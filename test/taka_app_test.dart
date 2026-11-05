@Tags(['unit'])
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/pages/about/about_page.dart';
import 'package:taka/taka_app.dart';

void main() {
  testWidgets('an About request opens About, once however often it comes', (
    tester,
  ) async {
    final requests = StreamController<void>();
    addTearDown(requests.close);
    await tester.pumpWidget(
      TakaApp(
        version: '1.2.3',
        aboutRequests: requests.stream,
        home: const Text('Tunnels'),
      ),
    );

    requests
      ..add(null)
      ..add(null);
    await tester.pumpAndSettle();

    expect(find.byType(AboutPage), findsOneWidget);
    expect(find.text('Version 1.2.3'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(AboutPage), findsNothing);
    expect(find.text('Tunnels'), findsOneWidget);
  });
}
