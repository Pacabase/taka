@Tags(['unit'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('LoopbackChannel', () {
    late Directory directory;
    late String path;
    late LoopbackChannel channel;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('taka_loopback');
      addTearDown(() => directory.delete(recursive: true));
      path = '${directory.path}/agent.port';
      channel = LoopbackChannel(path);
    });

    Future<(AgentListener, List<AgentLink>)> listen() async {
      final listener = (await channel.listen())!;
      addTearDown(listener.close);
      final links = <AgentLink>[];
      listener.links.listen(links.add);
      return (listener, links);
    }

    Future<Socket> stranger() async {
      final socket = await Socket.connect(
        InternetAddress.loopbackIPv4,
        (await AgentTicket.read(path))!.port,
      );
      return socket;
    }

    test(
      'a client with the token gets through, with what it sends next',
      () async {
        final listener = (await channel.listen())!;
        addTearDown(listener.close);
        final client = await channel.connect();
        addTearDown(client.close);

        client.writeln('hello');

        expect(await (await listener.links.first).lines.first, 'hello');
      },
    );

    for (final (name, line) in [
      ('a wrong token', 'not the token'),
      ('a command', jsonEncode(const AgentCommand.quit().toJson())),
    ]) {
      test('a client sending $name first is dropped unheard', () async {
        final (_, links) = await listen();
        final socket = await stranger();
        addTearDown(socket.close);

        socket.writeln(line);

        expect(await socket.toList(), isEmpty);
        expect(links, isEmpty);
      });
    }

    test(
      "replaces a dead agent's ticket, and removes its own on close",
      () async {
        await File(path).writeAsString(AgentTicket.random(1).encoded);

        final listener = (await channel.listen())!;
        final client = await channel.connect();
        addTearDown(client.close);
        client.writeln('hello');
        expect(await (await listener.links.first).lines.first, 'hello');

        await listener.close();
        expect(File(path).existsSync(), isFalse);
      },
    );
  });

  group('AgentTicket', () {
    test('reads back what it wrote', () async {
      final directory = await Directory.systemTemp.createTemp('taka_ticket');
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/agent.port');
      final ticket = AgentTicket.random(4242);

      await file.writeAsString(ticket.encoded);

      expect((await AgentTicket.read(file.path))?.encoded, ticket.encoded);
    });

    test('is null for a missing, empty or broken file', () async {
      final directory = await Directory.systemTemp.createTemp('taka_ticket');
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/agent.port');

      expect(await AgentTicket.read(file.path), isNull);
      for (final text in ['', 'port token', '4242', '4242 a b']) {
        await file.writeAsString(text);
        expect(await AgentTicket.read(file.path), isNull, reason: text);
      }
    });

    test('a fresh one has a new token each time', () {
      expect(AgentTicket.random(1).token, isNot(AgentTicket.random(1).token));
    });

    test('admits only its own token', () {
      const ticket = AgentTicket(1, 'secret');

      expect(ticket.admits('secret'), isTrue);
      expect(ticket.admits('secre'), isFalse);
      expect(ticket.admits('secrets'), isFalse);
      expect(ticket.admits(''), isFalse);
      expect(ticket.admits('Secret'), isFalse);
    });
  });
}
