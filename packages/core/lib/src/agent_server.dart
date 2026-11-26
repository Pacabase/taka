import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/src/agent_channel.dart';
import 'package:core/src/agent_command.dart';
import 'package:core/src/agent_message.dart';
import 'package:core/src/agent_settings.dart';
import 'package:core/src/login_prompt.dart';
import 'package:core/src/tunnel.dart';
import 'package:core/src/tunnel_manager.dart';
import 'package:core/src/tunnels_file.dart';
import 'package:core/src/tunnels_snapshot.dart';
import 'package:fimber/fimber.dart';
import 'package:system_ssh/system_ssh.dart';

final _log = FimberLog('Socket');

class AgentServer(
  final AgentListener _listener,
  final TunnelManager _manager,
  final AgentPreferences _preferences,
  final String _identity, {

  /// Runs when the last window closes before it got every waiting prompt,
  /// to bring one back for them.
  final void Function()? onUnseenPrompts,
}) {
  final Set<AgentLink> _clients = {};
  AgentMessage? _pending;
  final Map<int, ({LoginPrompt prompt, Completer<String?> answer})> _prompts =
      {};
  var _lastPrompt = 0;
  final Set<int> _seen = {};
  bool _isClosed = false;
  late final StreamSubscription<TunnelsSnapshot> _changes;
  late final StreamSubscription<AgentSettings> _settingsChanges;

  this {
    _changes = _manager.stream.listen(
      (snapshot) => _sendAll(AgentMessage.snapshot(snapshot)),
    );
    _settingsChanges = _preferences.changes.listen(
      (settings) => _sendAll(AgentMessage.settings(settings)),
    );
    _listener.links.listen(_accept);
  }

  static Future<AgentServer?> bind(
    AgentChannel channel,
    TunnelManager manager,
    AgentPreferences preferences, {
    String identity = '',
    void Function()? onUnseenPrompts,
  }) async {
    final listener = await channel.listen();
    return listener == null
        ? null
        : AgentServer(
            listener,
            manager,
            preferences,
            identity,
            onUnseenPrompts: onUnseenPrompts,
          );
  }

  bool show(AgentMessage request) {
    if (_clients.isEmpty) {
      _pending = request;
      return false;
    }

    _sendAll(request);
    return true;
  }

  /// Asks the windows [prompt] for [tunnel], until one answers, the last one
  /// that saw it closes, or ssh withdraws it; null cancels.
  Future<String?> ask(Tunnel tunnel, SshPrompt prompt) {
    if (_isClosed) return Future.value();

    final id = ++_lastPrompt;
    final answer = Completer<String?>();
    _prompts[id] = (
      prompt: LoginPrompt(id: id, tunnelId: tunnel.id, prompt: prompt),
      answer: answer,
    );
    _sendPrompts();
    unawaited(prompt.withdrawn.whenComplete(() => _settle(id, null)));
    return answer.future;
  }

  void _settle(int id, String? answer) {
    _seen.remove(id);
    final waiting = _prompts.remove(id);
    if (waiting == null) return;
    waiting.answer.complete(answer);
    _sendPrompts();
  }

  void _cancel(Iterable<int> ids) {
    for (final id in [...ids]) {
      _settle(id, null);
    }
  }

  void _sendPrompts() => _sendAll(_promptsMessage);

  AgentMessage get _promptsMessage => AgentMessage.prompts([
    for (final waiting in _prompts.values) waiting.prompt,
  ]);

  void _accept(AgentLink client) {
    _admit(client);
    client.lines.listen(
      (line) => unawaited(_handle(line)),
      onDone: () => _drop(client),
      onError: (Object _) => _drop(client),
      cancelOnError: true,
    );
  }

  void _admit(AgentLink client) {
    _clients.add(client);
    _send(client, AgentMessage.identity(_identity));
    _send(client, AgentMessage.snapshot(_manager.state));
    _send(client, AgentMessage.settings(_preferences.settings));
    if (_prompts.isNotEmpty) _send(client, _promptsMessage);
    if (_pending case final request?) {
      _pending = null;
      _send(client, request);
    }
  }

  Future<void> _handle(String line) async {
    final Object? json;
    final AgentCommand command;
    try {
      json = jsonDecode(line);
    } on FormatException {
      _log.w("Ignoring a line that isn't JSON");
      return;
    }
    // Any parse error, since one left uncaught would end the agent.
    try {
      command = AgentCommand.fromJson(json);
    } on Object {
      // Only its name: the rest may hold an answer.
      final name = switch (json) {
        {'command': final String name} => name,
        _ => 'nameless',
      };
      _log.w("Ignoring a $name command that isn't valid");
      return;
    }

    try {
      await _run(command);
    } on Object catch (exception) {
      _log.e('Could not run $command', ex: exception);
    }
  }

  Future<void> _run(AgentCommand command) async => switch (command) {
    SaveTunnel(:final tunnel) => await _manager.save(tunnel),
    RemoveTunnel(:final id) => await _manager.remove(id),
    ToggleTunnel(:final id) => await _manager.toggle(id),
    ArrangeTunnels(:final tunnels) => await _manager.arrange(tunnels),
    TrustHostKey(:final id, :final fingerprint) => await _manager.trustHostKey(
      id,
      fingerprint,
    ),
    EditGroup(:final group, :final name, :final colour) =>
      await _manager.editGroup(group, name: name, colour: colour),
    ImportTunnels(:final tunnels, :final groupColours) => await _manager.import(
      tunnels,
      groupColours: groupColours,
    ),
    ExportTunnels(:final path) => await File(
      path,
    ).writeAsString(encodeTunnels(_manager.book)),
    QuitAgent() => await _manager.close(),
    SetLaunchAtLogin(:final on) => _preferences.setLaunchAtLogin(on: on),
    SetDebugLogging(:final on) => _preferences.setDebugLogging(on: on),
    ShowLogs() => await _preferences.showLogs(),
    AnswerPrompt(:final prompt, :final answer) => _settle(prompt, answer),
    SawPrompts(:final prompts) => _seen.addAll(
      prompts.where(_prompts.containsKey),
    ),
  };

  void _sendAll(AgentMessage message) {
    for (final client in _clients) {
      _send(client, message);
    }
  }

  void _send(AgentLink client, AgentMessage message) =>
      client.send(jsonEncode(message.toJson()));

  // With no window left, a prompt the window had is given up; one it never
  // got, such as one sent as it closed, waits for the next window.
  void _drop(AgentLink client) {
    _clients.remove(client);
    client.close();
    if (_clients.isNotEmpty || _isClosed) return;
    _cancel(_seen);
    if (_prompts.isNotEmpty) onUnseenPrompts?.call();
  }

  Future<void> close() async {
    if (_isClosed) return;
    _isClosed = true;
    await _changes.cancel();
    await _settingsChanges.cancel();
    [..._clients].forEach(_drop);
    _cancel(_prompts.keys);
    await _listener.close();
  }
}
