@Tags(['unit'])
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/pages/login_prompt/login_prompt_cubit.dart';

import '../tunnels/fake_agent.dart';

void main() {
  const passphrase = LoginPrompt(
    id: 1,
    tunnelId: 'database',
    prompt: SshPassphrasePrompt(
      "Enter passphrase for key '/home/me/.ssh/id_ed25519': ",
      keyPath: '/home/me/.ssh/id_ed25519',
    ),
  );
  const code = LoginPrompt(
    id: 2,
    tunnelId: 'web',
    prompt: SshCodePrompt('(me@web) Verification code: '),
  );
  late FakeAgent agent;

  setUp(() => agent = FakeAgent());

  test('starts with no prompt and names itself', () async {
    final cubit = LoginPromptCubit(agent: agent);
    addTearDown(cubit.close);

    expect(cubit.state, const NoPrompt());
    expect('$cubit', 'LoginPromptCubit');
  });

  blocTest<LoginPromptCubit, LoginPromptState>(
    'asks the oldest prompt, and none once the agent has none',
    build: () => LoginPromptCubit(agent: agent),
    act: (_) => agent.promptsController
      ..add(const [passphrase, code])
      ..add(const [code])
      ..add(const []),
    expect: () => const [Asking(passphrase), Asking(code), NoPrompt()],
  );

  blocTest<LoginPromptCubit, LoginPromptState>(
    'sends an answer and moves on before the agent says so',
    build: () => LoginPromptCubit(agent: agent),
    act: (cubit) async {
      agent.promptsController.add(const [passphrase, code]);
      await Future<void>.delayed(Duration.zero);
      cubit.answer('hunter2');
      agent.promptsController.add(const [passphrase, code]);
    },
    expect: () => const [Asking(passphrase), Asking(code)],
    verify: (_) =>
        expect(agent.sent, const [AgentCommand.answer(1, 'hunter2')]),
  );

  blocTest<LoginPromptCubit, LoginPromptState>(
    'a cancel answers null',
    build: () => LoginPromptCubit(agent: agent),
    act: (cubit) async {
      agent.promptsController.add(const [code]);
      await Future<void>.delayed(Duration.zero);
      cubit.answer(null);
    },
    expect: () => const [Asking(code), NoPrompt()],
    verify: (_) => expect(agent.sent, const [AgentCommand.answer(2, null)]),
  );

  blocTest<LoginPromptCubit, LoginPromptState>(
    'an answer with nothing asked sends nothing',
    build: () => LoginPromptCubit(agent: agent),
    act: (cubit) => cubit.answer('hunter2'),
    expect: () => const <LoginPromptState>[],
    verify: (_) => expect(agent.sent, isEmpty),
  );

  blocTest<LoginPromptCubit, LoginPromptState>(
    'a prompt closed by the agent goes, unanswered',
    build: () => LoginPromptCubit(agent: agent),
    act: (_) => agent.promptsController
      ..add(const [passphrase])
      ..add(const []),
    expect: () => const [Asking(passphrase), NoPrompt()],
    verify: (_) => expect(agent.sent, isEmpty),
  );

  test('stops listening once closed', () async {
    final cubit = LoginPromptCubit(agent: agent);
    expect(agent.promptsController.hasListener, isTrue);

    await cubit.close();

    expect(agent.promptsController.hasListener, isFalse);
  });
}
