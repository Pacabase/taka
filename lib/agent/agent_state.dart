part of 'agent_bloc.dart';

@freezed
sealed class AgentState with _$AgentState {
  const factory connecting() = AgentConnecting;

  const factory failed(Object error) = AgentFailed;

  const factory connected(AgentClient agent) = AgentConnected;
}
