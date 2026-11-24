import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taka/pages/tunnels/widgets/form_fields.dart';
import 'package:taka/theme/app_theme.dart';

/// What ssh asks while a tunnel logs in, opening under its row; [tunnel]
/// names the tunnel where its row isn't in sight.
class const LoginPromptForm({
  super.key,
  required final LoginPrompt prompt,
  final String? tunnel,

  /// Null cancels the login.
  required final void Function(String? answer) onAnswer,
}) extends StatefulWidget {
  @override
  State<LoginPromptForm> createState() => _LoginPromptFormState();
}

class _LoginPromptFormState extends State<LoginPromptForm>
    with SingleTickerProviderStateMixin {
  final _answer = TextEditingController();
  late final _opening = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );

  @override
  void initState() {
    super.initState();
    _opening.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 180),
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
      }
    });
  }

  @override
  void dispose() {
    _opening.dispose();
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
    final secondary = TextStyle(fontSize: 12, color: colors.textSecondary);
    final prompt = widget.prompt.prompt;

    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: _opening, curve: Curves.easeOut),
      alignment: Alignment.topCenter,
      child: CallbackShortcuts(
        bindings: {const SingleActivator(LogicalKeyboardKey.escape): _cancel},
        child: Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              if (widget.tunnel case final tunnel?)
                Text(
                  'Log in to open $tunnel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
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
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: SingleChildScrollView(child: Text(text.trim())),
                  ),
                ],
              },
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: Input(
                      controller: _answer,
                      hint: switch (prompt) {
                        SshPassphrasePrompt() => 'Passphrase',
                        SshPasswordPrompt() => 'Password',
                        SshCodePrompt() => 'Answer',
                      },
                      autofocus: true,
                      isSecret: true,
                      onSubmitted: _send,
                    ),
                  ),
                  TextButton(onPressed: _cancel, child: const Text('Cancel')),
                  FilledButton(onPressed: _send, child: const Text('Log In')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
