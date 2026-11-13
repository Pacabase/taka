import 'dart:async';
import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taka/pages/tunnels/tunnels_bloc.dart';
import 'package:taka/pages/tunnels/widgets/reorderable_rows.dart';
import 'package:taka/pages/tunnels/widgets/tunnel_form.dart';
import 'package:taka/pages/tunnels/widgets/tunnel_tile.dart';
import 'package:taka/pages/tunnels/widgets/tunnels_header.dart';
import 'package:taka/taka_app.dart';
import 'package:taka/theme/taka_colors.dart';

class const TunnelsPage({
  super.key,
  final Stream<OpenTunnel> tunnelRequests = const Stream.empty(),
}) extends StatefulWidget {
  @override
  State<TunnelsPage> createState() => _TunnelsPageState();
}

class _TunnelsPageState extends State<TunnelsPage> {
  var _isFormOpen = false;
  Tunnel? _editing;
  var _newKind = TunnelKind.local;
  var _hosts = const <String>[];
  late final StreamSubscription<OpenTunnel> _tunnelRequests;

  @override
  void initState() {
    super.initState();
    _tunnelRequests = widget.tunnelRequests.listen(
      (request) => unawaited(_openRequested(request)),
    );
  }

  @override
  void dispose() {
    unawaited(_tunnelRequests.cancel());
    super.dispose();
  }

  Future<void> _openRequested(OpenTunnel request) async {
    final bloc = context.read<TunnelsBloc>();
    // A window opened from the tray gets the request before its first snapshot.
    final state = bloc.state is Loading
        ? await bloc.stream.firstWhere(
            (state) => state is! Loading,
            orElse: () => const Loading(),
          )
        : bloc.state;
    if (!mounted || state is! Ready) return;
    final tunnel = state.snapshot.tunnels
        .where((tunnel) => tunnel.id == request.id)
        .firstOrNull;
    if (request.id != null && tunnel == null) return;

    Navigator.popUntil(context, (route) => route.isFirst);
    _openForm(tunnel);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TunnelsBloc, TunnelsState>(
      listenWhen: (_, state) => state is Closed,
      listener: (_, _) => unawaited(
        ServicesBinding.instance.exitApplication(AppExitType.required),
      ),
      child: Scaffold(
        body: Column(
          children: [
            TunnelsHeader(
              title: switch ((_isFormOpen, _editing)) {
                (false, _) => 'Tunnels',
                (true, null) => 'New tunnel',
                (true, _?) => 'Edit tunnel',
              },
              isFormOpen: _isFormOpen,
              onPressed: _isFormOpen ? _closeForm : _openForm,
              onSettings: () =>
                  Navigator.pushNamed(context, TakaApp.settingsRoute),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, -0.01),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: _isFormOpen
                    ? TunnelForm(
                        key: ValueKey(_editing?.id ?? 'new ${_newKind.name}'),
                        initial: _editing,
                        kind: _newKind,
                        hosts: _hosts,
                        groups: switch (context.read<TunnelsBloc>().state) {
                          Ready(:final snapshot) => snapshot.tunnels.groups,
                          _ => const [],
                        },
                        onSave: (tunnel) {
                          context.read<TunnelsBloc>().add(
                            TunnelsEvent.send(AgentCommand.save(tunnel)),
                          );
                          _closeForm();
                        },
                        onCancel: _closeForm,
                      )
                    : _TunnelList(
                        key: const ValueKey('list'),
                        onEdit: _openForm,
                        onAdd: (kind) => _openForm(null, kind),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Read on every open, so edits to ~/.ssh/config show up.
  void _openForm([Tunnel? tunnel, TunnelKind kind = TunnelKind.local]) {
    setState(() {
      _isFormOpen = true;
      _editing = tunnel;
      _newKind = kind;
    });
    unawaited(
      configuredSshHosts().then((hosts) {
        if (mounted) setState(() => _hosts = hosts);
      }),
    );
  }

  void _closeForm() => setState(() => _isFormOpen = false);
}

class const _TunnelList({
  super.key,
  required final void Function(Tunnel tunnel) onEdit,
  required final void Function(TunnelKind kind) onAdd,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = TakaColors.of(context);

    return BlocBuilder<TunnelsBloc, TunnelsState>(
      builder: (context, state) => switch (state) {
        Loading() || Closed() => const SizedBox.shrink(),
        Ready(:final snapshot) when snapshot.tunnels.isEmpty => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              const Text(
                'No tunnels yet',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                'Add the SSH host, a local port, and where it leads.',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  FilledButton(
                    onPressed: () => onAdd(TunnelKind.local),
                    child: const Text('Add Tunnel'),
                  ),
                  TextButton(
                    onPressed: () => onAdd(TunnelKind.socks),
                    child: const Text('Add SOCKS Proxy'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Ready(:final snapshot) => _rows(context, snapshot),
      },
    );
  }

  Widget _rows(BuildContext context, TunnelsSnapshot snapshot) {
    final colors = TakaColors.of(context);
    final rows = snapshot.tunnels.rows;

    return ReorderableRows(
      spanOf: (index) => rows[index].span,
      settle: snapshot.tunnels.landingOf,
      onReorder: (from, to) => _send(
        context,
        AgentCommand.arrange([
          for (final tunnel in snapshot.tunnels.droppedAt(from, to))
            (id: tunnel.id, group: tunnel.group),
        ]),
      ),
      children: [
        for (final (index, row) in rows.indexed)
          switch (row) {
            GroupHeaderRow(:final group) => _GroupHeader(
              group,
              key: ValueKey('group $group'),
              onRename: (name) => _rename(context, snapshot, group, name),
            ),
            GroupEndRow(:final group) => SizedBox(
              key: ValueKey('end $group'),
              height: 12,
            ),
            TunnelRow(:final tunnel) => Column(
              key: ValueKey(tunnel.id),
              children: [
                // Lifted, it shows the group it would land in.
                Builder(
                  builder: (context) {
                    final landing = ReorderableRows.landingOf(context, index);
                    final group = landing == null
                        ? tunnel.group
                        : snapshot.tunnels
                              .droppedAt(index, landing)
                              .firstWhere((moved) => moved.id == tunnel.id)
                              .group;

                    return TunnelTile(
                      tunnel: tunnel,
                      status: snapshot.statusOf(tunnel.id),
                      isInGroup: group != null,
                      onToggle: () =>
                          _send(context, AgentCommand.toggle(tunnel.id)),
                      onTrust: (fingerprint) => _send(
                        context,
                        AgentCommand.trustHostKey(tunnel.id, fingerprint),
                      ),
                      onEdit: () => onEdit(tunnel),
                      onDelete: () =>
                          _send(context, AgentCommand.remove(tunnel.id)),
                    );
                  },
                ),
                if (rows.elementAtOrNull(index + 1)
                    case TunnelRow(tunnel: Tunnel(:final group))
                    when group == tunnel.group)
                  _InGroup(
                    isInGroup: tunnel.group != null,
                    child: Divider(
                      height: 1,
                      indent: 6,
                      endIndent: 6,
                      color: colors.background,
                    ),
                  ),
              ],
            ),
          },
      ],
    );
  }

  void _rename(
    BuildContext context,
    TunnelsSnapshot snapshot,
    String group,
    String name,
  ) {
    final renamed = groupNamed(name);
    if (renamed == null || renamed == group) return;

    _send(
      context,
      AgentCommand.arrange([
        for (final tunnel in snapshot.tunnels)
          (
            id: tunnel.id,
            group: tunnel.group == group ? renamed : tunnel.group,
          ),
      ]),
    );
  }

  void _send(BuildContext context, AgentCommand command) =>
      context.read<TunnelsBloc>().add(TunnelsEvent.send(command));
}

// The divider between two of a group's tunnels keeps its guide line.
class const _InGroup({
  required final bool isInGroup,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!isInGroup) return child;

    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: TakaColors.of(context).guide, width: 2),
          ),
        ),
        child: child,
      ),
    );
  }
}

class const _GroupHeader(
  final String group, {
  super.key,
  required final void Function(String name) onRename,
}) extends StatefulWidget {
  @override
  State<_GroupHeader> createState() => _GroupHeaderState();
}

class _GroupHeaderState extends State<_GroupHeader> {
  final _focus = FocusNode();
  TextEditingController? _editing;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) _finish(save: true);
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _editing?.dispose();
    super.dispose();
  }

  void _start() => setState(
    () => _editing = TextEditingController(text: widget.group)
      ..selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.group.length,
      ),
  );

  void _finish({required bool save}) {
    final editing = _editing;
    if (editing == null) return;

    setState(() => _editing = null);
    if (save) widget.onRename(editing.text);
    // The field still holds it until it's gone from the tree.
    WidgetsBinding.instance.addPostFrameCallback((_) => editing.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final colors = TakaColors.of(context);
    const style = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 2),
        child: switch (_editing) {
          final editing? => CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.escape): () =>
                  _finish(save: false),
            },
            child: TextField(
              controller: editing,
              focusNode: _focus,
              autofocus: true,
              style: style.copyWith(color: colors.text),
              decoration: const InputDecoration.collapsed(hintText: ''),
              onSubmitted: (_) => _finish(save: true),
            ),
          ),
          null => Tooltip(
            message: 'Rename',
            child: GestureDetector(
              onTap: _start,
              child: Text(
                widget.group,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style.copyWith(color: colors.textSecondary),
              ),
            ),
          ),
        },
      ),
    );
  }
}
