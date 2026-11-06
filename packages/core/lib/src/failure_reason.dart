import 'package:core/src/tunnel.dart';

final _portInUse = RegExp(r':(\d+) is already in use');

const _reasons = [
  (
    patterns: ['Could not resolve hostname'],
    short: 'server not found',
    sentence: "Can't find the server.",
  ),
  (
    patterns: ['Permission denied ('],
    short: 'login refused',
    sentence: 'The server refused the login.',
  ),
  (
    patterns: [
      'Host key verification failed',
      'REMOTE HOST IDENTIFICATION HAS CHANGED',
    ],
    short: 'host key changed',
    sentence: "The server's host key changed.",
  ),
  (
    patterns: ['not responding'],
    short: 'server stopped answering',
    sentence: 'The server stopped answering.',
  ),
  (
    patterns: ['Connection refused', 'timed out', 'No route to host'],
    short: "can't reach the server",
    sentence: "Can't reach the server.",
  ),
  (
    patterns: [
      'closed by remote host',
      'Connection reset',
      'Broken pipe',
      'Disconnected',
    ],
    short: 'disconnected',
    sentence: 'The connection dropped.',
  ),
];

({String short, String sentence})? _reasonOf(String message) {
  if (_portInUse.firstMatch(message)?[1] case final port?) {
    return (
      short: 'port $port in use',
      sentence: 'Port $port is already in use.',
    );
  }

  return _reasons
      .where((reason) => reason.patterns.any(message.contains))
      .map((reason) => (short: reason.short, sentence: reason.sentence))
      .firstOrNull;
}

/// A few words for why a tunnel failed, from ssh's own [message], for places
/// too narrow for all of it; anything unknown comes back as it is.
String shortReason(String message) =>
    _reasonOf(message)?.short ?? message.trim();

/// A plain sentence for why a tunnel failed, from ssh's own [message], with
/// no ssh or exception text in it.
String plainReason(String message) =>
    _reasonOf(message)?.sentence ?? "It couldn't connect.";

/// What a connected [tunnel] couldn't forward when ssh reports a destination
/// it couldn't open.
String forwardWarning(Tunnel tunnel) => switch (tunnel) {
  Tunnel(kind: TunnelKind.socks) =>
    "A site through the SOCKS proxy couldn't be reached.",
  Tunnel(:final remoteHost, :final remotePort) =>
    "Can't reach $remoteHost:$remotePort through the server.",
};
