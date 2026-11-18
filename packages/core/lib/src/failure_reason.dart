import 'package:core/src/tunnel.dart';
import 'package:core/src/tunnels_snapshot.dart';

/// [failed] in a few words for narrow places; an unknown failure stays as ssh
/// wrote it.
String failureShort(Tunnel tunnel, Failed failed) => switch (failed.failure) {
  TunnelFailure.sshNotFound => 'ssh not found',
  TunnelFailure.config => "SSH settings don't work",
  TunnelFailure.portInUse => 'port ${tunnel.localPort} in use',
  TunnelFailure.duplicateForward => 'port ${tunnel.remotePort} already open',
  TunnelFailure.addressUnavailable => 'address not on this computer',
  TunnelFailure.hostNotFound => 'server not found',
  TunnelFailure.unreachable => "can't reach the server",
  TunnelFailure.loginRefused => 'login refused',
  TunnelFailure.hostKey => 'host key changed',
  TunnelFailure.dropped => 'disconnected',
  TunnelFailure.remotePortRefused =>
    "server won't open port ${tunnel.remotePort}",
  TunnelFailure.forwardProhibited => "server won't forward",
  TunnelFailure.forwardRefused => switch (tunnel.remoteSocket) {
    final socket? => "can't open $socket",
    null => "can't reach ${tunnel.remoteHost}:${tunnel.remotePort}",
  },
  TunnelFailure.other => failed.message.trim(),
};

/// [failure] as a plain sentence, with none of ssh's own words.
String failureSentence(Tunnel tunnel, TunnelFailure failure) =>
    switch (failure) {
      TunnelFailure.sshNotFound => "Can't find ssh on this computer.",
      TunnelFailure.config => "The SSH settings for this server don't work.",
      TunnelFailure.portInUse => 'Port ${tunnel.localPort} is already in use.',
      TunnelFailure.duplicateForward =>
        'Another tunnel already opens port ${tunnel.remotePort} '
            'on the server.',
      TunnelFailure.addressUnavailable =>
        "This computer doesn't have the From address.",
      TunnelFailure.hostNotFound => "Can't find the server.",
      TunnelFailure.unreachable => "Can't reach the server.",
      TunnelFailure.loginRefused => 'The server refused the login.',
      TunnelFailure.hostKey => "The server's host key changed.",
      TunnelFailure.dropped => 'The connection dropped.',
      TunnelFailure.remotePortRefused =>
        "The server won't open port ${tunnel.remotePort}: it's taken there, "
            "or forwarding isn't allowed.",
      TunnelFailure.forwardProhibited =>
        "The server doesn't allow this tunnel.",
      TunnelFailure.forwardRefused => forwardWarning(tunnel),
      TunnelFailure.other => "It couldn't connect.",
    };

String forwardWarning(Tunnel tunnel) => switch (tunnel) {
  Tunnel(kind: TunnelKind.socks) =>
    "A site through the SOCKS proxy couldn't be reached.",
  Tunnel(kind: TunnelKind.remote, :final localHost, :final localPort) =>
    "Can't reach ${localHost ?? 'localhost'}:$localPort from this computer.",
  Tunnel(:final remoteSocket?) => "Can't open $remoteSocket on the server.",
  Tunnel(:final remoteHost, :final remotePort) =>
    "Can't reach $remoteHost:$remotePort through the server.",
};
