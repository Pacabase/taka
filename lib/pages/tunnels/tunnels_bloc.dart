import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tunnels_bloc.freezed.dart';
part 'tunnels_event.dart';
part 'tunnels_state.dart';

class TunnelsBloc({required AgentClient agent})
    extends Bloc<TunnelsEvent, TunnelsState> {
  @override
  String toString() => 'TunnelsBloc';

  this : super(const Loading()) {
    on<Started>((event, emit) async {
      await emit.forEach(agent.snapshots, onData: Ready.new);
      emit(const Closed());
    });

    // A dropped row stays put instead of jumping back until the agent replies.
    on<Send>((event, emit) {
      if (state case Ready(:final snapshot)) {
        final tunnels = switch (event.command) {
          MoveTunnel(:final id, :final index) => snapshot.tunnels.moved(
            id,
            index,
          ),
          ArrangeTunnels(:final tunnels) => snapshot.tunnels.arranged(tunnels),
          _ => null,
        };
        if (tunnels != null) emit(Ready(snapshot.copyWith(tunnels: tunnels)));
      }
      agent.send(event.command);
    });
  }
}
