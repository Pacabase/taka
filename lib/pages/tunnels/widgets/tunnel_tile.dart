import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:taka/pages/tunnels/widgets/native_switch.dart';
import 'package:taka/theme/taka_colors.dart';
import 'package:taka/theme/taka_theme.dart';
import 'package:taka/widgets/app_icon.dart';
import 'package:taka/widgets/focus_ring.dart';

class const TunnelTile({
  super.key,
  required final Tunnel tunnel,
  required final TunnelStatus status,
  required final void Function() onToggle,
  required final void Function() onEdit,
  required final void Function() onDelete,
}) extends StatefulWidget {
  @override
  State<TunnelTile> createState() => _TunnelTileState();
}

class _TunnelTileState extends State<TunnelTile> {
  var _hovered = false;
  var _focused = false;

  @override
  void initState() {
    super.initState();
    lastInputWasKey.addListener(_rebuild);
  }

  @override
  void dispose() {
    lastInputWasKey.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final colors = TakaColors.of(context);
    final TunnelTile(:tunnel, :status) = widget;
    final caption = switch (status) {
      Failed(:final message) => Text(
        message,
        style: TextStyle(fontSize: 12, color: colors.red),
      ),
      Connecting() => Text(
        'Connecting…',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, color: colors.orange),
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
          color: _hovered ? colors.selection : null,
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
              if (_hovered || _focused && lastInputWasKey.value) ...[
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
              if (status is Connecting)
                SizedBox.square(
                  dimension: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.orange,
                  ),
                ),
              if (status is Failed)
                AppIcon(AppIcons.triangleAlert, color: colors.red),
              NativeSwitch(
                value: status.isOn,
                color: status is Connecting ? colors.orange : colors.green,
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
