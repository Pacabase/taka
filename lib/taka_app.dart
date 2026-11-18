import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taka/agent/agent_bloc.dart';
import 'package:taka/pages/about/about_page.dart';
import 'package:taka/pages/agent_error_page.dart';
import 'package:taka/pages/settings/settings_page.dart';
import 'package:taka/theme/taka_theme.dart';

class const TakaApp({
  super.key,
  required final String version,
  required final Future<AgentClient> Function() connect,
  required final Widget Function(AgentClient agent) home,
}) extends StatefulWidget {
  static const settingsRoute = '/settings';

  @override
  State<TakaApp> createState() => _TakaAppState();
}

class _TakaAppState extends State<TakaApp> {
  static const _menu = MethodChannel('taka/menu');

  final _navigator = GlobalKey<NavigatorState>();
  late final _agent = AgentBloc(connect: widget.connect)
    ..add(const AgentEvent.connect());

  @override
  void initState() {
    super.initState();
    _menu.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'about':
          _showAbout();
        case 'settings':
          _showSettings();
      }
    });
  }

  @override
  void dispose() {
    _menu.setMethodCallHandler(null);
    unawaited(_agent.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<AgentBloc, AgentState>(
    bloc: _agent,
    builder: (context, link) => _app(link),
  );

  Widget _app(AgentState link) => MaterialApp(
    navigatorKey: _navigator,
    title: 'Taka',
    theme: takaTheme(Brightness.light),
    darkTheme: takaTheme(Brightness.dark),
    debugShowCheckedModeBanner: false,
    builder: (context, child) => CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _unfocus},
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _unfocus,
        child: child,
      ),
    ),
    home: switch (link) {
      AgentConnecting() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AgentFailed(:final error) => AgentErrorPage(
        error: error,
        version: widget.version,
        onTryAgain: () => _agent.add(const AgentEvent.connect()),
      ),
      AgentConnected(:final agent) => widget.home(agent),
    },
    routes: {
      if (link case AgentConnected(:final settings))
        TakaApp.settingsRoute: (_) => BlocProvider.value(
          value: settings,
          child: SettingsPage(version: widget.version),
        ),
    },
  );

  // Unfocusing a scope moves focus out of the navigator, where Tab finds nothing.
  void _unfocus() {
    if (FocusManager.instance.primaryFocus case final focus?
        when focus is! FocusScopeNode) {
      focus.unfocus();
    }
  }

  void _showSettings() {
    if (_agent.state is! AgentConnected) return;

    final navigator = _navigator.currentState!;
    var isShown = false;
    navigator.popUntil((route) {
      isShown = route.settings.name == TakaApp.settingsRoute;
      return isShown || route.isFirst;
    });
    if (!isShown) unawaited(navigator.pushNamed(TakaApp.settingsRoute));
  }

  void _showAbout() => _navigator.currentState!
    ..popUntil((route) => route.isFirst)
    ..push(
      MaterialPageRoute<void>(
        builder: (_) => AboutPage(version: widget.version),
      ),
    );
}
