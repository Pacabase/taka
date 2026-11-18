import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:fimber/fimber.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:taka/pages/settings/settings_bloc.dart';

part 'agent_bloc.freezed.dart';
part 'agent_event.dart';
part 'agent_state.dart';

class AgentBloc({required Future<AgentClient> Function() connect})
    extends Bloc<AgentEvent, AgentState> {
  @override
  String toString() => 'AgentBloc';

  this : super(const AgentConnecting()) {
    on<ConnectAgent>((event, emit) async {
      if (state is AgentConnected) return;

      if (state is! AgentConnecting) emit(const AgentConnecting());
      try {
        final agent = await connect();
        emit(
          AgentConnected(
            agent,
            SettingsBloc(agent: agent)..add(const SettingsEvent.started()),
          ),
        );
      } catch (exception) {
        Fimber.e("Taka's background helper didn't start", ex: exception);
        emit(AgentFailed(exception));
      }
    });
  }

  @override
  Future<void> close() async {
    if (state case AgentConnected(:final agent, :final settings)) {
      await settings.close();
      // A stream nobody listens to never finishes closing.
      unawaited(agent.close());
    }
    return super.close();
  }
}
