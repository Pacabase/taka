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
  _AgentLink _link = const _Connecting();

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
    if (_link case _Connected(:final settings)) unawaited(settings.close());
    super.dispose();
  }

  Future<void> _connect() async {
    setState(() => _link = const _Connecting());
    try {
      final agent = await widget.connect();
      if (!mounted) return;
      setState(
        () => _link = _Connected(
          agent,
          SettingsBloc(agent: agent)..add(const SettingsEvent.started()),
        ),
      );
    } catch (exception) {
      Fimber.e("Taka's background helper didn't start", ex: exception);
      if (mounted) setState(() => _link = _Failed(exception));
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
    home: switch (_link) {
      _Connecting() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      _Failed(:final error) => AgentErrorPage(
        error: error,
        version: widget.version,
        onTryAgain: _connect,
      ),
      _Connected(:final agent) => widget.home(agent),
    },
    routes: {
      if (_link case _Connected(:final settings))
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
    if (_link is! _Connected) return;

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

sealed class const _AgentLink() {}

class const _Connecting() extends _AgentLink {}

class const _Failed(final Object error) extends _AgentLink {}

class const _Connected(final AgentClient agent, final SettingsBloc settings)
    extends _AgentLink {}
