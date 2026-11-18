import 'dart:async';
import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taka/pages/tunnels/tunnels_bloc.dart';
import 'package:taka/pages/tunnels/tunnels_screen_cubit.dart';
import 'package:taka/pages/tunnels/widgets/group_form.dart';
import 'package:taka/pages/tunnels/widgets/reorderable_rows.dart';
import 'package:taka/pages/tunnels/widgets/tunnel_form.dart';
import 'package:taka/pages/tunnels/widgets/tunnel_tile.dart';
import 'package:taka/pages/tunnels/widgets/tunnels_header.dart';
import 'package:taka/taka_app.dart';
import 'package:taka/theme/taka_colors.dart';
import 'package:taka/widgets/app_icon.dart';
import 'package:taka/widgets/colour_dot.dart';
import 'package:taka/widgets/fill_or_scroll.dart';

class const TunnelsPage({
  super.key,
  final Stream<OpenTunnel> tunnelRequests = const Stream.empty(),
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => TunnelsScreenCubit(
      tunnels: context.read<TunnelsBloc>(),
      tunnelRequests: tunnelRequests,
    ),
    child: const _TunnelsView(),
  );
}

class const _TunnelsView() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screen = context.read<TunnelsScreenCubit>();
    final TunnelsScreenState(screen: shown, :hosts) = context
        .watch<TunnelsScreenCubit>()
        .state;
    final isOpen = shown is! ListScreen;

    void save(AgentCommand command) {
      context.read<TunnelsBloc>().add(TunnelsEvent.send(command));
      screen.closeForm();
    }

    Widget tunnelForm({
      required Key key,
      Tunnel? initial,
      TunnelKind kind = TunnelKind.local,
    }) => TunnelForm(
      key: key,
      initial: initial,
      kind: kind,
      hosts: hosts,
      groups: context.select(
        (TunnelsBloc bloc) => switch (bloc.state) {
          Ready(:final snapshot) => snapshot.tunnels.groups,
          _ => const <String>[],
        },
      ),
      groupColours: context.select(
        (TunnelsBloc bloc) => switch (bloc.state) {
          Ready(:final snapshot) => snapshot.groupColours,
          _ => const <String, TunnelColour>{},
        },
      ),
      onSave: (tunnel) => save(AgentCommand.save(tunnel)),
      onCancel: screen.closeForm,
    );

    return MultiBlocListener(
      listeners: [
        BlocListener<TunnelsBloc, TunnelsState>(
          listenWhen: (_, state) => state is Closed,
          listener: (_, _) => unawaited(
            ServicesBinding.instance.exitApplication(AppExitType.required),
          ),
        ),
        BlocListener<TunnelsScreenCubit, TunnelsScreenState>(
          listenWhen: (previous, state) => previous.requests != state.requests,
          listener: (context, _) =>
              Navigator.popUntil(context, (route) => route.isFirst),
        ),
      ],
      child: Scaffold(
        body: Column(
          children: [
            TunnelsHeader(
              title: switch (shown) {
                ListScreen() => 'Tunnels',
                NewTunnelScreen() => 'New tunnel',
                EditTunnelScreen() => 'Edit tunnel',
                EditGroupScreen() => 'Edit group',
              },
              isFormOpen: isOpen,
              onPressed: isOpen ? screen.closeForm : screen.openTunnel,
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
                child: switch (shown) {
                  ListScreen() => _TunnelList(
                    key: const ValueKey('list'),
                    onEdit: screen.openTunnel,
                    onEditGroup: screen.editGroup,
                    onAdd: (kind) => screen.openTunnel(null, kind),
                  ),
                  NewTunnelScreen(:final kind) => tunnelForm(
                    key: ValueKey('new ${kind.name}'),
                    kind: kind,
                  ),
                  EditTunnelScreen(:final tunnel) => tunnelForm(
                    key: ValueKey(tunnel.id),
                    initial: tunnel,
                  ),
                  EditGroupScreen(:final group, :final colour) => GroupForm(
                    key: ValueKey('group $group'),
                    group: group,
                    colour: colour,
                    onSave: (name, colour) => save(
                      AgentCommand.editGroup(group, name: name, colour: colour),
                    ),
                    onCancel: screen.closeForm,
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class const _TunnelList({
  super.key,
  required final void Function(Tunnel tunnel) onEdit,
  required final void Function(String group, TunnelColour? colour) onEditGroup,
  required final void Function(TunnelKind kind) onAdd,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = TakaColors.of(context);

    return BlocBuilder<TunnelsBloc, TunnelsState>(
      builder: (context, state) => switch (state) {
        Loading() || Closed() => const SizedBox.shrink(),
        Ready(:final snapshot) when snapshot.tunnels.isEmpty => FillOrScroll(
          child: Center(
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
              colour: snapshot.groupColours[group],
              onEdit: () => onEditGroup(group, snapshot.groupColours[group]),
            ),
            GroupEndRow(:final group) => SizedBox(
              key: ValueKey('end $group'),
              height: 12,
            ),
            TunnelRow(:final tunnel) => Builder(
              key: ValueKey(tunnel.id),
              builder: (context) {
                // Lifted, it shows the group it would land in.
                final dropAt = ReorderableRows.dropIndexOf(context, index);
                final group = switch (dropAt) {
                  final to? => snapshot.tunnels.groupOnDrop(index, to),
                  null => tunnel.group,
                };
                final groupColour = snapshot.groupColours[group];
                final guide = group == null
                    ? null
                    : (
                        colour: colors.guideOf(groupColour),
                        // A lifted one is between places, so neither end.
                        isFirst:
                            dropAt == null &&
                            rows.elementAtOrNull(index - 1) is GroupHeaderRow,
                        isLast:
                            dropAt == null &&
                            rows.elementAtOrNull(index + 1) is GroupEndRow,
                      );

                return Column(
                  children: [
                    TunnelTile(
                      tunnel: tunnel,
                      status: snapshot.statusOf(tunnel.id),
                      colour: groupColour == null ? tunnel.colour : null,
                      guide: guide,
                      onToggle: () =>
                          _send(context, AgentCommand.toggle(tunnel.id)),
                      onTrust: (fingerprint) => _send(
                        context,
                        AgentCommand.trustHostKey(tunnel.id, fingerprint),
                      ),
                      onEdit: () => onEdit(tunnel),
                      onDelete: () =>
                          _send(context, AgentCommand.remove(tunnel.id)),
                    ),
                    if (rows.elementAtOrNull(index + 1)
                        case TunnelRow(tunnel: Tunnel(group: final next))
                        when next == tunnel.group)
                      _InGroup(
                        guide: guide?.colour,
                        child: Divider(
                          height: 1,
                          indent: 6,
                          endIndent: 6,
                          color: colors.selection,
                        ),
                      ),
                  ],
                );
              },
            ),
          },
      ],
    );
  }

  void _send(BuildContext context, AgentCommand command) =>
      context.read<TunnelsBloc>().add(TunnelsEvent.send(command));
}

class const _InGroup({required final Color? guide, required final Widget child})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final guide = this.guide;
    if (guide == null) return child;

    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: guide, width: 2)),
        ),
        child: child,
      ),
    );
  }
}

class const _GroupHeader(
  final String group, {
  super.key,
  required final TunnelColour? colour,
  required final void Function() onEdit,
}) extends StatefulWidget {
  @override
  State<_GroupHeader> createState() => _GroupHeaderState();
}

class _GroupHeaderState extends State<_GroupHeader> {
  var _hovered = false;
  var _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = TakaColors.of(context);

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (focused) => setState(() => _focused = focused),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Padding(
          // The dot's 20px box centres it on the guide line below.
          padding: const EdgeInsets.fromLTRB(5, 12, 6, 2),
          child: Row(
            spacing: 2,
            children: [
              SizedBox.square(
                dimension: 20,
                child: Center(
                  child: switch (widget.colour) {
                    final colour? => ColourDot(colour),
                    null => null,
                  },
                ),
              ),
              Expanded(
                child: Text(
                  widget.group,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              // Kept in place, so the header doesn't grow on hover.
              Visibility.maintain(
                visible: _hovered || _focused,
                child: IconButton(
                  tooltip: 'Edit ${widget.group}',
                  onPressed: widget.onEdit,
                  constraints: const BoxConstraints.tightFor(
                    width: 24,
                    height: 20,
                  ),
                  padding: EdgeInsets.zero,
                  icon: AppIcon(AppIcons.pencil, color: colors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
