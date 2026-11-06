part of 'settings_bloc.dart';

@freezed
sealed class SettingsEvent with _$SettingsEvent {
  const factory started() = Started;

  const factory send(AgentCommand command) = Send;
}
