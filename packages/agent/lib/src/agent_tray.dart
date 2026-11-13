import 'dart:async';
import 'dart:io';

import 'package:agent/src/tray_entries.dart';
import 'package:core/core.dart';
import 'package:fimber/fimber.dart';
import 'package:nativeapi/nativeapi.dart';

class AgentTray({
  required final TunnelManager manager,
  required final String assetsPath,
  required final void Function() onManageTunnels,
  required final void Function(String? id) onOpenTunnel,
  required final Future<void> Function() onQuit,
}) {
  late final Image? _connectedImage = Image.fromFile(
    '$assetsPath/tray_icon_on.png',
  );
  late final Image? _idleImage = Image.fromFile(
    '$assetsPath/tray_icon_off.png',
  );

  TrayIcon? _icon;

  void show() {
    // Otherwise Linux trays know the icon by nativeapi's own application ID.
    final icon = _icon = Platform.isLinux
        ? TrayIcon.createWithIdentifier('com.pacabase.taka')
        : TrayIcon.create();
    if (icon == null) return;

    icon
      ..isIconTemplate = true
      ..setContextMenuTrigger(
        Platform.isWindows
            ? ContextMenuTrigger.rightClicked
            : ContextMenuTrigger.clicked,
      )
      ..addListener((event) {
        switch (event) {
          case TrayIconClickedEvent() when Platform.isWindows:
            onManageTunnels();
          case TrayIconRightClickedEvent() when !Platform.isWindows:
            icon.openContextMenu();
          case _:
        }
      })
      ..setVisible(true);

    // Nothing else holds the tray: this subscription keeps its icon on screen.
    manager.changes.listen(_rebuild);
    _rebuild(manager.snapshot);
  }

  void _rebuild(TunnelsSnapshot snapshot) {
    final icon = _icon;
    final menu = _menu(trayEntries(snapshot));
    if (icon == null || menu == null) return;

    final count = snapshot.connectedCount;
    final image = count == 0 ? _idleImage : _connectedImage;
    if (image != null) icon.icon = image;
    icon
      ..setContextMenu(menu)
      ..setTooltip(trayTooltip(snapshot));
    // GNOME's AppIndicator draws it as macOS does; other Linux trays ignore it.
    if (!Platform.isWindows) icon.setTitle(count == 0 ? null : '$count');
  }

  Menu? _menu(List<TrayEntry> entries) {
    final menu = Menu.create();
    if (menu == null) return null;

    for (final entry in entries) {
      menu.addItem(_item(entry));
    }
    return menu;
  }

  MenuItem? _item(TrayEntry entry) => switch (entry) {
    TunnelEntry(:final tunnel, :final label, :final isChecked) => _create(
      label,
      MenuItemType.checkbox,
      onClick: () => _guard(_toggle(tunnel.id)),
    )?..state = isChecked ? MenuItemState.checked : MenuItemState.unchecked,
    CopyEntry(:final label, :final text) => _create(
      label,
      MenuItemType.normal,
      onClick: () => Clipboard.instance.writeText(text),
    ),
    ActionEntry(:final action, :final label, :final shortcut) => _create(
      label,
      MenuItemType.normal,
      onClick: () => _run(action),
    )?..accelerator = shortcut == null ? null : _shortcut(shortcut),
    GroupActionEntry(:final group, :final label, :final connects) => _create(
      label,
      MenuItemType.normal,
      onClick: () => _guard(
        connects
            ? _connectAll(group: group)
            : manager.disconnectAll(group: group),
      ),
    ),
    TunnelActionEntry(:final tunnel, :final action, :final label) => _create(
      label,
      MenuItemType.normal,
      onClick: () => switch (action) {
        TunnelAction.edit => onOpenTunnel(tunnel.id),
        TunnelAction.tryAgain => _tryAgain(tunnel.id),
      },
    ),
    InfoEntry(:final label) => _create(label, MenuItemType.normal),
    SeparatorEntry() => _create('', MenuItemType.separator),
    SubmenuEntry(:final label, :final entries) =>
      MenuItem.createWithLabelAndType(label, MenuItemType.submenu)
        ?..submenu = _menu(entries),
  };

  MenuItem? _create(
    String label,
    MenuItemType type, {
    void Function()? onClick,
  }) {
    final item = MenuItem.createWithLabelAndType(label, type);
    if (item == null) return null;

    item.isEnabled = onClick != null;
    if (onClick != null) {
      item.addListener((event) {
        if (event is MenuItemClickedEvent) onClick();
      });
    }
    return item;
  }

  // The menu can be stale: don't stop a tunnel that has come back since.
  void _tryAgain(String id) {
    if (!manager.snapshot.statusOf(id).isOn) _guard(_toggle(id));
  }

  // A new server's key is trusted in the window, so connecting brings it up.
  Future<void> _toggle(String id) async {
    if (manager.snapshot.statusOf(id) is! UnknownHostKey) {
      await manager.toggle(id);
    }
    if (manager.snapshot.statusOf(id) is UnknownHostKey) onManageTunnels();
  }

  Future<void> _connectAll({String? group}) async {
    await manager.connectAll(group: group);
    final statuses = manager.snapshot.statuses.values;
    if (statuses.any((status) => status is UnknownHostKey)) onManageTunnels();
  }

  void _run(TrayAction action) => switch (action) {
    TrayAction.connectAll => _guard(_connectAll()),
    TrayAction.disconnectAll => _guard(manager.disconnectAll()),
    TrayAction.addTunnel => onOpenTunnel(null),
    TrayAction.manageTunnels => onManageTunnels(),
    TrayAction.quit => _guard(onQuit()),
  };

  // An uncaught error would end the agent, and every tunnel with it.
  void _guard(Future<void> work) => unawaited(
    work.catchError(
      (Object exception) => Fimber.e('A tray action failed', ex: exception),
    ),
  );

  KeyboardAccelerator _shortcut(String key) => KeyboardAccelerator(
    modifiers: Platform.isMacOS ? ModifierKey.meta : ModifierKey.ctrl,
    key: key,
  );
}
