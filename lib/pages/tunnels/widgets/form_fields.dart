import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taka/theme/app_theme.dart';

class const FieldBox({
  super.key,
  final bool isFocused = false,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.theme;

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: isFocused ? colors.accent : Colors.transparent,
        ),
      ),
      child: child,
    );
  }
}

class const Input({
  super.key,
  required final TextEditingController controller,
  final FocusNode? focusNode,
  required final String hint,
  final TextStyle style = const TextStyle(),
  final bool autofocus = false,

  /// Hides what is typed, and offers no suggestions for it.
  final bool isSecret = false,
  required final void Function() onSubmitted,
}) extends StatefulWidget {
  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  late final _focus = widget.focusNode ?? FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_rebuild);
  }

  @override
  void dispose() {
    _focus.removeListener(_rebuild);
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return FieldBox(
      isFocused: _focus.hasFocus,
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        autofocus: widget.autofocus,
        obscureText: widget.isSecret,
        autocorrect: !widget.isSecret,
        enableSuggestions: !widget.isSecret,
        inputFormatters: [if (widget.isSecret) const _AnswerLimit()],
        style: widget.style,
        decoration: InputDecoration.collapsed(
          hintText: widget.hint,
          hintStyle: widget.style.copyWith(color: context.theme.textSecondary),
        ),
        onSubmitted: (_) => widget.onSubmitted(),
      ),
    );
  }
}

// ssh reads at most 1023 bytes of an answer.
class const _AnswerLimit() extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => utf8.encode(newValue.text).length > 1023 ? oldValue : newValue;
}
