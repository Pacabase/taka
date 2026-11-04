import 'package:core/core.dart';
import 'package:flutter/material.dart';

class const TunnelTile({
  super.key,
  required final Tunnel tunnel,
  required final TunnelStatus status,
  required final void Function() onToggle,
  required final void Function() onEdit,
  required final void Function() onDelete,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      leading: switch (status) {
        Stopped() => Icon(Icons.circle_outlined, color: colors.outline),
        Connecting() => const SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        Connected() => Icon(Icons.circle, color: colors.primary),
        Failed() => Icon(Icons.error, color: colors.error),
      },
      title: Text(tunnel.title),
      subtitle: Text(switch (status) {
        Failed(:final message) => '${tunnel.summary}\n$message',
        _ => tunnel.summary,
      }),
      isThreeLine: status is Failed,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(value: status.isOn, onChanged: (_) => onToggle()),
          PopupMenuButton<void>(
            itemBuilder: (context) => [
              PopupMenuItem(onTap: onEdit, child: const Text('Edit')),
              PopupMenuItem(onTap: onDelete, child: const Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}
