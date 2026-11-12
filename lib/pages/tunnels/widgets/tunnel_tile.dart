import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taka/pages/tunnels/widgets/native_switch.dart';
import 'package:taka/pages/tunnels/widgets/reorderable_rows.dart';
import 'package:taka/theme/taka_colors.dart';
import 'package:taka/theme/taka_theme.dart';
import 'package:taka/widgets/app_icon.dart';

class const TunnelTile({
  super.key,
  required final Tunnel tunnel,
  required final TunnelStatus status,
  required final void Function() onToggle,
  required final void Function(String fingerprint) onTrust,
  required final void Function() onEdit,
  required final void Function() onDelete,
}) extends StatefulWidget {
  @override
  State<TunnelTile> createState() => _TunnelTileState();
}

class _TunnelTileState extends State<TunnelTile> {
  var _hovered = false;
  var _focused = false;
  Timer? _copied;

  @override
  void dispose() {
    _copied?.cancel();
    super.dispose();
  }

  Future<void> _copy(String command) async {
    await Clipboard.setData(ClipboardData(text: command));
    if (!mounted) return;

    _copied?.cancel();
    setState(
      () => _copied = Timer(
        const Duration(milliseconds: 1500),
        () => setState(() => _copied = null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = TakaColors.of(context);
    final TunnelTile(:tunnel, :status) = widget;
    final isHovered = _hovered || ReorderableRows.isLifted(context);
    Widget captioned(String text, Color color, {String details = ''}) {
      final label = Text(text, style: TextStyle(fontSize: 12, color: color));
      return details.trim().isEmpty
          ? label
          : Tooltip(message: details.trim(), child: label);
    }

    final caption = switch (status) {
      Failed(:final message) => captioned(
        plainReason(message),
        colors.red,
        details: message,
      ),
      Connecting() => captioned('Connecting…', colors.orange),
      UnknownHostKey(:final host, :final type, :final fingerprint) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          captioned(
            'First connection to $host. Check its $type key:',
            colors.orange,
          ),
          SelectableText(
            fingerprint,
            style: TextStyle(
              fontFamily: monoFont,
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
      Reconnecting(:final reason) => captioned(
        'Reconnecting — ${plainReason(reason)}',
        colors.orange,
        details: reason,
      ),
      Connected(:final warning) when warning.isNotEmpty => captioned(
        forwardWarning(tunnel),
        colors.orange,
        details: warning,
      ),
      Stopped() || Connected() when tunnel.name.isEmpty => null,
      Stopped() || Connected() => Text(
        tunnel.summary,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: monoFont,
          fontSize: 12,
          color: colors.textSecondary,
        ),
      ),
    };

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (focused) => setState(() => _focused = focused),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: isHovered ? colors.selection : Colors.transparent,
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      tunnel.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    ?caption,
                  ],
                ),
              ),
              if (isHovered || _focused) ...[
                if (tunnel.sshCommand case final command?)
                  IconButton(
                    tooltip: _copied == null ? 'Copy SSH command' : 'Copied',
                    onPressed: () => _copy(command),
                    icon: AppIcon(
                      _copied == null ? AppIcons.copy : AppIcons.check,
                      color: _copied == null
                          ? colors.textSecondary
                          : colors.green,
                    ),
                  ),
                IconButton(
                  tooltip: 'Edit',
                  onPressed: widget.onEdit,
                  icon: AppIcon(AppIcons.pencil, color: colors.textSecondary),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: widget.onDelete,
                  icon: AppIcon(AppIcons.trash, color: colors.textSecondary),
                ),
              ],
              if (status is Connecting || status is Reconnecting)
                SizedBox.square(
                  dimension: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.orange,
                  ),
                ),
              if (status is Failed)
                AppIcon(AppIcons.triangleAlert, color: colors.red),
              if (status case UnknownHostKey(:final fingerprint))
                Tooltip(
                  message: "Only if it's the key the server's owner gave you",
                  child: TextButton(
                    onPressed: () => widget.onTrust(fingerprint),
                    child: const Text('Trust'),
                  ),
                ),
              NativeSwitch(
                value: status.isOn,
                color: status is Connecting || status is Reconnecting
                    ? colors.orange
                    : colors.green,
                label: tunnel.title,
                onToggle: widget.onToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
