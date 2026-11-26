@Tags(['unit'])
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:core/core.dart';
import 'package:mocktail/mocktail.dart';
import 'package:system_ssh/system_ssh.dart';
import 'package:test/test.dart';

import 'fakes/fakes.dart';

void main() {
  for (final loopback in [false, true]) {
    group(loopback ? 'over loopback' : 'over a Unix socket', () {
      late Directory directory;
      late String path;
      late AgentChannel channel;
      late TunnelManager manager;
      late FakePreferences preferences;

      setUp(() async {
        directory = await Directory.systemTemp.createTemp('taka_socket');
        path = '${directory.path}/${loopback ? 'agent.port' : 'agent.sock'}';
        channel = loopback ? LoopbackChannel(path) : UnixChannel(path);
        manager = TunnelManager(
          store: FakeStore([database]),
          client: MockSshClient(),
        );
        await manager.load();
        preferences = FakePreferences();
      });

      tearDown(() async {
        await manager.close();
        await directory.delete(recursive: true);
      });

      Future<AgentServer> serve({void Function()? onUnseenPrompts}) async {
        final server = (await AgentServer.bind(
          channel,
          manager,
          preferences,
          onUnseenPrompts: onUnseenPrompts,
        ))!;
        addTearDown(server.close);
        return server;
      }

      Future<SocketAgentClient> connect() async {
        final agent = await SocketAgentClient.connect(channel);
        addTearDown(agent.close);
        return agent;
      }

      Future<ServerSocket> fakeAgent() async {
        if (!loopback) {
          return ServerSocket.bind(
            InternetAddress(path, type: InternetAddressType.unix),
            0,
          );
        }

        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        File(path).writeAsStringSync(AgentTicket.random(server.port).encoded);
        return server;
      }

      Future<StreamQueue<TunnelsSnapshot>> listen() async =>
          StreamQueue((await connect()).snapshots);

      test('a client gets the snapshot when it connects', () async {
        await serve();

        expect(await (await listen()).next, manager.state);
      });

      test('a command reaches the manager and every client sees it', () async {
        await serve();
        final agent = await connect();
        final mine = StreamQueue(agent.snapshots);
        final theirs = await listen();
        await (mine.next, theirs.next).wait;
        const added = Tunnel(
          id: 'c3',
          sshHost: 'web',
          forward: SocksProxy(localPort: 8080),
        );

        agent.send(const AgentCommand.save(added));

        expect((await mine.next).tunnels, [database, added]);
        expect((await theirs.next).tunnels, [database, added]);
      });

      test('each command reaches the manager', () async {
        await serve();
        final agent = await connect();
        final snapshots = StreamQueue(agent.snapshots);
        await snapshots.next;
        const added = Tunnel(
          id: 'c3',
          sshHost: 'web',
          forward: SocksProxy(localPort: 8080),
        );

        agent
          ..send(const AgentCommand.save(added))
          ..send(
            const AgentCommand.arrange([
              (id: 'c3', group: 'Web'),
              (id: 'a1', group: null),
            ]),
          )
          ..send(const AgentCommand.remove('a1'));

        await snapshots.next;
        expect((await snapshots.next).tunnels, [
          added.copyWith(group: 'Web'),
          database,
        ]);
        expect((await snapshots.next).tunnels, [added.copyWith(group: 'Web')]);

        agent.send(const AgentCommand.toggle('c3'));
        expect((await snapshots.next).statusOf('c3'), isNot(const Stopped()));
      });

      test('trustHostKey reaches the manager', () async {
        const hostKey = SshHostKey(
          host: 'bastion',
          type: 'ED25519',
          fingerprint: 'SHA256:4Q0Hx2v6PZ9dW1yYk0r6hN1m1bGq9cY',
        );
        registerFallbackValue(const SshTarget('fallback'));
        registerFallbackValue(hostKey);
        final client = MockSshClient();
        when(
          () => client.openTunnel(
            any(),
            remoteHost: any(named: 'remoteHost'),
            remotePort: any(named: 'remotePort'),
            bindAddress: any(named: 'bindAddress'),
            localPort: any(named: 'localPort'),
            onLog: any(named: 'onLog'),
            onPrompt: any(named: 'onPrompt'),
            abortTrigger: any(named: 'abortTrigger'),
          ),
        ).thenAnswer((_) async => throw SshUnknownHostKeyException(hostKey));
        final trusted = Completer<void>();
        when(
          () => client.trustHostKey(
            any(),
            any(),
            abortTrigger: any(named: 'abortTrigger'),
          ),
        ).thenAnswer((_) async => trusted.complete());
        await manager.close();
        manager = TunnelManager(store: FakeStore([database]), client: client);
        await manager.load();
        await serve();
        final agent = await connect();
        final snapshots = StreamQueue(agent.snapshots);
        await snapshots.next;

        agent.send(const AgentCommand.toggle('a1'));
        await snapshots.next;
        expect((await snapshots.next).statusOf('a1'), isA<UnknownHostKey>());
        agent.send(AgentCommand.trustHostKey('a1', hostKey.fingerprint));

        await trusted.future;
      });

      test(
        'export writes every tunnel, and import adds the new ones',
        () async {
          await serve();
          final agent = await connect();
          final snapshots = StreamQueue(agent.snapshots);
          await snapshots.next;
          final file = File('${directory.path}/exported.json');

          agent
            ..send(AgentCommand.exportTunnels(file.path))
            ..send(const AgentCommand.importTunnels([database, proxy]));

          expect((await snapshots.next).tunnels, [database, proxy]);
          expect(decodeTunnels(await file.readAsString()).book.tunnels, [
            database,
          ]);
        },
      );

      test(
        'a client gets the settings when it connects, and each change',
        () async {
          await serve();
          preferences.change(const AgentSettings(isLogging: true));
          final agent = await connect();
          final settings = StreamQueue(agent.settings);

          expect(await settings.next, const AgentSettings(isLogging: true));

          preferences.change(
            const AgentSettings(launchesAtLogin: true, isLogging: true),
          );
          expect(
            await settings.next,
            const AgentSettings(launchesAtLogin: true, isLogging: true),
          );
        },
      );

      test('settings commands reach the preferences', () async {
        await serve();
        final agent = await connect();
        await StreamQueue(agent.settings).next;

        agent
          ..send(const AgentCommand.setLaunchAtLogin(on: true))
          ..send(const AgentCommand.setDebugLogging(on: true))
          ..send(const AgentCommand.showLogs());

        expect(await preferences.calls.take(3).toList(), [
          'launchAtLogin true',
          'debugLogging true',
          'showLogs',
        ]);
      });

      test('logs that cannot be shown leave the agent listening', () async {
        await serve();
        final agent = await connect();
        final calls = StreamQueue(preferences.calls);
        preferences.logsFail = true;

        agent.send(const AgentCommand.showLogs());
        expect(await calls.next, 'showLogs');
        agent.send(const AgentCommand.setDebugLogging(on: true));

        expect(await calls.next, 'debugLogging true');
      });

      test('a bad line is ignored and the client stays connected', () async {
        await serve();
        final socket = await channel.connect();
        addTearDown(socket.destroy);
        final snapshots = await listen();
        await snapshots.next;

        socket
          ..writeln('not json')
          ..writeln('[]')
          ..writeln('{"command": "toggle"}');
        await manager.save(proxy);

        expect((await snapshots.next).tunnels, [database, proxy]);
      });

      test('snapshots end when the agent closes', () async {
        final server = await serve();
        final snapshots = await listen();
        await snapshots.next;

        await server.close();

        expect(await snapshots.hasNext, isFalse);
        expect(File(path).existsSync(), isFalse);
      });

      test('show asks every open window', () async {
        final server = await serve();
        final mine = await connect();
        final theirs = await connect();
        final requests = [
          StreamQueue(mine.tunnelRequests),
          StreamQueue(theirs.tunnelRequests),
        ];
        await (
          StreamQueue(mine.snapshots).next,
          StreamQueue(theirs.snapshots).next,
        ).wait;

        expect(server.show(const AgentMessage.openTunnel()), isTrue);

        await Future.wait(requests.map((queue) => queue.next));
      });

      test('show with no window open asks the next one, once', () async {
        final server = await serve();

        expect(server.show(const AgentMessage.openTunnel()), isFalse);

        final first = await connect();
        final second = await connect();
        final snapshots = StreamQueue(second.snapshots);
        await snapshots.next;
        await manager.save(proxy);
        await snapshots.next;
        await first.close();
        await second.close();

        expect(await first.tunnelRequests.length, 1);
        expect(await second.tunnelRequests.length, 0);
      });

      test('a window can listen for About after its first snapshot', () async {
        final server = await serve();
        final agent = await connect();
        final snapshots = StreamQueue(agent.snapshots);
        await snapshots.next;
        server.show(const AgentMessage.openTunnel());
        await manager.save(proxy);
        await snapshots.next;
        await agent.close();

        expect(await agent.tunnelRequests.length, 1);
      });

      test('a tunnel request reaches an open window', () async {
        final server = await serve();
        final agent = await connect();
        await agent.snapshots.first;

        expect(server.show(const AgentMessage.openTunnel('a1')), isTrue);

        expect(await agent.tunnelRequests.first, const OpenTunnel('a1'));
      });

      test(
        'with no window open, the next one gets the latest request, once',
        () async {
          final server = await serve();

          expect(server.show(const AgentMessage.openTunnel('a1')), isFalse);
          expect(server.show(const AgentMessage.openTunnel()), isFalse);

          final first = await connect();
          final second = await connect();
          final snapshots = StreamQueue(second.snapshots);
          await snapshots.next;
          await manager.save(proxy);
          await snapshots.next;
          await first.close();
          await second.close();

          expect(await first.tunnelRequests.toList(), [const OpenTunnel()]);
          expect(await second.tunnelRequests.toList(), isEmpty);
        },
      );

      test('show with a window open leaves none pending', () async {
        final server = await serve();
        final open = await connect();
        await StreamQueue(open.snapshots).next;
        server.show(const AgentMessage.openTunnel());
        await open.close();

        final next = await connect();
        final snapshots = StreamQueue(next.snapshots);
        await snapshots.next;
        await manager.save(proxy);
        await snapshots.next;
        await next.close();

        expect(await next.tunnelRequests.length, 0);
      });

      group('a login prompt', () {
        const password = SshPasswordPrompt("me@db's password: ");
        final asked = LoginPrompt(
          id: 1,
          tunnelId: database.id,
          prompt: password,
        );

        test('reaches every window, and the first answer wins', () async {
          final server = await serve();
          final mine = await connect();
          final other = await connect();
          final myPrompts = StreamQueue(mine.prompts);
          final theirs = StreamQueue(other.prompts);
          await (mine.identity, other.identity).wait;

          final answer = server.ask(database, password);

          expect(await myPrompts.next, [asked]);
          expect(await theirs.next, [asked]);
          mine.send(const AgentCommand.answer(1, 'hunter2'));
          expect(await answer, 'hunter2');
          other.send(const AgentCommand.answer(1, 'other'));
          expect(await myPrompts.next, isEmpty);
          expect(await theirs.next, isEmpty);
        });

        test('waits for a window that connects later', () async {
          final server = await serve();

          final answer = server.ask(database, password);
          final agent = await connect();

          expect(await agent.prompts.first, [asked]);
          agent.send(const AgentCommand.answer(1, ''));
          expect(await answer, '');
        });

        test('is cancelled once ssh withdraws it', () async {
          final server = await serve();
          final agent = await connect();
          final prompts = StreamQueue(agent.prompts);
          await agent.identity;
          final withdrawn = Completer<void>();

          final answer = server.ask(
            database,
            SshPasswordPrompt(password.text, withdrawn: withdrawn.future),
          );
          expect(await prompts.next, [asked]);
          withdrawn.complete();

          expect(await answer, isNull);
          expect(await prompts.next, isEmpty);
        });

        test('is cancelled when the last window that had it closes', () async {
          var reopened = 0;
          final server = await serve(onUnseenPrompts: () => reopened++);
          final agent = await connect();
          final answer = server.ask(database, password);
          await agent.prompts.first;
          agent.send(const AgentCommand.sawPrompts([1]));

          await agent.close();

          expect(await answer, isNull);
          expect(reopened, 0);
        });

        test(
          'waits for the next window if the last closed without it',
          () async {
            final reopened = Completer<void>();
            final server = await serve(onUnseenPrompts: reopened.complete);
            final agent = await connect();
            await agent.identity;
            final answer = server.ask(database, password);

            await agent.close();
            await reopened.future;
            final next = await connect();
            expect(await next.prompts.first, [asked]);
            next.send(const AgentCommand.answer(1, 'hunter2'));

            expect(await answer, 'hunter2');
          },
        );

        test('keeps only the prompts the closing window never had', () async {
          var reopened = 0;
          final server = await serve(onUnseenPrompts: () => reopened++);
          final agent = await connect();
          final prompts = StreamQueue(agent.prompts);
          await agent.identity;
          final first = server.ask(database, password);
          await prompts.next;
          var second = false;
          unawaited(server.ask(database, password).then((_) => second = true));
          await prompts.next;

          // 99 is no prompt, so it changes nothing.
          agent.send(const AgentCommand.sawPrompts([1, 99]));
          await agent.close();

          expect(await first, isNull);
          await pumpEventQueue();
          expect(second, isFalse);
          expect(reopened, 1);
        });

        test('stays while another window is open', () async {
          final server = await serve();
          final mine = await connect();
          final other = await connect();
          await (mine.identity, other.identity).wait;
          final answer = server.ask(database, password);
          await (mine.prompts.first, other.prompts.first).wait;

          await mine.close();
          other.send(const AgentCommand.answer(1, 'hunter2'));

          expect(await answer, 'hunter2');
        });

        test('is cancelled when the agent closes', () async {
          var reopened = 0;
          final server = await serve(onUnseenPrompts: () => reopened++);
          final agent = await connect();
          await agent.identity;

          final answer = server.ask(database, password);
          await server.close();

          expect(await answer, isNull);
          expect(await server.ask(database, password), isNull);
          expect(reopened, 0);
        });

        test('an answer to a prompt that is gone is ignored', () async {
          final server = await serve();
          final agent = await connect();
          final prompts = StreamQueue(agent.prompts);
          await agent.identity;
          final first = server.ask(
            database,
            SshPasswordPrompt(password.text, withdrawn: Future.value()),
          );
          expect(await first, isNull);

          agent.send(const AgentCommand.answer(1, 'late'));
          final second = server.ask(database, password);
          expect(await prompts.next, [asked]);
          expect(await prompts.next, isEmpty);
          expect(await prompts.next, [asked.copyWith(id: 2)]);
          agent.send(const AgentCommand.answer(2, 'hunter2'));

          expect(await second, 'hunter2');
        });
      });

      test('the client ignores bad lines and stays connected', () async {
        final server = await fakeAgent();
        addTearDown(server.close);
        server.listen(
          (socket) => unawaited(
            (socket
                  ..writeln('not json')
                  ..writeln('[]')
                  ..writeln('{}')
                  ..writeln('{"show": "settings"}')
                  ..writeln('{"tunnels": [1], "statuses": {}}')
                  ..writeln(jsonEncode(manager.state.toJson())))
                // Destroying it would drop what Windows hasn't sent yet.
                .close(),
          ),
        );
        final agent = await connect();

        expect(await agent.snapshots.toList(), [manager.state]);
        expect(await agent.tunnelRequests.length, 0);
      });

      test('a client learns which build of the agent it reached', () async {
        final server = (await AgentServer.bind(
          channel,
          manager,
          preferences,
          identity: '/Taka@1',
        ))!;
        addTearDown(server.close);

        expect(await (await connect()).identity, '/Taka@1');
      });

      test(
        'an agent too old to send its identity is identified as empty',
        () async {
          final server = await fakeAgent();
          addTearDown(server.close);
          server.listen((socket) {
            addTearDown(socket.destroy);
            socket.writeln(jsonEncode(manager.state.toJson()));
          });
          final agent = await connect();

          expect(await agent.identity, '');
          expect(await agent.snapshots.first, manager.state);
        },
      );

      test(
        'an agent that goes away before a word is identified as empty',
        () async {
          final server = await fakeAgent();
          addTearDown(server.close);
          server.listen((socket) => socket.destroy());

          expect(await (await connect()).identity, '');
        },
      );

      test('a quit command closes the manager', () async {
        await serve();
        final changes = manager.stream.toList();

        (await connect()).send(const AgentCommand.quit());

        await changes;
      });

      test(
        'a second agent finds the first one running',
        () async {
          await serve();

          expect(await AgentServer.bind(channel, manager, preferences), isNull);
        },
        skip: loopback && !Platform.isWindows
            ? 'Only Windows locks a file against its own process'
            : false,
      );
    }, testOn: loopback ? null : '!windows');
  }
}
