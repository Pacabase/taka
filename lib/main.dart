import 'dart:io';

import 'package:core/core.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:taka/agent/agent_launcher.dart';
import 'package:taka/pages/about/about_page.dart';
import 'package:taka/pages/settings/settings_bloc.dart';
import 'package:taka/pages/tunnels/tunnels_bloc.dart';
import 'package:taka/pages/tunnels/tunnels_page.dart';
import 'package:taka/taka_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) Fimber.plantTree(DebugTree());
  DebugLogging('window').start();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    Fimber.e(
      'Uncaught Flutter error',
      ex: details.exception,
      stacktrace: details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    Fimber.e('Uncaught error', ex: error, stacktrace: stack);
    return true;
  };
  LicenseRegistry.addLicense(bundledLicenses);
  final version = (await PackageInfo.fromPlatform()).version;
  Fimber.i('Taka $version on ${Platform.operatingSystemVersion}');

  try {
    final agent = await connectToAgent();
    runApp(
      TakaApp(
        version: version,
        aboutRequests: agent.aboutRequests,
        settings: SettingsBloc(agent: agent)
          ..add(const SettingsEvent.started()),
        home: BlocProvider(
          create: (_) =>
              TunnelsBloc(agent: agent)..add(const TunnelsEvent.started()),
          child: const TunnelsPage(),
        ),
      ),
    );
  } on Exception catch (exception) {
    Fimber.e("Taka's agent didn't start", ex: exception);
    runApp(
      TakaApp(
        version: version,
        home: Scaffold(
          body: Center(child: Text("Taka's agent didn't start: $exception")),
        ),
      ),
    );
  }
}
