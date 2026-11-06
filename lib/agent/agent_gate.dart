import 'dart:async';

import 'package:core/core.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:taka/pages/agent_error_page.dart';
import 'package:taka/theme/taka_theme.dart';

/// Connects to the background helper, and shows [connected] once it answers,
/// or why it didn't.
class const AgentGate({
  super.key,
  required final String version,
  required final Future<AgentClient> Function() connect,
  required final Widget Function(AgentClient agent) connected,
}) extends StatefulWidget {
  @override
  State<AgentGate> createState() => _AgentGateState();
}

class _AgentGateState extends State<AgentGate> {
  Widget? _app;
  Object? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_connect());
  }

  Future<void> _connect() async {
    setState(() => _error = null);
    try {
      final agent = await widget.connect();
      if (mounted) setState(() => _app = widget.connected(agent));
    } on Exception catch (exception) {
      Fimber.e("Taka's background helper didn't start", ex: exception);
      if (mounted) setState(() => _error = exception);
    }
  }

  @override
  Widget build(BuildContext context) => switch ((_app, _error)) {
    (final app?, _) => app,
    (_, final error?) => _Shell(
      home: AgentErrorPage(
        error: error,
        version: widget.version,
        onTryAgain: _connect,
      ),
    ),
    _ => const _Shell(
      home: Scaffold(body: Center(child: CircularProgressIndicator())),
    ),
  };
}

class const _Shell({required final Widget home}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Taka',
    theme: takaTheme(Brightness.light),
    darkTheme: takaTheme(Brightness.dark),
    debugShowCheckedModeBanner: false,
    home: home,
  );
}
