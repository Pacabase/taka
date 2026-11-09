import 'package:core/src/tunnel.dart';

const _flags = '46AaCfGgKkMNnqsTtVvXxYy';
const _ignoredFlags = 'CNTfnqtv';
const _withValue = 'BbcDEeFIiJLlmOoPpQRSWw';
const _operators = {'&', '&&', ';', '|', '||'};

/// The tunnel a pasted `ssh -L` or `ssh -D` command opens, with an empty id,
/// and what else the command sets that a tunnel can't keep, like `-i key.pem`.
///
/// Taka listens on 127.0.0.1 only, so a forward's bind address is dropped.
({Tunnel tunnel, List<String> leftOut})? parseSshCommand(String command) {
  final words = switch (_words(command)) {
    [r'$', final ssh, ...final rest] ||
    [final ssh, ...final rest] when _isSsh(ssh) => rest,
    _ => null,
  };
  if (words == null) return null;

  final leftOut = <String>[];
  final remoteCommand = <String>[];
  Tunnel? forward;
  String? destination;
  String? user;
  String? port;
  var optionsEnded = false;
  for (var index = 0; index < words.length; index++) {
    final word = words[index];
    if (remoteCommand.isNotEmpty) {
      remoteCommand.add(word);
    } else if (word == '--' && !optionsEnded) {
      optionsEnded = true;
    } else if (optionsEnded || !word.startsWith('-') || word == '-') {
      destination == null ? destination = word : remoteCommand.add(word);
    } else {
      for (var at = 1; at < word.length; at++) {
        final flag = word[at];
        if (_withValue.contains(flag)) {
          final value = at + 1 < word.length
              ? word.substring(at + 1)
              : index + 1 < words.length
              ? words[++index]
              : null;
          if (value == null) return null;

          switch (flag) {
            case 'L' when forward == null:
              forward = _local(value);
              if (forward == null) return null;
            case 'D' when forward == null:
              forward = _socks(value);
              if (forward == null) return null;
            case 'l':
              user = value;
            case 'p':
              port = value;
            default:
              leftOut.add('-$flag $value');
          }
          break;
        }
        if (!_flags.contains(flag)) return null;
        if (!_ignoredFlags.contains(flag)) leftOut.add('-$flag');
      }
    }
  }
  if (forward == null || destination == null) return null;

  if (destination.startsWith('ssh://')) {
    final uri = Uri.tryParse(destination);
    if (uri == null || uri.host.isEmpty) return null;
    if (uri.hasPort) port = '${uri.port}';
    destination = uri.userInfo.isEmpty
        ? uri.host
        : '${Uri.decodeComponent(uri.userInfo)}@${uri.host}';
  }
  if (destination.isEmpty || destination.startsWith('-')) return null;
  if (user != null && !destination.contains('@')) {
    destination = '$user@$destination';
  }

  return (
    tunnel: forward.copyWith(sshHost: destination),
    leftOut: [
      if (port != null && port != '22') '-p $port',
      ...leftOut,
      if (remoteCommand.isNotEmpty) remoteCommand.join(' '),
    ],
  );
}

bool _isSsh(String word) =>
    word == 'ssh' || word.endsWith('/ssh') || word.toLowerCase() == 'ssh.exe';

Tunnel? _local(String spec) => switch (_fields(spec)) {
  [_, final local, final host, final remote] ||
  [final local, final host, final remote] when host.isNotEmpty => switch ((
    _port(local),
    _port(remote),
  )) {
    (final localPort?, final remotePort?) => Tunnel(
      id: '',
      localPort: localPort,
      remoteHost: host,
      remotePort: remotePort,
    ),
    _ => null,
  },
  _ => null,
};

Tunnel? _socks(String spec) => switch (_fields(spec)) {
  [_, final local] || [final local] => switch (_port(local)) {
    final localPort? => Tunnel(
      id: '',
      kind: TunnelKind.socks,
      localPort: localPort,
    ),
    null => null,
  },
  _ => null,
};

int? _port(String text) => switch (int.tryParse(text, radix: 10)) {
  final port? when port >= 1 && port <= 65535 => port,
  _ => null,
};

// A forward's fields, split at colons outside [brackets], brackets dropped.
List<String>? _fields(String spec) {
  final fields = <String>[];
  final field = StringBuffer();
  var inBrackets = false;
  for (final char in spec.split('')) {
    switch (char) {
      case '[' when !inBrackets:
        inBrackets = true;
      case ']' when inBrackets:
        inBrackets = false;
      case ':' when !inBrackets:
        fields.add('$field');
        field.clear();
      default:
        field.write(char);
    }
  }
  if (inBrackets) return null;

  return fields..add('$field');
}

// Splits like a POSIX shell, up to the first operator such as `&`.
List<String> _words(String text) {
  final words = <String>[];
  final word = StringBuffer();
  var inWord = false;
  String? quote;

  void end() {
    if (inWord) words.add('$word');
    word.clear();
    inWord = false;
  }

  for (var index = 0; index < text.length; index++) {
    final char = text[index];
    final next = index + 1 < text.length ? text[index + 1] : null;
    if (quote == "'") {
      char == "'" ? quote = null : word.write(char);
    } else if (quote == '"') {
      if (char == '"') {
        quote = null;
      } else if (char == r'\' && next != null && r'$`"\'.contains(next)) {
        word.write(next);
        index++;
      } else {
        word.write(char);
      }
    } else if (char == "'" || char == '"') {
      quote = char;
      inWord = true;
    } else if (char == r'\' && next != null) {
      index++;
      if (next == '\r' && text.startsWith('\n', index + 1)) {
        index++;
      } else if (next != '\n') {
        word.write(next);
        inWord = true;
      }
    } else if (' \t\r\n'.contains(char)) {
      end();
    } else {
      word.write(char);
      inWord = true;
    }
  }
  if (quote != null) return const [];
  end();

  return words.takeWhile((word) => !_operators.contains(word)).toList();
}
