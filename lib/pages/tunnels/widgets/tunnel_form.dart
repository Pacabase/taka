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
  late final _localHost = TextEditingController(
    text: widget.initial?.localHost,
  );
  late final _sshHost = TextEditingController(text: widget.initial?.sshHost);
  late final _remoteHost = TextEditingController(
    text: widget.initial?.remoteHost,
  );
  late final _remotePort = TextEditingController(
    text: widget.initial?.remotePort?.toString(),
  );
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _fields = [
    _localHost,
    _localPort,
    _sshHost,
    _remoteHost,
    _remotePort,
    _name,
  ];
  ({String host, List<String> leftOut})? _pasted;
  late final _pasteCommand = _PasteCommandAction(onText: _fill);

  bool get _isLocal => _kind == TunnelKind.local;

  // Its From is a port on the SSH host, and its To is on this computer.
  bool get _isRemote => _kind == TunnelKind.remote;

  bool get _isValid =>
      _port(_localPort.text) != null &&
      _sshHost.text.trim().isNotEmpty &&
      (!_isLocal || _remoteHost.text.trim().isNotEmpty) &&
      (_kind == TunnelKind.socks || _port(_remotePort.text) != null);

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
          PasteTextIntent: _pasteCommand,
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
                label: _isRemote ? 'From, on the SSH host' : 'From',
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
                        _isRemote ? _remotePort : _localPort,
                        hint: switch (_kind) {
                          TunnelKind.local => '5432',
                          TunnelKind.socks => '1080',
                          TunnelKind.remote => '8080',
                        },
                        style: mono,
                        autofocus: true,
                      ),
                    ),
                  ],
                ),
              ),
              RouteStep(
                label: 'SSH host',
                hasNext: _kind != TunnelKind.socks,
                child: HostInput(
                  controller: _sshHost,
                  hosts: widget.hosts,
                  hint: 'Host from ~/.ssh/config, user@host, or an ssh command',
                  style: mono,
                  onSubmitted: _save,
                ),
              ),
              if (_kind != TunnelKind.socks)
                RouteStep(
                  label: _isRemote ? 'To, from this computer' : 'To',
                  hasNext: false,
                  child: Row(
                    spacing: 6,
                    children: [
                      Expanded(
                        child: _input(
                          _isRemote ? _localHost : _remoteHost,
                          hint: 'localhost',
                          style: mono,
                        ),
                      ),
                      const _Colon(),
                      SizedBox(
                        width: 72,
                        child: _input(
                          _isRemote ? _localPort : _remotePort,
                          hint: _isRemote ? '3000' : '5432',
                          style: mono,
                        ),
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
              ListenableBuilder(
                listenable: _sshHost,
                builder: (context, _) => switch (_pasted) {
                  (:final host, :final leftOut)
                      when leftOut.isNotEmpty && _sshHost.text.trim() == host =>
                    Padding(
                      padding: const EdgeInsets.only(left: RouteStep.indent),
                      child: Text(
                        'Not copied: ${leftOut.join(', ')}. '
                        'Set these for the host in ~/.ssh/config.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  _ => const SizedBox.shrink(),
                },
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

  bool _fill(String text) {
    if (!mounted) return false;
    if (parseSshCommand(text) case (:final tunnel, :final leftOut)) {
      setState(() {
        _kind = tunnel.kind;
        _pasted = (host: tunnel.sshHost, leftOut: leftOut);
      });
      for (final (field, value) in [
        (_localHost, tunnel.localHost ?? ''),
        (_localPort, '${tunnel.localPort}'),
        (_sshHost, tunnel.sshHost),
        (_remoteHost, tunnel.remoteHost ?? ''),
        (_remotePort, '${tunnel.remotePort ?? ''}'),
      ]) {
        field.value = TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );
      }
      return true;
    }
    return false;
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
        localHost: _isRemote && _localHost.text.trim().isNotEmpty
            ? _localHost.text.trim()
            : null,
        localPort: _port(_localPort.text)!,
        remoteHost: _isLocal ? _remoteHost.text.trim() : null,
        remotePort: _kind == TunnelKind.socks ? null : _port(_remotePort.text),
      ),
    );
  }
}

// Reads the clipboard itself: a field is one line, so it would drop the
// newlines of a command split over lines.
class _PasteCommandAction({required final bool Function(String text) onText})
    extends Action<PasteTextIntent> {
  @override
  Future<void> invoke(PasteTextIntent intent) async {
    final paste = callingAction;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text case final text? when onText(text)) return;

    paste?.invoke(intent);
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
          (TunnelKind.remote, 'Expose a port'),
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
