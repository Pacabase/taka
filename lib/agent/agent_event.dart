part of 'agent_bloc.dart';

@freezed
sealed class AgentEvent with _$AgentEvent {
  /// Starts the helper if it isn't running, and connects to it.
  const factory connect() = ConnectAgent;
}
