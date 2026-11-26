@Tags(['unit'])
library;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/pages/login_prompt/login_prompt_form.dart';
import 'package:taka/theme/taka_theme.dart';

void main() {
  const passphrase = LoginPrompt(
    id: 1,
    tunnelId: 'database',
    prompt: SshPassphrasePrompt(
      "Enter passphrase for key '/home/me/.ssh/id_ed25519': ",
      keyPath: '/home/me/.ssh/id_ed25519',
    ),
  );
  const password = LoginPrompt(
    id: 2,
    tunnelId: 'proxy',
    prompt: SshPasswordPrompt("me@bastion's password: "),
  );
  const code = LoginPrompt(
    id: 3,
    tunnelId: 'web',
    prompt: SshCodePrompt('<b>Verification</b> code: '),
  );
  late List<String?> answers;

  Future<void> pumpForm(
    WidgetTester tester,
    LoginPrompt prompt, {
    String? tunnel,
  }) async {
    answers = [];
    await tester.pumpWidget(
      MaterialApp(
        theme: takaTheme(Brightness.light),
        home: Scaffold(
          body: LoginPromptForm(
            prompt: prompt,
            tunnel: tunnel,
            onAnswer: answers.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a passphrase names the key file, and its path', (tester) async {
    await pumpForm(tester, passphrase);

    expect(find.text('Passphrase for id_ed25519'), findsOneWidget);
    expect(find.text('/home/me/.ssh/id_ed25519'), findsOneWidget);
    expect(find.text('Passphrase'), findsOneWidget);
  });

  testWidgets('a key path ssh cut short at a folder names no file', (
    tester,
  ) async {
    await pumpForm(
      tester,
      const LoginPrompt(
        id: 4,
        tunnelId: 'database',
        prompt: SshPassphrasePrompt(
          "Enter passphrase for key '/very/long/': ",
          keyPath: '/very/long/',
        ),
      ),
    );

    expect(find.text('Passphrase for the key'), findsOneWidget);
  });

  testWidgets("a password shows ssh's question", (tester) async {
    await pumpForm(tester, password);

    expect(find.text("me@bastion's password:"), findsOneWidget);
  });

  testWidgets("a server's question is shown as plain text", (tester) async {
    await pumpForm(tester, code);

    expect(find.text('The server asks:'), findsOneWidget);
    expect(find.text('<b>Verification</b> code:'), findsOneWidget);
  });

  testWidgets("an older ssh's passphrase prompt shows its words", (
    tester,
  ) async {
    await pumpForm(
      tester,
      const LoginPrompt(
        id: 5,
        tunnelId: 'database',
        prompt: SshPassphrasePrompt(
          "Enter passphrase for key '/home/me/.ssh/id_ed25519': ",
          keyPath: '/home/me/.ssh/id_ed25519',
          isVerified: false,
        ),
      ),
    );

    expect(find.text('ssh, or the server, asks:'), findsOneWidget);
    expect(
      find.text("Enter passphrase for key '/home/me/.ssh/id_ed25519':"),
      findsOneWidget,
    );
    expect(find.text('Passphrase for id_ed25519'), findsNothing);
    expect(find.text('Answer'), findsOneWidget);
  });

  testWidgets('an answer stays within the 1023 bytes ssh reads', (
    tester,
  ) async {
    await pumpForm(tester, password);

    await tester.enterText(find.byType(TextField), 'ä' * 511);
    await tester.enterText(find.byType(TextField), '${'ä' * 511}ää');
    await tester.testTextInput.receiveAction(TextInputAction.done);

    expect(answers.single, 'ä' * 511);
  });

  testWidgets('takes exactly 1023 bytes, and turns away a longer paste', (
    tester,
  ) async {
    await pumpForm(tester, password);
    final longest = '${'a' * 1021}ä';

    await tester.enterText(find.byType(TextField), 'a' * 1024);
    expect(find.text('a' * 1024), findsNothing);
    await tester.enterText(find.byType(TextField), longest);
    await tester.testTextInput.receiveAction(TextInputAction.done);

    expect(answers.single, longest);
  });

  testWidgets('names the tunnel only when told to', (tester) async {
    await pumpForm(tester, password);
    expect(find.textContaining('Log in to open'), findsNothing);

    await pumpForm(tester, password, tunnel: 'Proxy');
    expect(find.text('Log in to open Proxy'), findsOneWidget);
  });

  testWidgets('the answer is hidden as it is typed, and has focus', (
    tester,
  ) async {
    await pumpForm(tester, code);
    final field = tester.widget<TextField>(find.byType(TextField));

    expect(field.obscureText, isTrue);
    expect(field.enableSuggestions, isFalse);
    expect(field.focusNode!.hasFocus, isTrue);
  });

  testWidgets('Return sends what was typed', (tester) async {
    await pumpForm(tester, passphrase);

    await tester.enterText(find.byType(TextField), 'hunter2');
    await tester.testTextInput.receiveAction(TextInputAction.done);

    expect(answers, ['hunter2']);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('Log In sends what was typed, even nothing', (tester) async {
    await pumpForm(tester, password);

    await tester.tap(find.text('Log In'));

    expect(answers, ['']);
  });

  testWidgets('Cancel and Escape cancel', (tester) async {
    await pumpForm(tester, password);

    await tester.enterText(find.byType(TextField), 'hunter2');
    await tester.tap(find.text('Cancel'));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);

    expect(answers, [null, null]);
  });
}
