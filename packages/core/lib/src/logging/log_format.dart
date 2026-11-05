String formatLogLine({
  required DateTime time,
  required String level,
  required String tag,
  required String message,
  Object? exception,
  StackTrace? stackTrace,
}) {
  final details = [
    ...message.split('\n').skip(1),
    if (exception != null) ...'$exception'.split('\n'),
    if (stackTrace != null) ...'$stackTrace'.trimRight().split('\n'),
  ];
  final lines = [
    '${logTimestamp(time)} $level/$tag: ${message.split('\n').first}',
    for (final detail in details) '    $detail',
  ];

  return '${lines.join('\n')}\n';
}

String logTimestamp(DateTime time) {
  String pad(int value, [int width = 2]) => '$value'.padLeft(width, '0');

  return '${time.year}-${pad(time.month)}-${pad(time.day)} '
      '${pad(time.hour)}:${pad(time.minute)}:${pad(time.second)}.'
      '${pad(time.millisecond, 3)}';
}
