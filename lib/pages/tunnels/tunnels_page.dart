import 'dart:async';
import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taka/pages/tunnels/tunnels_bloc.dart';
import 'package:taka/pages/tunnels/widgets/tunnel_form.dart';
import 'package:taka/pages/tunnels/widgets/tunnel_tile.dart';
import 'package:taka/pages/tunnels/widgets/tunnels_header.dart';
import 'package:taka/theme/taka_colors.dart';

class const TunnelsPage({super.key}) extends StatefulWidget {
  @override
  State<TunnelsPage> createState() => _TunnelsPageState();
}

class _TunnelsPageState extends State<TunnelsPage> {
  var _isFormOpen = false;
  Tunnel? _editing;
  var _hosts = const <String>[];

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
                        key: ValueKey(_editing?.id ?? 'new'),
                        initial: _editing,
                        hosts: _hosts,
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
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Read on every open, so edits to ~/.ssh/config show up.
  void _openForm([Tunnel? tunnel]) {
    setState(() {
      _isFormOpen = true;
      _editing = tunnel;
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
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = TakaColors.of(context);

    return BlocBuilder<TunnelsBloc, TunnelsState>(
      builder: (context, state) => switch (state) {
        Loading() || Closed() => const SizedBox.shrink(),
        Ready(:final snapshot) when snapshot.tunnels.isEmpty => Center(
          child: Text(
            'No tunnels yet. Add one with +.',
            style: TextStyle(color: colors.textSecondary),
          ),
        ),
        Ready(:final snapshot) => ListView.separated(
          itemCount: snapshot.tunnels.length,
          separatorBuilder: (context, _) => Divider(
            height: 1,
            indent: 6,
            endIndent: 6,
            color: colors.background,
          ),
          itemBuilder: (context, index) {
            final tunnel = snapshot.tunnels[index];
            void send(AgentCommand command) =>
                context.read<TunnelsBloc>().add(TunnelsEvent.send(command));

            return TunnelTile(
              key: ValueKey(tunnel.id),
              tunnel: tunnel,
              status: snapshot.statusOf(tunnel.id),
              onToggle: () => send(AgentCommand.toggle(tunnel.id)),
              onEdit: () => onEdit(tunnel),
              onDelete: () => send(AgentCommand.remove(tunnel.id)),
            );
          },
        ),
      },
    );
  }
}
