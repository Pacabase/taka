import 'dart:async';

import 'package:core/core.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taka/pages/about/about_page.dart';
import 'package:taka/pages/agent_error_page.dart';
import 'package:taka/pages/settings/settings_bloc.dart';
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
  AgentClient? _agent;
  SettingsBloc? _settings;
  Object? _error;

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
    unawaited(_connect());
  }

  @override
  void dispose() {
    _menu.setMethodCallHandler(null);
    unawaited(_settings?.close());
    super.dispose();
  }

  Future<void> _connect() async {
    setState(() => _error = null);
    try {
      final agent = await widget.connect();
      if (!mounted) return;
      setState(() {
        _agent = agent;
        _settings = SettingsBloc(agent: agent)
          ..add(const SettingsEvent.started());
      });
    } catch (exception) {
      Fimber.e("Taka's background helper didn't start", ex: exception);
      if (mounted) setState(() => _error = exception);
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
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
    home: switch ((_agent, _error)) {
      (final agent?, _) => widget.home(agent),
      (_, final error?) => AgentErrorPage(
        error: error,
        version: widget.version,
        onTryAgain: _connect,
      ),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    },
    routes: {
      TakaApp.settingsRoute: (_) => BlocProvider.value(
        value: _settings!,
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
    if (_settings == null) return;

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
