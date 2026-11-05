import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent_settings.freezed.dart';

@freezed
sealed class const AgentSettings._() with _$AgentSettings {
  /// [launchesAtLogin] is null where the agent can't launch at login, such
  /// as a development build outside an app bundle.
  const factory({bool? launchesAtLogin, @Default(false) bool isLogging}) =
      _AgentSettings;

  static AgentSettings fromJson(Object? json) => switch (json) {
    {'debugLogging': final bool isLogging} &&
        final Map<Object?, Object?> fields =>
      AgentSettings(
        launchesAtLogin: switch (fields['launchAtLogin']) {
          final bool launches => launches,
          _ => null,
        },
        isLogging: isLogging,
      ),
    _ => throw FormatException('Not settings: $json'),
  };

  Map<String, Object?> toJson() => {
    'launchAtLogin': launchesAtLogin,
    'debugLogging': isLogging,
  };
}

abstract interface class AgentPreferences {
  AgentSettings get settings;

  Stream<AgentSettings> get changes;

  void setLaunchAtLogin({required bool on});

  void setDebugLogging({required bool on});

  Future<void> showLogs();
}
