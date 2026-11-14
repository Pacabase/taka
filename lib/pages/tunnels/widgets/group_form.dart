import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taka/pages/tunnels/widgets/form_fields.dart';
import 'package:taka/pages/tunnels/widgets/route_step.dart';
import 'package:taka/widgets/colour_picker.dart';

class const GroupForm({
  super.key,
  required final String group,
  required final TunnelColour? colour,
  required final void Function(String name, TunnelColour? colour) onSave,
  required final void Function() onCancel,
}) extends StatefulWidget {
  @override
  State<GroupForm> createState() => _GroupFormState();
}

class _GroupFormState extends State<GroupForm> {
  late final _name = TextEditingController(text: widget.group);
  late TunnelColour? _colour = widget.colour;

  bool get _isValid => groupNamed(_name.text) != null;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (_isValid) widget.onSave(_name.text, _colour);
  }

  @override
  Widget build(BuildContext context) {
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
              Labelled(
                label: 'Name',
                child: Input(
                  controller: _name,
                  hint: 'Such as Production',
                  style: const TextStyle(),
                  autofocus: true,
                  onSubmitted: _save,
                ),
              ),
              Labelled(
                label: 'Colour',
                child: ColourPicker(
                  selected: _colour,
                  onPick: (colour) => setState(() => _colour = colour),
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
                    listenable: _name,
                    builder: (context, _) => FilledButton(
                      onPressed: _isValid ? _save : null,
                      child: const Text('Save'),
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
}
