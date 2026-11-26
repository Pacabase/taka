import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_prompt_cubit.freezed.dart';

@freezed
sealed class LoginPromptState with _$LoginPromptState {
  const factory none() = NoPrompt;

  const factory asking(LoginPrompt prompt) = Asking;
}

/// The oldest prompt the agent is waiting on that this window hasn't answered.
class LoginPromptCubit({required final AgentClient agent})
    extends Cubit<LoginPromptState> {
  late final StreamSubscription<List<LoginPrompt>> _prompts;
  List<LoginPrompt> _waiting = const [];
  // Answered here, but maybe not yet gone from what the agent last sent.
  final Set<int> _answered = {};

  @override
  String toString() => 'LoginPromptCubit';

  this : super(const NoPrompt()) {
    _prompts = agent.prompts.listen((prompts) {
      if (prompts.isNotEmpty) {
        agent.send(
          AgentCommand.sawPrompts([for (final prompt in prompts) prompt.id]),
        );
      }
      _waiting = prompts;
      _answered.retainAll(prompts.map((prompt) => prompt.id));
      _show();
    });
  }

  /// Sends [answer] to prompt [id] if it's the one shown, so a second press
  /// can't answer the next; null cancels its login.
  void answer(int id, String? answer) {
    if (state case Asking(:final prompt) when prompt.id == id) {
      _answered.add(prompt.id);
      agent.send(AgentCommand.answer(prompt.id, answer));
      _show();
    }
  }

  void _show() => emit(switch (_waiting
      .where((prompt) => !_answered.contains(prompt.id))
      .firstOrNull) {
    final prompt? => Asking(prompt),
    null => const NoPrompt(),
  });

  @override
  Future<void> close() async {
    await _prompts.cancel();
    return super.close();
  }
}
