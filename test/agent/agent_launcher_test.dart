@Tags(['unit'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/agent/agent_launcher.dart';

void main() {
  late Directory directory;
  late String path;
  late File agent;
  late TakaInstall install;
  late List<String> events;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('taka_launcher');
    path = '${directory.path}/agent.sock';
    agent = await File('${directory.path}/Taka').create();
    install = TakaInstall(
      app: '${directory.path}/app',
      agent: agent.path,
      agentBundle: '${directory.path}/Taka.app',
      agentAssets: directory.path,
    );
    events = [];
  });

  tearDown(() => directory.delete(recursive: true));

  Future<void> serve(String identity) async {
    final file = File(path);
    if (file.existsSync()) file.deleteSync();
    final server = await ServerSocket.bind(
      InternetAddress(path, type: InternetAddressType.unix),
      0,
    );
    addTearDown(server.close);
    final clients = <Socket>[];
    server.listen((client) {
      clients.add(client);
      client.writeln(jsonEncode(AgentMessage.identity(identity).toJson()));
      utf8.decoder.bind(client).transform(const LineSplitter()).listen((
        line,
      ) async {
        if (AgentCommand.fromJson(jsonDecode(line)) is QuitAgent) {
          events.add('quit');
          await server.close();
          for (final client in clients) {
            client.destroy();
          }
        }
      });
    });
  }

  Future<ProcessResult> Function(String, List<String>) opens({
    String? identity,
    int exitCode = 0,
    String stderr = '',
  }) => (executable, arguments) async {
    events.add([executable, ...arguments].join(' '));
    if (identity != null) await serve(identity);
    return ProcessResult(0, exitCode, '', stderr);
  };

  Future<AgentClient> connect(
    Future<ProcessResult> Function(String, List<String>) run,
  ) async {
    final client = await connectToAgent(
      socketPath: path,
      install: install,
      run: run,
      answerTimeout: const Duration(milliseconds: 500),
      quitTimeout: const Duration(milliseconds: 500),
      identityTimeout: const Duration(milliseconds: 200),
    );
    addTearDown(client.close);
    return client;
  }

  test('returns the running agent when it is from this build', () async {
    await serve(agentIdentity(agent.path));

    final client = await connect(opens());

    expect(await client.identity, agentIdentity(agent.path));
    expect(events, isEmpty);
  });

  test('replaces an agent from another build', () async {
    await serve('/old/Taka@1');

    final client = await connect(opens(identity: agentIdentity(agent.path)));

    expect(await client.identity, agentIdentity(agent.path));
    expect(events, ['quit', 'open -n -g ${install.agentBundle}']);
  });

  test(
    'starts the agent when none runs, and returns once it answers',
    () async {
      final client = await connect(opens(identity: agentIdentity(agent.path)));

      expect(await client.identity, agentIdentity(agent.path));
      expect(events, ['open -n -g ${install.agentBundle}']);
    },
  );

  test('throws a timeout when the started agent never answers', () async {
    await expectLater(connect(opens()), throwsA(isA<AgentTimeoutException>()));
  });

  test('reports open failing', () async {
    await expectLater(
      connect(opens(exitCode: 1, stderr: 'no such app\n')),
      throwsA(
        isA<ProcessException>()
            .having((exception) => exception.executable, 'executable', 'open')
            .having((exception) => exception.message, 'message', 'no such app'),
      ),
    );
  });

  test('keeps the running agent when its own binary is missing', () async {
    await serve('/old/Taka@1');
    await agent.delete();

    final client = await connect(opens());

    expect(await client.identity, '/old/Taka@1');
    expect(events, isEmpty);
  });
}
