part of 'tunnels_bloc.dart';

@freezed
sealed class TunnelsEvent with _$TunnelsEvent {
  const factory started() = Started;

  const factory send(AgentCommand command) = Send;
}
