import 'package:core/src/tunnel.dart';
import 'package:core/src/tunnel_colour.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent_command.freezed.dart';

@freezed
sealed class const AgentCommand._() with _$AgentCommand {
  const factory save(Tunnel tunnel) = SaveTunnel;

  const factory remove(String id) = RemoveTunnel;

  const factory toggle(String id) = ToggleTunnel;

  const factory arrange(List<({String id, String? group})> tunnels) =
      ArrangeTunnels;

  const factory trustHostKey(String id, String fingerprint) = TrustHostKey;

  /// [name] renames [group], to the spelling of a group in use like it;
  /// [colour] null takes its colour away.
  const factory editGroup(
    String group, {
    required String name,
    required TunnelColour? colour,
  }) = EditGroup;

  const factory importTunnels(
    List<Tunnel> tunnels, {
    @Default({}) Map<String, TunnelColour> groupColours,
  }) = ImportTunnels;

  const factory exportTunnels(String path) = ExportTunnels;

  const factory quit() = QuitAgent;

  const factory setLaunchAtLogin({required bool on}) = SetLaunchAtLogin;

  const factory setDebugLogging({required bool on}) = SetDebugLogging;

  const factory showLogs() = ShowLogs;

  /// Answers login prompt [prompt]; a null [answer] cancels the login.
  const factory answer(int prompt, String? answer) = AnswerPrompt;

  /// The window has [prompts], so closing it gives them up.
  const factory sawPrompts(List<int> prompts) = SawPrompts;

  // Freezed's would print the answer.
  @override
  String toString() => switch (this) {
    AnswerPrompt(:final prompt) => 'AgentCommand.answer($prompt)',
    _ => 'AgentCommand.${toJson()['command']}',
  };

  static AgentCommand fromJson(Object? json) => switch (json) {
    {'command': 'save', 'tunnel': final tunnel} => SaveTunnel(
      Tunnel.fromJson(tunnel),
    ),
    {'command': 'remove', 'id': final String id} => RemoveTunnel(id),
    {'command': 'toggle', 'id': final String id} => ToggleTunnel(id),
    {'command': 'arrange', 'tunnels': final List<Object?> tunnels} =>
      ArrangeTunnels([
        for (final tunnel in tunnels)
          switch (tunnel) {
            {'id': final String id} && final Map<Object?, Object?> fields => (
              id: id,
              group: switch (fields['group']) {
                final String group => groupNamed(group),
                _ => null,
              },
            ),
            _ => throw FormatException('Not a tunnel to arrange: $tunnel'),
          },
      ]),
    {
      'command': 'trustHostKey',
      'id': final String id,
      'fingerprint': final String fingerprint,
    } =>
      TrustHostKey(id, fingerprint),
    {
          'command': 'editGroup',
          'group': final String group,
          'name': final String name,
        } &&
        final Map<Object?, Object?> fields =>
      EditGroup(
        group,
        name: name,
        colour: TunnelColour.fromName(fields['colour']),
      ),
    {'command': 'import', 'tunnels': final List<Object?> tunnels} &&
        final Map<Object?, Object?> fields =>
      ImportTunnels(
        tunnels.map(Tunnel.fromJson).toList(),
        groupColours: groupColoursFromJson(fields['groupColours']),
      ),
    {'command': 'export', 'path': final String path} => ExportTunnels(path),
    {'command': 'quit'} => const QuitAgent(),
    {'command': 'launchAtLogin', 'on': final bool on} => SetLaunchAtLogin(
      on: on,
    ),
    {'command': 'debugLogging', 'on': final bool on} => SetDebugLogging(on: on),
    {'command': 'showLogs'} => const ShowLogs(),
    {'command': 'answer', 'prompt': final int prompt} &&
        final Map<Object?, Object?> fields =>
      AnswerPrompt(prompt, switch (fields['answer']) {
        final String answer => answer,
        _ => null,
      }),
    {'command': 'sawPrompts', 'prompts': final List<Object?> prompts}
        when prompts.every((prompt) => prompt is int) =>
      SawPrompts(prompts.cast<int>()),
    _ => throw FormatException('Not a command: $json'),
  };

  Map<String, Object?> toJson() => switch (this) {
    SaveTunnel(:final tunnel) => {'command': 'save', 'tunnel': tunnel.toJson()},
    RemoveTunnel(:final id) => {'command': 'remove', 'id': id},
    ToggleTunnel(:final id) => {'command': 'toggle', 'id': id},
    ArrangeTunnels(:final tunnels) => {
      'command': 'arrange',
      'tunnels': [
        for (final (:id, :group) in tunnels) {'id': id, 'group': ?group},
      ],
    },
    TrustHostKey(:final id, :final fingerprint) => {
      'command': 'trustHostKey',
      'id': id,
      'fingerprint': fingerprint,
    },
    EditGroup(:final group, :final name, :final colour) => {
      'command': 'editGroup',
      'group': group,
      'name': name,
      'colour': ?colour?.name,
    },
    ImportTunnels(:final tunnels, :final groupColours) => {
      'command': 'import',
      'tunnels': tunnels.map((tunnel) => tunnel.toJson()).toList(),
      if (groupColours.isNotEmpty)
        'groupColours': groupColoursToJson(groupColours),
    },
    ExportTunnels(:final path) => {'command': 'export', 'path': path},
    QuitAgent() => {'command': 'quit'},
    SetLaunchAtLogin(:final on) => {'command': 'launchAtLogin', 'on': on},
    SetDebugLogging(:final on) => {'command': 'debugLogging', 'on': on},
    ShowLogs() => {'command': 'showLogs'},
    AnswerPrompt(:final prompt, :final answer) => {
      'command': 'answer',
      'prompt': prompt,
      'answer': ?answer,
    },
    SawPrompts(:final prompts) => {'command': 'sawPrompts', 'prompts': prompts},
  };
}
