import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taka/pages/about/about_page.dart';
import 'package:taka/theme/taka_theme.dart';

class const TakaApp({
  super.key,
  required final String version,
  required final Widget home,
  final Stream<void> aboutRequests = const Stream.empty(),
}) extends StatefulWidget {
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
      if (call.method == 'about') _showAbout();
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
    return MaterialApp(
      navigatorKey: _navigator,
      title: 'Taka',
      theme: takaTheme(Brightness.light),
      darkTheme: takaTheme(Brightness.dark),
      debugShowCheckedModeBanner: false,
      home: widget.home,
    );
  }

  void _showAbout() => _navigator.currentState!
    ..popUntil((route) => route.isFirst)
    ..push(
      MaterialPageRoute<void>(
        builder: (_) => AboutPage(version: widget.version),
      ),
    );
}
