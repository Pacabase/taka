import 'package:core/src/tunnel.dart';

final _portInUse = RegExp(r':(\d+) is already in use');
final _remotePortRefused = RegExp(
  r'remote port forwarding failed for listen port (\d+)',
);

const _reasons = [
  (
    // ssh's line for a forwarded connection the server couldn't make.
    patterns: [': open failed: '],
    short: "can't reach where it leads",
    sentence: "The server can't reach where this tunnel leads.",
  ),
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
      'has changed; it now offers',
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

  if (_remotePortRefused.firstMatch(message)?[1] case final port?) {
    return (
      short: "server won't open port $port",
      sentence:
          "The server won't open port $port: it's taken there, "
          "or forwarding isn't allowed.",
    );
  }

  return _reasons
      .where((reason) => reason.patterns.any(message.contains))
      .map((reason) => (short: reason.short, sentence: reason.sentence))
      .firstOrNull;
}

/// ssh's [message] in a few words for narrow places; unknown ones stay as is.
String shortReason(String message) =>
    _reasonOf(message)?.short ?? message.trim();

/// ssh's [message] as a plain sentence, with none of ssh's own words.
String plainReason(String message) =>
    _reasonOf(message)?.sentence ?? "It couldn't connect.";

String forwardWarning(Tunnel tunnel) => switch (tunnel) {
  Tunnel(kind: TunnelKind.socks) =>
    "A site through the SOCKS proxy couldn't be reached.",
  Tunnel(kind: TunnelKind.remote, :final localHost, :final localPort) =>
    "Can't reach ${localHost ?? 'localhost'}:$localPort from this computer.",
  Tunnel(:final remoteSocket?) => "Can't open $remoteSocket on the server.",
  Tunnel(:final remoteHost, :final remotePort) =>
    "Can't reach $remoteHost:$remotePort through the server.",
};
