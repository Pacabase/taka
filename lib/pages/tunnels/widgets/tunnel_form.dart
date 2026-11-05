import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taka/theme/taka_colors.dart';
import 'package:taka/theme/taka_theme.dart';

class const TunnelForm({
  super.key,
  final Tunnel? initial,
  required final void Function(Tunnel tunnel) onSave,
  required final void Function() onCancel,
}) extends StatefulWidget {
  @override
  State<TunnelForm> createState() => _TunnelFormState();
}

class _TunnelFormState extends State<TunnelForm> {
  late TunnelKind _kind = widget.initial?.kind ?? TunnelKind.local;
  late final _localPort = TextEditingController(
    text: widget.initial?.localPort.toString(),
  );
  late final _sshHost = TextEditingController(text: widget.initial?.sshHost);
  late final _remoteHost = TextEditingController(
    text: widget.initial?.remoteHost,
  );
  late final _remotePort = TextEditingController(
    text: widget.initial?.remotePort?.toString(),
  );
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _fields = [_localPort, _sshHost, _remoteHost, _remotePort, _name];

  bool get _isLocal => _kind == TunnelKind.local;

  bool get _isValid =>
      _port(_localPort.text) != null &&
      _sshHost.text.trim().isNotEmpty &&
      (!_isLocal ||
          _remoteHost.text.trim().isNotEmpty &&
              _port(_remotePort.text) != null);

  @override
  void dispose() {
    for (final field in _fields) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = TakaColors.of(context);
    const mono = TextStyle(fontFamily: monoFont, fontSize: 13);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): widget.onCancel,
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            _KindTabs(
              kind: _kind,
              onPick: (kind) => setState(() => _kind = kind),
            ),
            _RouteStep(
              label: 'From',
              hasNext: true,
              child: Row(
                spacing: 6,
                children: [
                  Expanded(
                    child: Opacity(
                      opacity: 0.5,
                      child: _FieldBox(
                        child: Text(
                          '127.0.0.1',
                          style: mono.copyWith(color: colors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                  const _Colon(),
                  SizedBox(
                    width: 72,
                    child: _input(
                      _localPort,
                      hint: _isLocal ? '5432' : '1080',
                      style: mono,
                      autofocus: true,
                    ),
                  ),
                ],
              ),
            ),
            _RouteStep(
              label: 'SSH host',
              hasNext: _isLocal,
              child: _input(
                _sshHost,
                hint: 'Host from ~/.ssh/config, or user@host',
                style: mono,
              ),
            ),
            if (_isLocal)
              _RouteStep(
                label: 'To',
                hasNext: false,
                child: Row(
                  spacing: 6,
                  children: [
                    Expanded(
                      child: _input(
                        _remoteHost,
                        hint: 'localhost',
                        style: mono,
                      ),
                    ),
                    const _Colon(),
                    SizedBox(
                      width: 72,
                      child: _input(_remotePort, hint: '5432', style: mono),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(left: _RouteStep.indent),
              child: _Labelled(
                label: 'Name',
                child: _input(_name, hint: 'Optional'),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
                ListenableBuilder(
                  listenable: Listenable.merge(_fields),
                  builder: (context, _) => FilledButton(
                    onPressed: _isValid ? _save : null,
                    child: Text(widget.initial == null ? 'Add' : 'Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller, {
    required String hint,
    TextStyle style = const TextStyle(),
    bool autofocus = false,
  }) => _Input(
    controller: controller,
    hint: hint,
    style: style,
    autofocus: autofocus,
    onSubmitted: _save,
  );

  int? _port(String text) => switch (int.tryParse(text.trim(), radix: 10)) {
    final port? when port >= 1 && port <= 65535 => port,
    _ => null,
  };

  void _save() {
    if (!_isValid) return;

    widget.onSave(
      Tunnel(
        id:
            widget.initial?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        name: _name.text.trim(),
        kind: _kind,
        sshHost: _sshHost.text.trim(),
        localPort: _port(_localPort.text)!,
        remoteHost: _isLocal ? _remoteHost.text.trim() : null,
        remotePort: _isLocal ? _port(_remotePort.text) : null,
      ),
    );
  }
}

class const _KindTabs({
  required final TunnelKind kind,
  required final void Function(TunnelKind kind) onPick,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        for (final (tab, label) in [
          (TunnelKind.local, 'Forward a port'),
          (TunnelKind.socks, 'SOCKS proxy'),
        ])
          _KindTab(
            label: label,
            isSelected: tab == kind,
            onTap: () => onPick(tab),
          ),
      ],
    );
  }
}

class const _KindTab({
  required final String label,
  required final bool isSelected,
  required final void Function() onTap,
}) extends StatefulWidget {
  @override
  State<_KindTab> createState() => _KindTabState();
}

class _KindTabState extends State<_KindTab> {
  final _focus = FocusNode();
  var _showsFocus = false;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = TakaColors.of(context);
    final _KindTab(:label, :isSelected, :onTap) = widget;

    return Semantics(
      selected: isSelected,
      button: true,
      onTap: onTap,
      child: FocusableActionDetector(
        focusNode: _focus,
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (shows) => setState(() => _showsFocus = shows),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => onTap(),
          ),
        },
        child: GestureDetector(
          excludeFromSemantics: true,
          onTap: () {
            _focus.unfocus();
            onTap();
          },
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? colors.accent : Colors.transparent,
                ),
              ),
            ),
            foregroundDecoration: _showsFocus
                ? BoxDecoration(border: Border.all(color: colors.accent))
                : null,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
                color: isSelected ? colors.textBrilliant : colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class const _FieldBox({
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

class const _Input({
  required final TextEditingController controller,
  required final String hint,
  required final TextStyle style,
  required final bool autofocus,
  required final void Function() onSubmitted,
}) extends StatefulWidget {
  @override
  State<_Input> createState() => _InputState();
}

class _InputState extends State<_Input> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FieldBox(
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

class const _Colon() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: TakaColors.of(context).textSecondary,
        shape: BoxShape.circle,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [dot, dot],
    );
  }
}

class const _Labelled({
  required final String label,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        SizedBox(
          height: 16,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: TakaColors.of(context).textSecondary,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

// The dashes run on through the 12px gap to the next step's dot.
class const _RouteStep({
  required final String label,
  required final bool hasNext,
  required final Widget child,
}) extends StatelessWidget {
  static const indent = 22.0;

  @override
  Widget build(BuildContext context) {
    final color = TakaColors.of(context).textSecondary;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 2,
          top: 30,
          bottom: hasNext ? -41 : null,
          width: 9,
          child: Column(
            spacing: 2,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasNext ? null : color,
                  border: Border.all(color: color, width: 1.5),
                ),
              ),
              if (hasNext)
                Expanded(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _Dashes(color),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: indent),
          child: _Labelled(label: label, child: child),
        ),
      ],
    );
  }
}

class const _Dashes(final Color color) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    final x = size.width / 2;
    for (var y = 0.0; y < size.height; y += 6) {
      canvas.drawLine(Offset(x, y), Offset(x, min(y + 3, size.height)), paint);
    }
  }

  @override
  bool shouldRepaint(_Dashes old) => old.color != color;
}
