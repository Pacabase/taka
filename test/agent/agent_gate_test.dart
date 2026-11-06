@Tags(['unit'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/agent/agent_gate.dart';
import 'package:taka/pages/agent_error_page.dart';
import 'package:taka/pages/settings/settings_bloc.dart';
import 'package:taka/taka_app.dart';

import '../pages/tunnels/fake_agent.dart';

void main() {
  test('says in plain words why the helper did not start', () {
    expect(
      agentFailure(const ProcessException('open', [])),
      "macOS couldn't open it.",
    );
    expect(
      agentFailure(
        const ProcessException('/opt/taka/agent/bin/taka_agent', []),
      ),
      "It couldn't be started.",
    );
    expect(
      agentFailure(
        const SocketException('no answer on its socket within 5 seconds'),
      ),
      "It started but didn't answer within 5 seconds.",
    );
    expect(
      agentFailure(Exception('boom')),
      'Something went wrong while starting it.',
    );
  });

  testWidgets('shows why it failed, and Try Again opens the app once it '
      'answers', (tester) async {
    final agent = FakeAgent();
    var tries = 0;
    await tester.pumpWidget(
      AgentGate(
        version: '1.2.3',
        connect: () async {
          if (++tries == 1) {
            throw const SocketException(
              'no answer on its socket within 5 seconds',
            );
          }
          return agent;
        },
        connected: (agent) => TakaApp(
          version: '1.2.3',
          settings: SettingsBloc(agent: agent),
          home: const Text('Tunnels'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Taka's background helper didn't start"), findsOneWidget);
    expect(
      find.text("It started but didn't answer within 5 seconds."),
      findsOneWidget,
    );

    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();

    expect(find.text('Tunnels'), findsOneWidget);
    expect(tries, 2);
  });

  testWidgets('Copy Details copies the version and the error, and Show '
      'Details shows them', (tester) async {
    final copied = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') copied.add(call.arguments);
        return null;
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        home: AgentErrorPage(
          error: Exception('boom'),
          version: '1.2.3',
          onTryAgain: () {},
        ),
      ),
    );

    await tester.tap(find.text('Copy Details'));
    await tester.tap(find.text('Show Details'));
    await tester.pump();

    final details =
        (copied.single! as Map<Object?, Object?>)['text']! as String;
    expect(details, startsWith('Taka 1.2.3 on '));
    expect(details, endsWith('Exception: boom'));
    expect(find.text(details), findsOneWidget);
  });
}
