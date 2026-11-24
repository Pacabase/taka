import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taka/pages/tunnels/widgets/form_fields.dart';
import 'package:taka/pages/tunnels/widgets/host_input.dart';
import 'package:taka/pages/tunnels/widgets/route_step.dart';
import 'package:taka/theme/app_theme.dart';
import 'package:taka/widgets/colour_picker.dart';
import 'package:taka/widgets/fill_or_scroll.dart';

final _notInAddress = RegExp('[^0-9a-fA-F.:]');

class const TunnelForm({
  super.key,
  final Tunnel? initial,
  final TunnelKind kind = TunnelKind.local,
  final List<String> hosts = const [],
  final List<String> groups = const [],
  final Map<String, TunnelColour> groupColours = const {},
  required final void Function(Tunnel tunnel) onSave,
  required final void Function() onCancel,
}) extends StatefulWidget {
  @override
  State<TunnelForm> createState() => _TunnelFormState();
}

class _TunnelFormState extends State<TunnelForm> {
  late TunnelKind _kind = widget.initial?.kind ?? widget.kind;
  // Each field keeps its place on screen, whichever tunnel ends it holds.
  late final _fromHost = TextEditingController();
  late final _fromPort = TextEditingController();
  late final _sshHost = TextEditingController();
  late final _toHost = TextEditingController();
  late final _toPort = TextEditingController();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _group = TextEditingController(text: widget.initial?.group);
  late TunnelColour? _colour = widget.initial?.colour;
  late final _fields = [
    _fromHost,
    _fromPort,
    _sshHost,
    _toHost,
    _toPort,
    _name,
    _group,
  ];
  ({String host, List<String> leftOut})? _pasted;
  late final _pasteCommand = _PasteCommandAction(onText: _fill);

  bool get _isLocal => _kind == TunnelKind.local;

  bool get _isRemote => _kind == TunnelKind.remote;

  bool get _isSocket => _isLocal && _toHost.text.trim().startsWith('/');

  // Retyped in another case, the group a tunnel is edited in is new.
  String? get _typedGroup => switch (groupNamed(_group.text)) {
    final typed? => groupLike(
      widget.groups,
      typed,
      except: widget.initial?.group,
    ),
    null => null,
  };

  TunnelColour? get _groupColour => widget.groupColours[_typedGroup];

  String? get _bindAddress => bindAddressNamed(_fromHost.text);

  // Quiet while an address is half typed; Add stays off until it's whole.
  String? get _fromNote => switch (_bindAddress) {
    null => null,
    final address when address.contains(_notInAddress) =>
      'Use an IP address, such as 172.17.0.1.',
    final address when !isIpAddress(address) || isLoopbackAddress(address) =>
      null,
    final address when isEveryAddress(address) =>
      'Other computers on your networks can use this tunnel, with no login.',
    final address =>
      'Anything that can reach $address can use this tunnel, with no login.',
  };

  // sshCommand is null for a tunnel system_ssh would refuse to open.
  bool get _isValid =>
      _port(_fromPort.text) != null &&
      _sshHost.text.trim().isNotEmpty &&
      (!_isLocal || _toHost.text.trim().isNotEmpty) &&
      (_kind == TunnelKind.socks || _isSocket || _port(_toPort.text) != null) &&
      _tunnel.sshCommand != null;

  @override
  void initState() {
    super.initState();
    if (widget.initial case final tunnel?) _show(tunnel);
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
    final colors = context.theme;
    const mono = TextStyle(fontFamily: fontMono, fontSize: 13);

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
        child: FillOrScroll(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Labelled(
                  label: 'Group',
                  child: HostInput(
                    controller: _group,
                    hosts: widget.groups,
                    hint: 'Optional',
                    style: const TextStyle(),
                    acceptsNew: true,
                    onSubmitted: _save,
                  ),
                ),
                Labelled(
                  label: 'Name',
                  child: Input(
                    controller: _name,
                    hint: 'Optional',
                    autofocus: true,
                    onSubmitted: _save,
                  ),
                ),
                _KindTabs(
                  kind: _kind,
                  onPick: (kind) => setState(() => _kind = kind),
                ),
                RouteStep(
                  label: _isRemote ? 'From, on the SSH host' : 'From',
                  hasNext: true,
                  child: ListenableBuilder(
                    listenable: _fromHost,
                    child: Row(
                      spacing: 6,
                      children: [
                        Expanded(
                          // The SSH host listens on its own 127.0.0.1.
                          child: _isRemote
                              ? Opacity(
                                  opacity: 0.5,
                                  child: FieldBox(
                                    child: Text(
                                      '127.0.0.1',
                                      style: mono.copyWith(
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  ),
                                )
                              : Input(
                                  controller: _fromHost,
                                  hint: '127.0.0.1',
                                  style: mono,
                                  onSubmitted: _save,
                                ),
                        ),
                        const _Colon(),
                        SizedBox(
                          width: 72,
                          child: Input(
                            controller: _fromPort,
                            hint: switch (_kind) {
                              TunnelKind.local => '5432',
                              TunnelKind.socks => '1080',
                              TunnelKind.remote => '8080',
                            },
                            style: mono,
                            onSubmitted: _save,
                          ),
                        ),
                      ],
                    ),
                    builder: (context, row) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 4,
                      children: [
                        row!,
                        if (_fromNote case final note? when !_isRemote)
                          Text(
                            note,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.orange,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                RouteStep(
                  label: 'SSH host',
                  hasNext: _kind != TunnelKind.socks,
                  child: HostInput(
                    controller: _sshHost,
                    hosts: widget.hosts,
                    hint:
                        'Host from ~/.ssh/config, user@host, or an ssh command',
                    style: mono,
                    onSubmitted: _save,
                  ),
                ),
                if (_kind != TunnelKind.socks)
                  RouteStep(
                    label: _isRemote ? 'To, on this computer' : 'To',
                    hasNext: false,
                    child: ListenableBuilder(
                      listenable: _toHost,
                      builder: (context, _) => Row(
                        spacing: 6,
                        children: [
                          Expanded(
                            child: Input(
                              controller: _toHost,
                              hint: _isRemote
                                  ? 'localhost'
                                  : 'localhost or /var/run/docker.sock',
                              style: mono,
                              onSubmitted: _save,
                            ),
                          ),
                          if (!_isSocket) ...[
                            const _Colon(),
                            SizedBox(
                              width: 72,
                              child: Input(
                                controller: _toPort,
                                hint: _isRemote ? '3000' : '5432',
                                style: mono,
                                onSubmitted: _save,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ListenableBuilder(
                  listenable: _sshHost,
                  builder: (context, _) => switch (_pasted) {
                    (:final host, :final leftOut)
                        when leftOut.isNotEmpty &&
                            _sshHost.text.trim() == host =>
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
                ListenableBuilder(
                  listenable: _group,
                  builder: (context, _) => _groupColour == null
                      ? Labelled(
                          label: 'Colour',
                          child: ColourPicker(
                            selected: _colour,
                            onPick: (colour) =>
                                setState(() => _colour = colour),
                          ),
                        )
                      : const SizedBox.shrink(),
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
      ),
    );
  }

  bool _fill(String text) {
    if (!mounted) return false;
    if (parseSshCommand(text) case (:final tunnel, :final leftOut)) {
      setState(() {
        _kind = tunnel.kind;
        _pasted = (host: tunnel.sshHost, leftOut: leftOut);
      });
      _show(tunnel);
      return true;
    }
    return false;
  }

  void _show(Tunnel tunnel) {
    final (fromPort, toHost, toPort) = switch (tunnel.kind) {
      TunnelKind.remote => (
        tunnel.remotePort,
        tunnel.localHost,
        tunnel.localPort,
      ),
      TunnelKind.local || TunnelKind.socks => (
        tunnel.localPort,
        tunnel.remoteSocket ?? tunnel.remoteHost,
        tunnel.remotePort,
      ),
    };
    for (final (field, value) in [
      (_fromHost, tunnel.bindAddress ?? ''),
      (_fromPort, '${fromPort ?? ''}'),
      (_sshHost, tunnel.sshHost),
      (_toHost, toHost ?? ''),
      (_toPort, '${toPort ?? ''}'),
    ]) {
      field.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
  }

  int? _port(String text) => switch (int.tryParse(text.trim(), radix: 10)) {
    final port? when port >= 1 && port <= 65535 => port,
    _ => null,
  };

  void _save() {
    if (_isValid) widget.onSave(_tunnel);
  }

  Tunnel get _tunnel => Tunnel(
    id: widget.initial?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
    name: _name.text.trim(),
    kind: _kind,
    sshHost: _sshHost.text.trim(),
    bindAddress: _isRemote ? null : _bindAddress,
    localHost: _isRemote && _toHost.text.trim().isNotEmpty
        ? _toHost.text.trim()
        : null,
    localPort: _port((_isRemote ? _toPort : _fromPort).text)!,
    remoteHost: _isLocal && !_isSocket ? _toHost.text.trim() : null,
    remotePort: switch (_kind) {
      TunnelKind.local => _isSocket ? null : _port(_toPort.text),
      TunnelKind.socks => null,
      TunnelKind.remote => _port(_fromPort.text),
    },
    remoteSocket: _isSocket ? _toHost.text.trim() : null,
    group: _typedGroup,
    colour: _colour,
  );
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
    final colors = context.theme;
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
                ? BoxDecoration(border: Border.all(color: colors.focusRing))
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
        color: context.theme.textSecondary,
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
