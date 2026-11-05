import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:taka/agent/agent_launcher.dart';
import 'package:taka/pages/about/about_page.dart';
import 'package:taka/pages/tunnels/tunnels_bloc.dart';
import 'package:taka/pages/tunnels/tunnels_page.dart';
import 'package:taka/taka_app.dart';
import 'package:taka/widgets/input_kind.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(bundledLicenses);
  watchInputKind();
  final version = (await PackageInfo.fromPlatform()).version;

  try {
    final agent = await connectToAgent();
    runApp(
      TakaApp(
        version: version,
        aboutRequests: agent.aboutRequests,
        home: BlocProvider(
          create: (_) =>
              TunnelsBloc(agent: agent)..add(const TunnelsEvent.started()),
          child: const TunnelsPage(),
        ),
      ),
    );
  } on Exception catch (exception) {
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
