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
  final Stream<void> aboutRequests = const Stream.empty(),
  final SettingsBloc? settings,
}) extends StatefulWidget {
  static const settingsRoute = '/settings';

  @override
  State<TakaApp> createState() => _TakaAppState();
}

class _TakaAppState extends State<TakaApp> {
  static const _menu = MethodChannel('taka/menu');

  final _navigator = GlobalKey<NavigatorState>();
  late final StreamSubscription<void> _aboutRequests;

  @override
  void initState() {
    super.initState();
    _aboutRequests = widget.aboutRequests.listen((_) => _showAbout());
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
    unawaited(_aboutRequests.cancel());
    _menu.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
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
      home: widget.home,
      routes: {
        if (widget.settings != null)
          TakaApp.settingsRoute: (_) => SettingsPage(version: widget.version),
      },
    );

    return switch (widget.settings) {
      final settings? => BlocProvider.value(value: settings, child: app),
      null => app,
    };
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

    _navigator.currentState!
      ..popUntil((route) => route.isFirst)
      ..pushNamed(TakaApp.settingsRoute);
  }

  void _showAbout() => _navigator.currentState!
    ..popUntil((route) => route.isFirst)
    ..push(
      MaterialPageRoute<void>(
        builder: (_) => AboutPage(version: widget.version),
      ),
    );
}
