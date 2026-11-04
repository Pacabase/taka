import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taka/agent/agent_launcher.dart';
import 'package:taka/pages/tunnels/tunnels_bloc.dart';
import 'package:taka/pages/tunnels/tunnels_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(TakaApp(home: await _home()));
}

Future<Widget> _home() async {
  try {
    final agent = await connectToAgent();
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
      title: 'Taka',
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      home: home,
    );
  }
}
