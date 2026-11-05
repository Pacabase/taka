import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taka/widgets/focus_ring.dart';

class const NativeSwitch({
  super.key,
  required final bool value,
  required final Color color,
  required final String label,
  required final void Function() onToggle,
}) extends StatefulWidget {
  @override
  State<NativeSwitch> createState() => _NativeSwitchState();
}

class _NativeSwitchState extends State<NativeSwitch> {
  static const _duration = Duration(milliseconds: 150);

  var _showsFocus = false;

  @override
  Widget build(BuildContext context) {
    final NativeSwitch(:value, :color, :label, :onToggle) = widget;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? Colors.white : Colors.black;
    final (
      :width,
      :height,
      :padding,
      :knob,
      :track,
      :knobColor,
      :border,
      :shadow,
    ) = switch (defaultTargetPlatform) {
      TargetPlatform.windows => (
        width: 40.0,
        height: 20.0,
        padding: 2.0,
        knob: 12.0,
        track: value ? color : Colors.transparent,
        knobColor: value
            ? (dark ? Colors.black : Colors.white)
            : ink.withValues(alpha: 0.6),
        border: Border.all(color: value ? color : ink.withValues(alpha: 0.6)),
        shadow: const <BoxShadow>[],
      ),
      TargetPlatform.linux => (
        width: 46.0,
        height: 26.0,
        padding: 3.0,
        knob: 20.0,
        track: value ? color : ink.withValues(alpha: 0.15),
        knobColor: Colors.white,
        border: null,
        shadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      _ => (
        width: 26.0,
        height: 15.0,
        padding: 1.0,
        knob: 13.0,
        track: value ? color : ink.withValues(alpha: dark ? 0.14 : 0.09),
        knobColor: Colors.white,
        border: null,
        shadow: const [
          BoxShadow(
            color: Color(0x4d000000),
            blurRadius: 1.5,
            offset: Offset(0, 0.5),
          ),
        ],
      ),
    };

    return Semantics(
      container: true,
      toggled: value,
      label: label,
      onTap: onToggle,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (shows) => setState(() => _showsFocus = shows),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => onToggle(),
          ),
        },
        child: GestureDetector(
          excludeFromSemantics: true,
          onTap: onToggle,
          child: FocusRing(
            isFocused: _showsFocus,
            borderRadius: BorderRadius.circular(height / 2),
            child: AnimatedContainer(
              duration: _duration,
              width: width,
              height: height,
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: track,
                border: border,
                borderRadius: BorderRadius.circular(height / 2),
              ),
              child: AnimatedAlign(
                duration: _duration,
                curve: Curves.easeOut,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: knob,
                  height: knob,
                  decoration: BoxDecoration(
                    color: knobColor,
                    shape: BoxShape.circle,
                    boxShadow: shadow,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
