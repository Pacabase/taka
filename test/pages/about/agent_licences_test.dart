@Tags(['unit'])
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taka/pages/about/about_page.dart';

void main() {
  test('reads each package and its licence', () {
    final entries = agentLicences(
      '[{"package": "nativeapi", "licence": "MIT License\\n\\nText"}]',
    ).toList();

    expect(entries.single.packages, ['nativeapi']);
    expect(entries.single.paragraphs.map((paragraph) => paragraph.text), [
      'MIT License',
      'Text',
    ]);
  });

  test('the bundled list has the packages the helper ships', () {
    final packages = agentLicences(
      File('assets/agent_licences.json').readAsStringSync(),
    ).expand((LicenseEntry entry) => entry.packages);

    expect(packages, containsAll(['nativeapi', 'cnativeapi', 'process']));
    expect(packages, isNot(contains('core')));
  });
}
