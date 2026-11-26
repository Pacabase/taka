import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:system_ssh/system_ssh.dart';

part 'tunnel_forward.freezed.dart';

/// Which of the form's tabs a tunnel is on: a socket forward is a local one.
enum TunnelKind { local, socks, remote }

/// Whether [address] is an IPv4 or IPv6 address, rather than a name.
bool isIpAddress(String address) {
  try {
    address.contains(':')
        ? Uri.parseIPv6Address(address)
        : Uri.parseIPv4Address(address);
    return true;
  } on FormatException {
    return false;
  }
}

/// [typed] as a tunnel keeps it: null for the default 127.0.0.1, 0.0.0.0 for
/// ssh's `*`, and an IPv6 address without its brackets.
String? bindAddressNamed(String? typed) => switch (typed?.trim()) {
  null || '' || '127.0.0.1' || 'localhost' => null,
  '*' => '0.0.0.0',
  final address when address.startsWith('[') && address.endsWith(']') =>
    address.substring(1, address.length - 1),
  final address => address,
};

/// Whether only this computer can reach [address], however it's written.
bool isLoopbackAddress(String address) =>
    InternetAddress.tryParse(address)?.isLoopback ?? false;

/// Whether [address] is every IPv4 or every IPv6 address, as 0.0.0.0 or ::.
bool isEveryAddress(String address) =>
    switch (InternetAddress.tryParse(address)) {
      final parsed? => parsed == .anyIPv4 || parsed == .anyIPv6,
      null => false,
    };

/// What a tunnel forwards. Every forward but a remote one listens on this
/// computer at `bindAddress`, one of its IP addresses.
@freezed
sealed class const TunnelForward._() with _$TunnelForward {
  /// `ssh -L` to [remoteHost] and [remotePort], reached from the SSH host.
  const factory local({
    @Default('127.0.0.1') String bindAddress,
    required int localPort,
    required String remoteHost,
    required int remotePort,
  }) = LocalForward;

  /// `ssh -L` to the Unix socket at [remoteSocket] on the SSH host.
  const factory socket({
    @Default('127.0.0.1') String bindAddress,
    required int localPort,
    required String remoteSocket,
  }) = SocketForward;

  /// `ssh -D`.
  const factory socks({
    @Default('127.0.0.1') String bindAddress,
    required int localPort,
  }) = SocksProxy;

  /// `ssh -R`: the SSH host listens on its own [remotePort], and brings each
  /// connection back to [localHost], or localhost when null, on [localPort].
  const factory remote({
    required int remotePort,
    String? localHost,
    required int localPort,
  }) = RemoteForward;

  /// Reads the fields [toJson] writes into a tunnel, or throws a
  /// [FormatException] when one its kind needs is missing.
  static TunnelForward fromJson(Map<Object?, Object?> fields) {
    T? field<T>(String key) => switch (fields[key]) {
      final T value => value,
      _ => null,
    };
    T required<T>(String key) =>
        field<T>(key) ??
        (throw FormatException('A ${fields['kind']} tunnel needs $key'));

    final bindAddress =
        bindAddressNamed(field<String>('bindAddress')) ?? '127.0.0.1';
    return switch (fields['kind']) {
      null || 'local' => switch (field<String>('remoteSocket')) {
        final remoteSocket? => SocketForward(
          bindAddress: bindAddress,
          localPort: required('localPort'),
          remoteSocket: remoteSocket,
        ),
        null => LocalForward(
          bindAddress: bindAddress,
          localPort: required('localPort'),
          remoteHost: required('remoteHost'),
          remotePort: required('remotePort'),
        ),
      },
      'socks' => SocksProxy(
        bindAddress: bindAddress,
        localPort: required('localPort'),
      ),
      'remote' => RemoteForward(
        remotePort: required('remotePort'),
        localHost: field('localHost'),
        localPort: required('localPort'),
      ),
      final kind => throw FormatException('Not a kind of tunnel: $kind'),
    };
  }

  /// Flat, in the keys tunnels have always been saved with.
  Map<String, Object?> toJson() => switch (this) {
    LocalForward(
      :final bindAddress,
      :final localPort,
      :final remoteHost,
      :final remotePort,
    ) =>
      {
        'kind': kind.name,
        'bindAddress': ?bindAddressNamed(bindAddress),
        'localPort': localPort,
        'remoteHost': remoteHost,
        'remotePort': remotePort,
      },
    SocketForward(:final bindAddress, :final localPort, :final remoteSocket) =>
      {
        'kind': kind.name,
        'bindAddress': ?bindAddressNamed(bindAddress),
        'localPort': localPort,
        'remoteSocket': remoteSocket,
      },
    SocksProxy(:final bindAddress, :final localPort) => {
      'kind': kind.name,
      'bindAddress': ?bindAddressNamed(bindAddress),
      'localPort': localPort,
    },
    RemoteForward(:final remotePort, :final localHost, :final localPort) => {
      'kind': kind.name,
      'localHost': ?localHost,
      'localPort': localPort,
      'remotePort': remotePort,
    },
  };

  TunnelKind get kind => switch (this) {
    LocalForward() || SocketForward() => TunnelKind.local,
    SocksProxy() => TunnelKind.socks,
    RemoteForward() => TunnelKind.remote,
  };

  String get address => switch (this) {
    LocalForward(:final bindAddress, :final localPort) ||
    SocketForward(
      :final bindAddress,
      :final localPort,
    ) => '${_bracketed(reachableAt(bindAddress))}:$localPort',
    SocksProxy(:final bindAddress, :final localPort) =>
      'socks5h://${_bracketed(reachableAt(bindAddress))}:$localPort',
    RemoteForward(:final remotePort) => 'localhost:$remotePort',
  };

  /// Throws an [ArgumentError] for one ssh can't open, such as a port outside
  /// 1 to 65535.
  String sshCommand(SshTarget target) => switch (this) {
    LocalForward(
      :final bindAddress,
      :final localPort,
      :final remoteHost,
      :final remotePort,
    ) =>
      tunnelCommand(
        target,
        bindAddress: bindAddress,
        remoteHost: remoteHost,
        remotePort: remotePort,
        localPort: localPort,
      ),
    SocketForward(:final bindAddress, :final localPort, :final remoteSocket) =>
      socketTunnelCommand(
        target,
        bindAddress: bindAddress,
        remoteSocket: remoteSocket,
        localPort: localPort,
      ),
    SocksProxy(:final bindAddress, :final localPort) => socksProxyCommand(
      target,
      bindAddress: bindAddress,
      localPort: localPort,
    ),
    RemoteForward(:final remotePort, :final localHost, :final localPort) =>
      remoteTunnelCommand(
        target,
        localHost: localHost ?? 'localhost',
        localPort: localPort,
        remotePort: remotePort,
      ),
  };

  String summary(String sshHost) => switch (this) {
    LocalForward(
      :final bindAddress,
      :final localPort,
      :final remoteHost,
      :final remotePort,
    ) =>
      '${_bracketed(bindAddress)}:$localPort → $remoteHost:$remotePort '
          'via $sshHost',
    SocketForward(:final bindAddress, :final localPort, :final remoteSocket) =>
      '${_bracketed(bindAddress)}:$localPort → $remoteSocket via $sshHost',
    SocksProxy(:final bindAddress, :final localPort) =>
      'SOCKS on ${_bracketed(bindAddress)}:$localPort via $sshHost',
    RemoteForward(:final remotePort, :final localHost, :final localPort) =>
      'port $remotePort on $sshHost → ${localHost ?? 'localhost'}:$localPort',
  };
}

/// Where this computer reaches a forward listening on [bindAddress]: 0.0.0.0
/// and :: listen on loopback too.
String reachableAt(String bindAddress) => isEveryAddress(bindAddress)
    ? bindAddress.contains(':')
          ? '::1'
          : '127.0.0.1'
    : bindAddress;

String _bracketed(String address) =>
    address.contains(':') ? '[$address]' : address;
