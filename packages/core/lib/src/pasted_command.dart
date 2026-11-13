import 'package:core/src/tunnel.dart';

const _withValue = 'BbcDEeFIiJLlmOoPpQRSWw';
// Flags that only change how ssh runs, and -l, which goes into the host.
const _notLeftOut = 'CNTfnqtvl';

final _continuation = RegExp(r'\\\r?\n');
// A word of quoted, escaped and plain runs, or an operator such as `&&`.
final _word = RegExp(
  r'''(?:'[^']*'|"(?:\\.|[^"\\])*"|\\.|[^\s'"\\;&|<>])+|[;&|<>]+''',
);
final _operator = RegExp('^[;&|<>]');
final _quoted = RegExp(r''''([^']*)'|"((?:\\.|[^"\\])*)"|\\(.)''');
final _escapedInDoubleQuotes = RegExp(r'\\([$`"\\])');
// The SSH host listens on 127.0.0.1 for a remote forward, whatever bind
// address it names.
final _portForward = RegExp(
  r'^(?:([^:\[\]]*):|\[([^\]]*)\]:)?(\d+):(?:\[([^\]]+)\]|([^:\[\]]+)):(\d+)$',
);
final _socketForward = RegExp(
  r'^(?:([^:\[\]/]*):|\[([^\]]*)\]:)?(\d+):(/[^:]+)$',
);
final _socksForward = RegExp(r'^(?:([^:\[\]]*):|\[([^\]]*)\]:)?(\d+)$');

/// A word that isn't an option has no flag: the host or the remote command.
typedef _Argument = ({String? flag, String? value});

/// The tunnel a pasted `ssh -L`, `-R` or `-D` command opens, with an empty id,
/// and what else the command sets that a tunnel can't keep, like `-i key.pem`.
({Tunnel tunnel, List<String> leftOut})? parseSshCommand(String command) {
  try {
    final arguments = switch (_words(command)) {
      [r'$', final ssh, ...final rest] ||
      [final ssh, ...final rest] when _isSsh(ssh) => _arguments(rest),
      _ => throw const FormatException('Not ssh'),
    };
    final forwardAt = arguments.indexWhere(
      (argument) => const ['L', 'R', 'D'].contains(argument.flag),
    );
    final (host, remoteCommand) = switch ([
      for (final (:flag, :value) in arguments)
        if (flag == null) value!,
    ]) {
      [final host, ...final rest] when !host.startsWith('-') => (host, rest),
      _ => throw const FormatException('No host'),
    };
    if (forwardAt == -1 || host.contains('://')) return null;

    // ssh takes the first user it reads, from -l or the host.
    final userAt = arguments.indexWhere((argument) => argument.flag == 'l');
    final hostAt = arguments.indexWhere((argument) => argument.flag == null);
    final user = userAt != -1 && (userAt < hostAt || !host.contains('@'))
        ? arguments[userAt].value
        : null;

    return (
      tunnel: _tunnel(arguments[forwardAt]).copyWith(
        sshHost: user == null
            ? host
            : '$user@${host.substring(host.lastIndexOf('@') + 1)}',
      ),
      leftOut: [
        for (final (index, (:flag, :value)) in arguments.indexed)
          if (flag != null &&
              index != forwardAt &&
              !_notLeftOut.contains(flag) &&
              !(flag == 'p' && value == '22'))
            ['-$flag', ?value].join(' '),
        if (remoteCommand.isNotEmpty) remoteCommand.join(' '),
      ],
    );
  } on FormatException {
    return null;
  }
}

bool _isSsh(String word) =>
    word == 'ssh' || word.endsWith('/ssh') || word.toLowerCase() == 'ssh.exe';

// Splits like a POSIX shell, up to the first operator or redirection.
List<String> _words(String text) {
  final joined = text.replaceAll(_continuation, '');
  if (joined.split(_word).any((gap) => gap.trim().isNotEmpty)) {
    throw const FormatException('Unclosed quote');
  }

  return _word
      .allMatches(joined)
      .map((match) => match[0]!)
      .takeWhile((word) => !word.startsWith(_operator))
      .map(
        (word) => word.replaceAllMapped(
          _quoted,
          (quoted) =>
              quoted[1] ??
              quoted[3] ??
              quoted[2]!.replaceAllMapped(
                _escapedInDoubleQuotes,
                (escaped) => escaped[1]!,
              ),
        ),
      )
      .toList();
}

// ssh reads options after the host too, up to the remote command.
List<_Argument> _arguments(List<String> words, {bool afterHost = false}) =>
    switch (words) {
      [] => [],
      ['--', ...final rest] => [
        for (final word in rest) (flag: null, value: word),
      ],
      [final word, ...final rest]
          when word.length > 1 && word.startsWith('-') =>
        _flags(word.substring(1), rest, afterHost: afterHost),
      _ when afterHost => [for (final word in words) (flag: null, value: word)],
      [final host, ...final rest] => [
        (flag: null, value: host),
        ..._arguments(rest, afterHost: true),
      ],
    };

// Grouped flags such as `-fNL`; the first that takes a value ends the group.
List<_Argument> _flags(
  String flags,
  List<String> words, {
  required bool afterHost,
}) {
  final flag = flags[0];
  final attached = flags.substring(1);
  if (!_withValue.contains(flag)) {
    return [
      (flag: flag, value: null),
      ...attached.isEmpty
          ? _arguments(words, afterHost: afterHost)
          : _flags(attached, words, afterHost: afterHost),
    ];
  }

  return switch ((attached, words)) {
    ('', [final value, ...final rest]) => [
      (flag: flag, value: value),
      ..._arguments(rest, afterHost: afterHost),
    ],
    ('', []) => throw FormatException('-$flag needs a value'),
    _ => [
      (flag: flag, value: attached),
      ..._arguments(words, afterHost: afterHost),
    ],
  };
}

Tunnel _tunnel(_Argument forward) => switch ((
  forward.flag,
  _portForward.firstMatch(forward.value!),
  _socksForward.firstMatch(forward.value!),
  _socketForward.firstMatch(forward.value!),
)) {
  ('L', _, _, final socket?) => Tunnel(
    id: '',
    bindAddress: _bindAddress(socket),
    localPort: _port(socket[3]!),
    remoteSocket: socket[4],
  ),
  ('L', final local?, _, _) => Tunnel(
    id: '',
    bindAddress: _bindAddress(local),
    localPort: _port(local[3]!),
    remoteHost: local[4] ?? local[5],
    remotePort: _port(local[6]!),
  ),
  ('R', final remote?, _, _) => Tunnel(
    id: '',
    kind: TunnelKind.remote,
    remotePort: _port(remote[3]!),
    localHost: remote[4] ?? remote[5],
    localPort: _port(remote[6]!),
  ),
  ('D', _, final socks?, _) => Tunnel(
    id: '',
    kind: TunnelKind.socks,
    bindAddress: _bindAddress(socks),
    localPort: _port(socks[3]!),
  ),
  _ => throw FormatException('Not a forward: ${forward.value}'),
};

// ssh's `*` or an empty address is every IPv4 one; Taka keeps an IP address
// and leaves a name such as localhost at the default.
String? _bindAddress(RegExpMatch forward) => switch (forward[1] ?? forward[2]) {
  '' || '*' => '0.0.0.0',
  '127.0.0.1' || null => null,
  final address when isIpAddress(address) => address,
  _ => null,
};

int _port(String digits) => switch (int.parse(digits)) {
  final port when port >= 1 && port <= 65535 => port,
  _ => throw FormatException('Not a port: $digits'),
};
