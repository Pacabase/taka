import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taka/pages/about/about_page.dart';
import 'package:taka/pages/settings/settings_bloc.dart';
import 'package:taka/pages/settings/settings_page.dart';
import 'package:taka/theme/taka_theme.dart';

class const TakaApp({
  super.key,
  required final String version,
  required final Widget home,
  final SettingsBloc? settings,
}) extends StatefulWidget {
  static const settingsRoute = '/settings';

  @override
  State<TakaApp> createState() => _TakaAppState();
}

class _TakaAppState extends State<TakaApp> {
  static const _menu = MethodChannel('taka/menu');

  final _navigator = GlobalKey<NavigatorState>();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigator,
      title: 'Taka',
      theme: takaTheme(Brightness.light),
      darkTheme: takaTheme(Brightness.dark),
      debugShowCheckedModeBanner: false,
      // Around the navigator, not MaterialApp: a replaced MaterialApp leaves its
      // navigator showing the old home.
      builder: (context, child) {
        final app = CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): _unfocus,
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _unfocus,
            child: child,
          ),
        );
        return switch (widget.settings) {
          final settings? => BlocProvider.value(value: settings, child: app),
          null => app,
        };
      },
      home: widget.home,
      routes: {
        if (widget.settings != null)
          TakaApp.settingsRoute: (_) => SettingsPage(version: widget.version),
      },
    );
  }

  // Unfocusing a scope moves focus out of the navigator, where Tab finds nothing.
  void _unfocus() {
    if (FocusManager.instance.primaryFocus case final focus?
        when focus is! FocusScopeNode) {
      focus.unfocus();
    }
  }

  void _showSettings() {
    if (widget.settings == null) return;

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
