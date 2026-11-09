@Tags(['unit'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/agent/agent_launcher.dart';
import 'package:taka/pages/agent_error_page.dart';

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
      agentFailure(const AgentTimeoutException()),
      "It started but didn't answer within 5 seconds.",
    );
    expect(
      agentFailure(const AgentTimeoutException(output: 'libX11.so.6')),
      "It didn't answer within 5 seconds, and left an error under Show Details.",
    );
    expect(
      agentFailure(Exception('boom')),
      'Something went wrong while starting it.',
    );
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
