import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taka/pages/tunnels/widgets/form_fields.dart';
import 'package:taka/pages/tunnels/widgets/host_input.dart';
import 'package:taka/pages/tunnels/widgets/route_step.dart';
import 'package:taka/theme/taka_colors.dart';
import 'package:taka/theme/taka_theme.dart';

class const TunnelForm({
  super.key,
  final Tunnel? initial,
  final TunnelKind kind = TunnelKind.local,
  final List<String> hosts = const [],
  required final void Function(Tunnel tunnel) onSave,
  required final void Function() onCancel,
}) extends StatefulWidget {
  @override
  State<TunnelForm> createState() => _TunnelFormState();
}

class _TunnelFormState extends State<TunnelForm> {
  late TunnelKind _kind = widget.initial?.kind ?? widget.kind;
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
  List<String> _leftOut = const [];

  bool get _isLocal => _kind == TunnelKind.local;

  bool get _isValid =>
      _port(_localPort.text) != null &&
      _sshHost.text.trim().isNotEmpty &&
      (!_isLocal ||
          _remoteHost.text.trim().isNotEmpty &&
              _port(_remotePort.text) != null);

  @override
  void initState() {
    super.initState();
    for (final field in _fields) {
      field.addListener(() => _fillFrom(field));
    }
  }

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

    // As DismissIntent, Esc first closes the host suggestions.
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: {
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) => widget.onCancel(),
          ),
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
              RouteStep(
                label: 'From',
                hasNext: true,
                child: Row(
                  spacing: 6,
                  children: [
                    Expanded(
                      child: Opacity(
                        opacity: 0.5,
                        child: FieldBox(
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
              RouteStep(
                label: 'SSH host',
                hasNext: _isLocal,
                child: HostInput(
                  controller: _sshHost,
                  hosts: widget.hosts,
                  hint: 'Host from ~/.ssh/config, user@host, or an ssh command',
                  style: mono,
                  onSubmitted: _save,
                ),
              ),
              if (_isLocal)
                RouteStep(
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
                padding: const EdgeInsets.only(left: RouteStep.indent),
                child: Labelled(
                  label: 'Name',
                  child: _input(_name, hint: 'Optional'),
                ),
              ),
              if (_leftOut.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: RouteStep.indent),
                  child: Text(
                    'Not copied: ${_leftOut.join(', ')}. '
                    'Set these for the host in ~/.ssh/config.',
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
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
      ),
    );
  }

  Widget _input(
    TextEditingController controller, {
    required String hint,
    TextStyle style = const TextStyle(),
    bool autofocus = false,
  }) => Input(
    controller: controller,
    hint: hint,
    style: style,
    autofocus: autofocus,
    onSubmitted: _save,
  );

  // Waits, so the field the command went into finishes taking it first.
  void _fillFrom(TextEditingController field) {
    if (parseSshCommand(field.text) case (:final tunnel, :final leftOut)) {
      scheduleMicrotask(() {
        if (!mounted) return;

        setState(() {
          _kind = tunnel.kind;
          _leftOut = leftOut;
        });
        if (field == _name) _name.clear();
        _localPort.text = '${tunnel.localPort}';
        _sshHost.text = tunnel.sshHost;
        _remoteHost.text = tunnel.remoteHost ?? '';
        _remotePort.text = '${tunnel.remotePort ?? ''}';
      });
    }
  }

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
