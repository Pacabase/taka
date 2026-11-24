@Tags(['unit'])
library;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/pages/login_prompt/login_prompt_cubit.dart';
import 'package:taka/pages/login_prompt/login_prompt_dialog.dart';
import 'package:taka/theme/taka_theme.dart';

import '../tunnels/fake_agent.dart';

void main() {
  const passphrase = LoginPrompt(
    id: 1,
    tunnel: 'Database',
    prompt: SshPassphrasePrompt(
      "Enter passphrase for key '/home/me/.ssh/id_ed25519': ",
      keyPath: '/home/me/.ssh/id_ed25519',
    ),
  );
  const password = LoginPrompt(
    id: 2,
    tunnel: 'Proxy',
    prompt: SshPasswordPrompt("me@bastion's password: "),
  );
  const code = LoginPrompt(
    id: 3,
    tunnel: 'Web',
    prompt: SshCodePrompt('<b>Verification</b> code: '),
  );
  late List<String?> answers;

  Future<void> pumpDialog(WidgetTester tester, LoginPrompt prompt) async {
    answers = [];
    await tester.pumpWidget(
      MaterialApp(
        theme: takaTheme(Brightness.light),
        home: LoginPromptDialog(prompt: prompt, onAnswer: answers.add),
      ),
    );
  }

  testWidgets('a passphrase names the key file, and its path', (tester) async {
    await pumpDialog(tester, passphrase);

    expect(find.text('Log in to open Database'), findsOneWidget);
    expect(find.text('Passphrase for id_ed25519'), findsOneWidget);
    expect(find.text('/home/me/.ssh/id_ed25519'), findsOneWidget);
  });

  testWidgets("a password shows ssh's question", (tester) async {
    await pumpDialog(tester, password);

    expect(find.text("me@bastion's password:"), findsOneWidget);
  });

  testWidgets("a server's question is shown as plain text", (tester) async {
    await pumpDialog(tester, code);

    expect(find.text('The server asks:'), findsOneWidget);
    expect(find.text('<b>Verification</b> code:'), findsOneWidget);
  });

  testWidgets('the answer is hidden as it is typed', (tester) async {
    await pumpDialog(tester, code);

    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isTrue,
    );
  });

  testWidgets('Return sends what was typed', (tester) async {
    await pumpDialog(tester, passphrase);

    await tester.enterText(find.byType(TextField), 'hunter2');
    await tester.testTextInput.receiveAction(TextInputAction.done);

    expect(answers, ['hunter2']);
  });

  testWidgets('Log In sends what was typed, even nothing', (tester) async {
    await pumpDialog(tester, password);

    await tester.tap(find.text('Log In'));

    expect(answers, ['']);
  });

  testWidgets('Cancel and Escape cancel', (tester) async {
    await pumpDialog(tester, password);

    await tester.enterText(find.byType(TextField), 'hunter2');
    await tester.tap(find.text('Cancel'));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);

    expect(answers, [null, null]);
  });

  group('LoginPromptLayer', () {
    late FakeAgent agent;

    Future<void> pumpLayer(WidgetTester tester) async {
      agent = FakeAgent();
      await tester.pumpWidget(
        MaterialApp(
          theme: takaTheme(Brightness.light),
          builder: (context, child) => BlocProvider(
            create: (_) => LoginPromptCubit(agent: agent),
            child: LoginPromptLayer(child: child!),
          ),
          home: const Scaffold(body: TextField()),
        ),
      );
    }

    testWidgets('shows the prompt over the window while it is asked', (
      tester,
    ) async {
      await pumpLayer(tester);
      expect(find.byType(LoginPromptDialog), findsNothing);

      agent.promptsController.add(const [passphrase]);
      await tester.pump();
      expect(find.byType(LoginPromptDialog), findsOneWidget);

      agent.promptsController.add(const []);
      await tester.pump();
      expect(find.byType(LoginPromptDialog), findsNothing);
    });

    testWidgets('sends the answer and closes', (tester) async {
      await pumpLayer(tester);
      agent.promptsController.add(const [password]);
      await tester.pump();

      await tester.enterText(
        find.descendant(
          of: find.byType(LoginPromptDialog),
          matching: find.byType(TextField),
        ),
        'hunter2',
      );
      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(agent.sent, const [AgentCommand.answer(2, 'hunter2')]);
      expect(find.byType(LoginPromptDialog), findsNothing);
    });

    testWidgets('the next prompt starts with an empty field', (tester) async {
      await pumpLayer(tester);
      agent.promptsController.add(const [password, code]);
      await tester.pump();
      final field = find.descendant(
        of: find.byType(LoginPromptDialog),
        matching: find.byType(TextField),
      );

      await tester.enterText(field, 'hunter2');
      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(find.text('<b>Verification</b> code:'), findsOneWidget);
      expect(tester.widget<TextField>(field).controller!.text, isEmpty);
    });
  });
}
