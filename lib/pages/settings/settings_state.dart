part of 'settings_bloc.dart';

@freezed
sealed class SettingsState with _$SettingsState {
  const factory loading() = Loading;

  const factory ready(AgentSettings settings) = Ready;
}
