@Tags(['unit'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:taka/pages/about/about_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  group('About', () {
    late List<String> packages;

    setUpAll(
      () async => packages = await bundledLicenses()
          .expand((entry) => entry.packages)
          .toList(),
    );

    test("lists the helper's packages beside Taka's own", () {
      expect(
        packages,
        containsAll(['Lucide', 'nativeapi', 'cnativeapi', 'process']),
      );
    });

    test('adds none that Flutter lists for the window already', () {
      for (final listed in ['crypto', 'file', 'glob', 'pub_semver', 'yaml']) {
        expect(packages, isNot(contains(listed)));
      }
    });
  });
}
