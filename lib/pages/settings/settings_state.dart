part of 'settings_bloc.dart';

@freezed
sealed class SettingsState with _$SettingsState {
  const factory loading() = SettingsLoading;

  const factory ready(AgentSettings settings) = SettingsReady;
}
