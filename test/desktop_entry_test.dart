@Tags(['unit'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:taka/desktop_entry.dart';

void main() {
  late Directory home;
  late File userEntry;

  setUp(() {
    home = Directory.systemTemp.createTempSync('taka_desktop');
    userEntry = entryIn('${home.path}/.local/share');
  });
  tearDown(() => home.deleteSync(recursive: true));

  Map<String, String> environment({String? systemData}) => {
    'HOME': home.path,
    'XDG_DATA_DIRS': systemData ?? '${home.path}/none',
  };

  test(
    'names the window and draws its icon from the unpacked bundle',
    () async {
      await writeDesktopEntry('/opt/taka/taka', environment: environment());

      final entry = userEntry.readAsStringSync();
      expect(entry, contains('Name=Taka\n'));
      expect(entry, contains('Exec="/opt/taka/taka"\n'));
      expect(
        entry,
        contains('Icon=/opt/taka/data/flutter_assets/assets/icon/icon.png\n'),
      );
      expect(entry, contains('StartupWMClass=com.pacabase.taka\n'));
    },
  );

  test('goes in XDG_DATA_HOME when it is set', () async {
    final data = '${home.path}/data';

    await writeDesktopEntry(
      '/opt/taka/taka',
      environment: {...environment(), 'XDG_DATA_HOME': data},
    );

    expect(entryIn(data).existsSync(), isTrue);
    expect(userEntry.existsSync(), isFalse);
  });

  test('rewrites an entry for a bundle that moved, and only then', () async {
    await writeDesktopEntry('/old/taka', environment: environment());
    await writeDesktopEntry('/opt/taka/taka', environment: environment());

    expect(userEntry.readAsStringSync(), contains('Exec="/opt/taka/taka"\n'));

    userEntry.setLastModifiedSync(DateTime(2000));
    await writeDesktopEntry('/opt/taka/taka', environment: environment());

    expect(userEntry.lastModifiedSync(), DateTime(2000));
  });

  test("leaves a package's entry to the package, and drops its own", () async {
    final system = '${home.path}/usr/share';
    await writeDesktopEntry('/opt/taka/taka', environment: environment());
    entryIn(system).createSync(recursive: true);

    await writeDesktopEntry(
      '/opt/taka/taka',
      environment: environment(systemData: '${home.path}/none:$system'),
    );

    expect(userEntry.existsSync(), isFalse);
  });

  test('never touches an entry the user wrote', () async {
    final system = '${home.path}/usr/share';
    userEntry
      ..createSync(recursive: true)
      ..writeAsStringSync('[Desktop Entry]\nName=My Taka\n');

    await writeDesktopEntry('/opt/taka/taka', environment: environment());
    expect(userEntry.readAsStringSync(), '[Desktop Entry]\nName=My Taka\n');

    entryIn(system).createSync(recursive: true);
    await writeDesktopEntry(
      '/opt/taka/taka',
      environment: environment(systemData: system),
    );
    expect(userEntry.existsSync(), isTrue);
  });

  test('keeps its entry when XDG_DATA_DIRS lists the user folder', () async {
    final both = environment(systemData: '${home.path}/.local/share');

    await writeDesktopEntry('/opt/taka/taka', environment: both);
    await writeDesktopEntry('/opt/taka/taka', environment: both);

    expect(userEntry.existsSync(), isTrue);
  });

  test('quotes the path and escapes what Exec reads', () {
    final entry = desktopEntry(
      executable: r"/home/a b/it's 50% $x\y/taka",
      icon: '',
    );

    expect(
      entry,
      contains('Exec="/home/a b/it\'s 50%% \\\\\$x\\\\\\\\y/taka"\n'),
    );
  });

  test('escapes the icon and the executable it tries', () {
    final entry = desktopEntry(
      executable: r'/a\b/taka',
      icon: r'/a\b/icon.png',
    );

    expect(
      entry,
      contains(
        r'Icon=/a\\b/icon.png'
        '\n',
      ),
    );
    expect(
      entry,
      contains(
        r'TryExec=/a\\b/taka'
        '\n',
      ),
    );
  });
}

File entryIn(String data) =>
    File('$data/applications/com.pacabase.taka.desktop');
