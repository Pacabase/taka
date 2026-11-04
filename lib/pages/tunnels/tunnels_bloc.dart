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

    on<Send>((event, emit) => agent.send(event.command));
  }
}
