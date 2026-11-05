part of 'settings_bloc.dart';

@freezed
sealed class SettingsEvent with _$SettingsEvent {
  const factory started() = SettingsStarted;

  const factory send(AgentCommand command) = SendSetting;
}
