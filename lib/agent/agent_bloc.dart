import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:fimber/fimber.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent_bloc.freezed.dart';
part 'agent_event.dart';
part 'agent_state.dart';

class AgentBloc({required Future<AgentClient> Function() connect})
    extends Bloc<AgentEvent, AgentState> {
  @override
  String toString() => 'AgentBloc';

  this : super(const AgentConnecting()) {
    // One at a time: Try Again tapped twice would start a second link.
    on<ConnectAgent>((event, emit) async {
      if (state is AgentConnected) return;

      if (state is! AgentConnecting) emit(const AgentConnecting());
      try {
        final agent = await connect();
        if (isClosed) return unawaited(agent.close());

        emit(AgentConnected(agent));
      } catch (exception) {
        Fimber.e("Taka's background helper didn't start", ex: exception);
        emit(AgentFailed(exception));
      }
    }, transformer: (events, handle) => events.asyncExpand(handle));
  }

  @override
  Future<void> close() async {
    if (state case AgentConnected(:final agent)) await agent.close();
    return super.close();
  }
}
