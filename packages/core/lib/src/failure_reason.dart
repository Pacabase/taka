final _portInUse = RegExp(r':(\d+) is already in use');

const _reasons = [
  (['Could not resolve hostname'], 'server not found'),
  (['Permission denied ('], 'login refused'),
  (
    ['Host key verification failed', 'REMOTE HOST IDENTIFICATION HAS CHANGED'],
    'host key changed',
  ),
  (['not responding'], 'server stopped answering'),
  (
    ['Connection refused', 'timed out', 'No route to host'],
    "can't reach the server",
  ),
  (
    ['closed by remote host', 'Connection reset', 'Broken pipe'],
    'disconnected',
  ),
];

/// A few words for why a tunnel failed, from ssh's own [message], for places
/// too narrow for all of it; anything unknown comes back as it is.
String shortReason(String message) {
  if (_portInUse.firstMatch(message)?[1] case final port?) {
    return 'port $port in use';
  }

  return _reasons
          .where((reason) => reason.$1.any(message.contains))
          .firstOrNull
          ?.$2 ??
      message.trim();
}
