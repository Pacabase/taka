import 'dart:async';
import 'dart:io';

import 'package:agent/src/tray_entries.dart';
import 'package:core/core.dart';
import 'package:nativeapi/nativeapi.dart';

class AgentTray({
  required final TunnelManager manager,
  required final String assetsPath,
  required final void Function() onSettings,
  required final Future<void> Function() onQuit,
}) {
  TrayIcon? _icon;
  late final Image? _connectedImage = Image.fromFile(
    '$assetsPath/tray_icon_on.png',
  );
  late final Image? _idleImage = Image.fromFile(
    '$assetsPath/tray_icon_off.png',
  );
  // nativeapi frees a menu or item, and its listener, once Dart collects it.
  List<void Function()> _shown = [];

  void show() {
    final icon = TrayIcon.create();
    if (icon == null) return;

    icon
      ..isIconTemplate = true
      ..setContextMenuTrigger(
        Platform.isMacOS
            ? ContextMenuTrigger.clicked
            : ContextMenuTrigger.rightClicked,
      )
      ..addListener((event) {
        if (event is TrayIconClickedEvent && Platform.isWindows) onSettings();
      })
      ..setVisible(true);
    _icon = icon;

    manager.changes.listen(_rebuild);
    _rebuild(manager.snapshot);
  }

  void _rebuild(TunnelsSnapshot snapshot) {
    final icon = _icon;
    if (icon == null) return;

    final shown = <void Function()>[];
    final menu = _menu(trayEntries(snapshot), shown);
    if (menu == null) return;

    final count = snapshot.connectedCount;
    final image = count == 0 ? _idleImage : _connectedImage;
    if (image != null) icon.icon = image;
    icon
      ..setContextMenu(menu)
      ..setTooltip(trayTooltip(snapshot));
    if (Platform.isMacOS) icon.setTitle(count == 0 ? null : '$count');

    final previous = _shown;
    _shown = shown;
    Timer.run(() {
      for (final dispose in previous) {
        dispose();
      }
    });
  }

  Menu? _menu(List<TrayEntry> entries, List<void Function()> shown) {
    final menu = Menu.create();
    if (menu == null) return null;

    shown.add(menu.dispose);
    for (final entry in entries) {
      menu.addItem(_item(entry, shown));
    }
    return menu;
  }

  MenuItem? _item(TrayEntry entry, List<void Function()> shown) {
    final (label, type) = switch (entry) {
      TunnelEntry(:final label) => (label, MenuItemType.checkbox),
      SubmenuEntry(:final label) => (label, MenuItemType.submenu),
      InfoEntry(:final label) ||
      CopyEntry(:final label) ||
      ActionEntry(:final label) => (label, MenuItemType.normal),
      SeparatorEntry() => ('', MenuItemType.separator),
    };
    final item = MenuItem.createWithLabelAndType(label, type);
    if (item == null) return null;

    shown.add(item.dispose);
    final onClick = switch (entry) {
      TunnelEntry(:final tunnel) => () => _guard(manager.toggle(tunnel.id)),
      CopyEntry(:final text) => () => Clipboard.instance.writeText(text),
      ActionEntry(:final action, isEnabled: true) => () => _run(action),
      _ => null,
    };
    item.isEnabled = onClick != null || entry is SubmenuEntry;
    if (onClick != null) {
      item.addListener((event) {
        if (event is MenuItemClickedEvent) onClick();
      });
    }
    switch (entry) {
      case TunnelEntry(:final isChecked):
        item.state = isChecked
            ? MenuItemState.checked
            : MenuItemState.unchecked;
      case ActionEntry(:final shortcut?):
        item.accelerator = _shortcut(shortcut);
      case SubmenuEntry(:final entries):
        item.submenu = _menu(entries, shown);
      default:
    }
    return item;
  }

  void _run(TrayAction action) => switch (action) {
    TrayAction.connectAll => _guard(manager.connectAll()),
    TrayAction.disconnectAll => _guard(manager.disconnectAll()),
    TrayAction.settings => onSettings(),
    TrayAction.quit => _guard(onQuit()),
  };

  // An uncaught error would end the agent, and every tunnel with it.
  void _guard(Future<void> work) => unawaited(
    work.catchError(
      (Object exception) => stderr.writeln('A tray action failed: $exception'),
    ),
  );

  KeyboardAccelerator _shortcut(String key) => KeyboardAccelerator(
    modifiers: Platform.isMacOS ? ModifierKey.meta : ModifierKey.ctrl,
    key: key,
  );
}
