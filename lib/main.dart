import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:taka/agent/agent_launcher.dart';
import 'package:taka/pages/about/about_page.dart';
import 'package:taka/pages/tunnels/tunnels_bloc.dart';
import 'package:taka/pages/tunnels/tunnels_page.dart';
import 'package:taka/theme/taka_theme.dart';

final _navigator = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(bundledLicenses);
  final version = (await PackageInfo.fromPlatform()).version;

  void showAbout() {
    final navigator = _navigator.currentState;
    if (navigator == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showAbout());
      return;
    }

    navigator
      ..popUntil((route) => route.isFirst)
      ..push(
        MaterialPageRoute<void>(builder: (_) => AboutPage(version: version)),
      );
  }

  const MethodChannel('taka/menu').setMethodCallHandler((call) async {
    if (call.method == 'about') showAbout();
  });

  runApp(TakaApp(home: await _home(onAbout: showAbout)));
}

Future<Widget> _home({required void Function() onAbout}) async {
  try {
    final agent = await connectToAgent();
    agent.aboutRequests.listen((_) => onAbout());
    final bloc = TunnelsBloc(agent: agent)..add(const TunnelsEvent.started());
    unawaited(
      bloc.stream
          .firstWhere((state) => state is Closed)
          .then(
            (_) =>
                ServicesBinding.instance.exitApplication(AppExitType.required),
          ),
    );

    return BlocProvider.value(value: bloc, child: const TunnelsPage());
  } on Exception catch (exception) {
    return Scaffold(
      body: Center(child: Text("Taka's agent didn't start: $exception")),
    );
  }
}

class const TakaApp({super.key, required final Widget home})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigator,
      title: 'Taka',
      theme: takaTheme(Brightness.light),
      darkTheme: takaTheme(Brightness.dark),
      debugShowCheckedModeBanner: false,
      home: home,
    );
  }
}
