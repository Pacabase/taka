import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taka/pages/tunnels/tunnels_bloc.dart';
import 'package:taka/pages/tunnels/widgets/tunnel_form.dart';
import 'package:taka/pages/tunnels/widgets/tunnel_tile.dart';

class const TunnelsPage({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Taka')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add tunnel',
        onPressed: () => _edit(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<TunnelsBloc, TunnelsState>(
        builder: (context, state) => switch (state) {
          Loading() => const Center(child: CircularProgressIndicator()),
          Closed() => const Center(child: Text('Taka quit.')),
          Ready(:final snapshot) when snapshot.tunnels.isEmpty => const Center(
            child: Text('No tunnels yet. Add one with +.'),
          ),
          Ready(:final snapshot) => ListView(
            children: [
              for (final tunnel in snapshot.tunnels)
                TunnelTile(
                  tunnel: tunnel,
                  status: snapshot.statusOf(tunnel.id),
                  onToggle: () => context.read<TunnelsBloc>().add(
                    TunnelsEvent.toggle(tunnel.id),
                  ),
                  onEdit: () => _edit(context, tunnel),
                  onDelete: () => context.read<TunnelsBloc>().add(
                    TunnelsEvent.remove(tunnel.id),
                  ),
                ),
            ],
          ),
        },
      ),
    );
  }

  Future<void> _edit(BuildContext context, [Tunnel? tunnel]) async {
    final bloc = context.read<TunnelsBloc>();
    final saved = await showDialog<Tunnel>(
      context: context,
      builder: (context) => TunnelForm(initial: tunnel),
    );
    if (saved != null) bloc.add(TunnelsEvent.save(saved));
  }
}
