import 'package:flutter/material.dart';
import 'package:taka/theme/taka_colors.dart';

class const FieldBox({
  super.key,
  final bool isFocused = false,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = TakaColors.of(context);

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
  required final TextStyle style,
  final bool autofocus = false,
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
        style: widget.style,
        decoration: InputDecoration.collapsed(
          hintText: widget.hint,
          hintStyle: widget.style.copyWith(
            color: TakaColors.of(context).textSecondary,
          ),
        ),
        onSubmitted: (_) => widget.onSubmitted(),
      ),
    );
  }
}
