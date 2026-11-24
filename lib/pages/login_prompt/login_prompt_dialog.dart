import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taka/pages/login_prompt/login_prompt_cubit.dart';
import 'package:taka/theme/app_theme.dart';

/// [child] with the login prompt over it while the agent waits on one.
///
/// Above the navigator, so a page opening from the menu or tray doesn't
/// close it.
class const LoginPromptLayer({super.key, required final Widget child})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<LoginPromptCubit>().state;
    final isAsking = state is Asking;

    return Stack(
      children: [
        ExcludeFocus(excluding: isAsking, child: child),
        if (state case Asking(:final prompt)) ...[
          const ModalBarrier(dismissible: false, color: Colors.black38),
          // A text field needs an overlay of its own for its menus.
          Overlay(
            key: ValueKey(prompt.id),
            initialEntries: [
              OverlayEntry(
                builder: (context) => LoginPromptDialog(
                  prompt: prompt,
                  onAnswer: context.read<LoginPromptCubit>().answer,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class const LoginPromptDialog({
  super.key,
  required final LoginPrompt prompt,

  /// Null cancels the login.
  required final void Function(String? answer) onAnswer,
}) extends StatefulWidget {
  @override
  State<LoginPromptDialog> createState() => _LoginPromptDialogState();
}

class _LoginPromptDialogState extends State<LoginPromptDialog> {
  final _answer = TextEditingController();

  @override
  void dispose() {
    _answer
      ..clear()
      ..dispose();
    super.dispose();
  }

  void _send() {
    final answer = _answer.text;
    _answer.clear();
    widget.onAnswer(answer);
  }

  void _cancel() {
    _answer.clear();
    widget.onAnswer(null);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme;
    final LoginPrompt(:tunnel, :prompt) = widget.prompt;
    final secondary = TextStyle(fontSize: 12, color: colors.textSecondary);

    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _cancel},
      child: AlertDialog(
        title: Text(
          'Log in to open $tunnel',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              ...switch (prompt) {
                SshPassphrasePrompt(:final keyPath) => [
                  Text(switch (keyPath.split(RegExp(r'[/\\]')).last) {
                    // ssh cuts a long path short, maybe inside a folder.
                    '' => 'Passphrase for the key',
                    final file => 'Passphrase for $file',
                  }),
                  Text(
                    keyPath,
                    style: secondary.copyWith(fontFamily: fontMono),
                  ),
                ],
                SshPasswordPrompt(:final text) => [Text(text.trim())],
                // The server's own words, so plain text and never markup.
                SshCodePrompt(:final text) => [
                  Text('The server asks:', style: secondary),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 160),
                    child: SingleChildScrollView(child: Text(text.trim())),
                  ),
                ],
              },
              TextField(
                controller: _answer,
                autofocus: true,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                onSubmitted: (_) => _send(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: _cancel, child: const Text('Cancel')),
          FilledButton(onPressed: _send, child: const Text('Log In')),
        ],
      ),
    );
  }
}
