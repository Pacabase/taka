import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taka/agent/agent_launcher.dart';
import 'package:taka/theme/taka_colors.dart';
import 'package:taka/theme/taka_theme.dart';
import 'package:taka/widgets/app_icon.dart';

/// In plain words, what went wrong starting the background helper.
String agentFailure(Object error) => switch (error) {
  ProcessException(executable: 'open') => "macOS couldn't open it.",
  ProcessException() => "It couldn't be started.",
  AgentTimeoutException() => "It started but didn't answer within 5 seconds.",
  _ => 'Something went wrong while starting it.',
};

class const AgentErrorPage({
  super.key,
  required final Object error,
  required final String version,
  required final void Function() onTryAgain,
}) extends StatefulWidget {
  @override
  State<AgentErrorPage> createState() => _AgentErrorPageState();
}

class _AgentErrorPageState extends State<AgentErrorPage> {
  var _showsDetails = false;

  String get _details =>
      'Taka ${widget.version} on ${Platform.operatingSystemVersion}\n'
      '${widget.error}';

  @override
  Widget build(BuildContext context) {
    final colors = TakaColors.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              AppIcon(AppIcons.triangleAlert, color: colors.red, size: 24),
              const SizedBox(height: 4),
              const Text(
                "Taka's background helper didn't start",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                agentFailure(widget.error),
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  FilledButton(
                    onPressed: widget.onTryAgain,
                    child: const Text('Try Again'),
                  ),
                  TextButton(
                    onPressed: () => DebugLogging('window').reveal(),
                    child: const Text('Show Logs'),
                  ),
                  TextButton(
                    onPressed: () =>
                        Clipboard.setData(ClipboardData(text: _details)),
                    child: const Text('Copy Details'),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => setState(() => _showsDetails = !_showsDetails),
                child: Text(_showsDetails ? 'Hide Details' : 'Show Details'),
              ),
              if (_showsDetails)
                SelectableText(
                  _details,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: monoFont,
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
