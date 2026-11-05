import 'dart:async';
import 'dart:io';

import 'package:agent/src/tray_entries.dart';
import 'package:core/core.dart';
import 'package:nativeapi/nativeapi.dart';

class AgentTray({
  required final TunnelManager manager,
  required final String assetsPath,
  required final void Function() onAbout,
  required final void Function() onSettings,
  required final Future<void> Function() onQuit,
}) {
  late final Image? _connectedImage = Image.fromFile(
    '$assetsPath/tray_icon_on.png',
  );
  late final Image? _idleImage = Image.fromFile(
    '$assetsPath/tray_icon_off.png',
  );

  void show() {
    final icon = TrayIcon.create();
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
            onSettings();
          case TrayIconRightClickedEvent() when !Platform.isWindows:
            icon.openContextMenu();
          case _:
        }
      })
      ..setVisible(true);

    // Nothing else holds the icon: this subscription keeps it on screen.
    manager.changes.listen((snapshot) => _rebuild(icon, snapshot));
    _rebuild(icon, manager.snapshot);
  }

  void _rebuild(TrayIcon icon, TunnelsSnapshot snapshot) {
    final menu = _menu(trayEntries(snapshot));
    if (menu == null) return;

    final count = snapshot.connectedCount;
    final image = count == 0 ? _idleImage : _connectedImage;
    if (image != null) icon.icon = image;
    icon
      ..setContextMenu(menu)
      ..setTooltip(trayTooltip(snapshot));
    if (Platform.isMacOS) icon.setTitle(count == 0 ? null : '$count');
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
      onClick: () => _guard(manager.toggle(tunnel.id)),
    )?..state = isChecked ? MenuItemState.checked : MenuItemState.unchecked,
    CopyEntry(:final label, :final text) => _create(
      label,
      MenuItemType.normal,
      onClick: () => Clipboard.instance.writeText(text),
    ),
    ActionEntry(
      :final action,
      :final label,
      :final isEnabled,
      :final shortcut,
    ) =>
      _create(
        label,
        MenuItemType.normal,
        onClick: isEnabled ? () => _run(action) : null,
      )?..accelerator = shortcut == null ? null : _shortcut(shortcut),
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

  void _run(TrayAction action) => switch (action) {
    TrayAction.connectAll => _guard(manager.connectAll()),
    TrayAction.disconnectAll => _guard(manager.disconnectAll()),
    TrayAction.about => onAbout(),
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
