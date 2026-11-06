@Tags(['unit'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:taka/desktop_entry.dart';

void main() {
  late Directory home;

  setUp(() => home = Directory.systemTemp.createTempSync('taka_desktop'));
  tearDown(() => home.deleteSync(recursive: true));

  Map<String, String> environment({String? systemData}) => {
    'HOME': home.path,
    'XDG_DATA_DIRS': systemData ?? '${home.path}/none',
  };
  File entryIn(String data) =>
      File('$data/applications/com.pacabase.taka.desktop');

  test(
    'names the window and draws its icon from the unpacked bundle',
    () async {
      await writeDesktopEntry('/opt/taka/taka', environment: environment());

      final entry = entryIn('${home.path}/.local/share').readAsStringSync();
      expect(entry, contains('Name=Taka\n'));
      expect(entry, contains('Exec=/opt/taka/taka\n'));
      expect(
        entry,
        contains('Icon=/opt/taka/data/flutter_assets/assets/icon/icon.png\n'),
      );
      expect(entry, contains('StartupWMClass=com.pacabase.taka\n'));
    },
  );

  test('leaves a package\'s entry to the package', () async {
    final system = '${home.path}/usr/share';
    entryIn(system).createSync(recursive: true);

    await writeDesktopEntry(
      '/opt/taka/taka',
      environment: environment(systemData: system),
    );

    expect(entryIn('${home.path}/.local/share').existsSync(), isFalse);
  });

  test('quotes a path with spaces and escapes what Exec reads', () {
    final entry = desktopEntry(executable: r'/home/a b/50% $x/taka', icon: '');

    expect(
      entry,
      contains(
        r'Exec="/home/a b/50%% \\$x/taka"'
        '\n',
      ),
    );
  });
}
