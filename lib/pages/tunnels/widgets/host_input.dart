import 'package:flutter/material.dart';
import 'package:taka/pages/tunnels/widgets/form_fields.dart';
import 'package:taka/theme/taka_colors.dart';

class const HostInput({
  super.key,
  required final TextEditingController controller,
  required final List<String> hosts,
  required final String hint,
  required final TextStyle style,
  required final void Function() onSubmitted,
}) extends StatefulWidget {
  @override
  State<HostInput> createState() => _HostInputState();
}

class _HostInputState extends State<HostInput> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = TakaColors.of(context);

    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focus,
      optionsBuilder: (value) {
        final typed = value.text.trim().toLowerCase();
        return widget.hosts.where(
          (host) => host.toLowerCase().contains(typed) && host != value.text,
        );
      },
      fieldViewBuilder: (context, controller, focus, onFieldSubmitted) => Input(
        controller: controller,
        focusNode: focus,
        hint: widget.hint,
        style: widget.style,
        onSubmitted: () {
          final typed = controller.text;
          if (!widget.hosts.contains(typed.trim())) onFieldSubmitted();
          if (controller.text == typed) widget.onSubmitted();
        },
      ),
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: TextFieldTapRegion(
          child: Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 160, maxWidth: 320),
            decoration: BoxDecoration(
              color: colors.selection,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 4),
              shrinkWrap: true,
              children: [
                for (final (index, host) in options.indexed)
                  Suggestion(
                    host: host,
                    style: widget.style,
                    isHighlighted:
                        AutocompleteHighlightedOption.of(context) == index,
                    onTap: () => onSelected(host),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class const Suggestion({
  super.key,
  required final String host,
  required final TextStyle style,
  required final bool isHighlighted,
  required final void Function() onTap,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (isHighlighted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Scrollable.ensureVisible(context, alignment: 0.5);
      });
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          color: isHighlighted
              ? TakaColors.of(context).surface
              : Colors.transparent,
          child: Text(host, style: style),
        ),
      ),
    );
  }
}
