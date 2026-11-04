import 'package:core/core.dart';
import 'package:flutter/material.dart';

class const TunnelForm({super.key, final Tunnel? initial})
    extends StatefulWidget {
  @override
  State<TunnelForm> createState() => _TunnelFormState();
}

class _TunnelFormState extends State<TunnelForm> {
  final _form = GlobalKey<FormState>();
  late TunnelKind _kind = widget.initial?.kind ?? TunnelKind.local;
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _sshHost = TextEditingController(text: widget.initial?.sshHost);
  late final _localPort = TextEditingController(
    text: widget.initial?.localPort.toString(),
  );
  late final _remoteHost = TextEditingController(
    text: widget.initial?.remoteHost,
  );
  late final _remotePort = TextEditingController(
    text: widget.initial?.remotePort?.toString(),
  );

  @override
  void dispose() {
    for (final controller in [
      _name,
      _sshHost,
      _localPort,
      _remoteHost,
      _remotePort,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add tunnel' : 'Edit tunnel'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              SegmentedButton(
                segments: const [
                  ButtonSegment(value: TunnelKind.local, label: Text('Local')),
                  ButtonSegment(value: TunnelKind.socks, label: Text('SOCKS')),
                ],
                selected: {_kind},
                onSelectionChanged: (kinds) =>
                    setState(() => _kind = kinds.single),
              ),
              _field(_name, 'Name', hint: 'Production database'),
              _field(
                _sshHost,
                'SSH host',
                hint: 'An alias from ~/.ssh/config, a host or user@host',
              ),
              _field(_localPort, 'Local port', hint: '5432', isPort: true),
              if (_kind == TunnelKind.local) ...[
                _field(_remoteHost, 'Remote host', hint: 'db.internal'),
                _field(_remotePort, 'Remote port', hint: '5432', isPort: true),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    required String hint,
    bool isPort = false,
  }) => TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label, hintText: hint),
    validator: (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return 'Required';
      if (!isPort) return null;

      final port = int.tryParse(text, radix: 10);
      return port == null || port < 1 || port > 65535 ? '1 to 65535' : null;
    },
  );

  void _save() {
    if (!_form.currentState!.validate()) return;

    final isLocal = _kind == TunnelKind.local;
    Navigator.pop(
      context,
      Tunnel(
        id:
            widget.initial?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        name: _name.text.trim(),
        kind: _kind,
        sshHost: _sshHost.text.trim(),
        localPort: int.parse(_localPort.text.trim()),
        remoteHost: isLocal ? _remoteHost.text.trim() : null,
        remotePort: isLocal ? int.parse(_remotePort.text.trim()) : null,
      ),
    );
  }
}
