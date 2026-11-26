import 'package:core/src/tunnel.dart';
import 'package:core/src/tunnels_snapshot.dart';

/// [failed] in a few words for narrow places; an unknown failure stays as ssh
/// wrote it.
String failureShort(Tunnel tunnel, Failed failed) => switch (failed.failure) {
  TunnelFailure.sshNotFound => 'ssh not found',
  TunnelFailure.config => "SSH settings don't work",
  TunnelFailure.portInUse => 'port ${tunnel.forward.localPort} in use',
  TunnelFailure.duplicateForward => '${_serverPort(tunnel)} already open',
  TunnelFailure.addressUnavailable => 'address not on this computer',
  TunnelFailure.hostNotFound => 'server not found',
  TunnelFailure.unreachable => "can't reach the server",
  TunnelFailure.loginRefused => 'login refused',
  TunnelFailure.promptsOff => "login refused, can't ask",
  TunnelFailure.hostKey => 'host key changed',
  TunnelFailure.dropped => 'disconnected',
  TunnelFailure.remotePortRefused => "server won't open ${_serverPort(tunnel)}",
  TunnelFailure.forwardProhibited => "server won't forward",
  TunnelFailure.forwardRefused => switch (tunnel.forward) {
    LocalForward(:final remoteHost, :final remotePort) =>
      "can't reach $remoteHost:$remotePort",
    SocketForward(:final remoteSocket) => "can't open $remoteSocket",
    SocksProxy() => "can't reach a site",
    RemoteForward(:final localHost, :final localPort) =>
      "can't reach $localHost:$localPort",
  },
  TunnelFailure.other => failed.message.trim(),
};

/// [failure] as a plain sentence, with none of ssh's own words.
String failureSentence(Tunnel tunnel, TunnelFailure failure) =>
    switch (failure) {
      TunnelFailure.sshNotFound => "Can't find ssh on this computer.",
      TunnelFailure.config => "The SSH settings for this server don't work.",
      TunnelFailure.portInUse =>
        'Port ${tunnel.forward.localPort} is already in use.',
      TunnelFailure.duplicateForward =>
        'Another tunnel already opens ${_serverPort(tunnel)} on the server.',
      TunnelFailure.addressUnavailable =>
        "This computer doesn't have the From address.",
      TunnelFailure.hostNotFound => "Can't find the server.",
      TunnelFailure.unreachable => "Can't reach the server.",
      TunnelFailure.loginRefused => 'The server refused the login.',
      TunnelFailure.promptsOff =>
        "The server refused the login, and Taka can't ask for a password "
            'on this computer.',
      TunnelFailure.hostKey => "The server's host key changed.",
      TunnelFailure.dropped => 'The connection dropped.',
      TunnelFailure.remotePortRefused =>
        "The server won't open ${_serverPort(tunnel)}: it's taken there, "
            "or forwarding isn't allowed.",
      TunnelFailure.forwardProhibited =>
        "The server doesn't allow this tunnel.",
      TunnelFailure.forwardRefused => forwardWarning(tunnel),
      TunnelFailure.other => "It couldn't connect.",
    };

String forwardWarning(Tunnel tunnel) => switch (tunnel.forward) {
  LocalForward(:final remoteHost, :final remotePort) =>
    "Can't reach $remoteHost:$remotePort through the server.",
  SocketForward(:final remoteSocket) =>
    "Can't open $remoteSocket on the server.",
  SocksProxy() => "A site through the SOCKS proxy couldn't be reached.",
  RemoteForward(:final localHost, :final localPort) =>
    "Can't reach $localHost:$localPort from this computer.",
};

// Only a remote tunnel has the server listen.
String _serverPort(Tunnel tunnel) => switch (tunnel.forward) {
  RemoteForward(:final remotePort) => 'port $remotePort',
  LocalForward() || SocketForward() || SocksProxy() => 'the port',
};
