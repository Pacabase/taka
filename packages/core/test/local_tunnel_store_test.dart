@Tags(['unit'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late File file;

  const database = Tunnel(
    id: 'a1',
    name: 'Production database',
    sshHost: 'bastion',
    forward: LocalForward(
      localPort: 15432,
      remoteHost: 'db.internal',
      remotePort: 5432,
    ),
  );
  const proxy = Tunnel(
    id: 'b2',
    sshHost: 'bastion',
    forward: SocksProxy(localPort: 1080),
  );

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('taka_store_test');
    file = File('${directory.path}/nested/tunnels.json');
  });

  tearDown(() => directory.delete(recursive: true));

  LocalTunnelStore store() => LocalTunnelStore(file: file);

  test('load is empty when there is no file', () async {
    final loaded = await store().load();

    expect(loaded.book.tunnels, <Tunnel>[]);
    expect(loaded.on, <String>{});
  });

  test('save creates the folder and load reads the tunnels in order', () async {
    await store().save(
      const TunnelBook(tunnels: [proxy, database]),
      on: const {},
    );

    expect((await store().load()).book.tunnels, [proxy, database]);
  });

  test('save keeps group colours, and a file without them has none', () async {
    await store().save(const TunnelBook(tunnels: [database]), on: const {});
    expect((await store().load()).book.groupColours, isEmpty);

    await store().save(
      TunnelBook(
        tunnels: [database.copyWith(group: 'Prod')],
        groupColours: const {'Prod': TunnelColour.blue},
      ),
      on: const {},
    );
    expect((await store().load()).book.groupColours, {
      'Prod': TunnelColour.blue,
    });
  });

  test('save writes a versioned file', () async {
    await store().save(const TunnelBook(tunnels: [proxy]), on: const {});

    expect(jsonDecode(await file.readAsString()), {
      'version': 1,
      'tunnels': [proxy.toJson()],
      'on': <String>[],
    });
  });

  test('save replaces what was saved before', () async {
    await store().save(
      const TunnelBook(tunnels: [database, proxy]),
      on: const {},
    );
    await store().save(const TunnelBook(tunnels: [proxy]), on: const {});

    expect((await store().load()).book.tunnels, [proxy]);
  });

  test('saves made together land in order', () async {
    final saving = store();

    await Future.wait([
      saving.save(const TunnelBook(tunnels: [database]), on: const {}),
      saving.save(const TunnelBook(tunnels: [database, proxy]), on: const {}),
      saving.save(const TunnelBook(tunnels: [proxy]), on: const {}),
    ]);

    expect((await store().load()).book.tunnels, [proxy]);
  });

  test('load rejects a file of another version', () async {
    await file.create(recursive: true);
    await file.writeAsString(
      jsonEncode({'version': 3, 'tunnels': <Object?>[]}),
    );

    expect(store().load(), throwsFormatException);
  });

  for (final (name, contents) in [
    ('not JSON', '{"version": 1, "tunn'),
    ('a list', '[]'),
    ('missing tunnels', '{"version": 1}'),
    ('a tunnel without an id', '{"version": 1, "tunnels": [{"localPort": 1}]}'),
    ('a tunnel that is not an object', '{"version": 1, "tunnels": [3]}'),
    (
      'a local tunnel without a destination',
      '{"version": 1, "tunnels": [{"id": "c3", "localPort": 1}]}',
    ),
  ]) {
    test('load rejects $name with a FormatException', () async {
      await file.create(recursive: true);
      await file.writeAsString(contents);

      expect(store().load(), throwsFormatException);
    });
  }

  test('save refuses to overwrite a file it could not read', () async {
    await file.create(recursive: true);
    await file.writeAsString(
      jsonEncode({'version': 3, 'tunnels': <Object?>[]}),
    );
    final saving = store();
    await expectLater(saving.load(), throwsFormatException);

    await expectLater(
      saving.save(const TunnelBook(tunnels: [proxy]), on: const {}),
      throwsA(isA<FileSystemException>()),
    );
    expect(jsonDecode(await file.readAsString()), containsPair('version', 3));
  });

  test('a failed save does not stop the next one', () async {
    final saving = store();
    await Directory(file.path).create(recursive: true);

    await expectLater(
      saving.save(const TunnelBook(tunnels: [proxy]), on: const {}),
      throwsA(isA<FileSystemException>()),
    );
    await Directory(file.path).delete();
    await saving.save(const TunnelBook(tunnels: [database]), on: const {});

    expect((await store().load()).book.tunnels, [database]);
  });

  test('save leaves no temporary file behind', () async {
    await store().save(const TunnelBook(tunnels: [proxy]), on: const {});

    expect(file.parent.listSync().map((entry) => entry.uri.pathSegments.last), [
      'tunnels.json',
    ]);
  });

  test('save keeps which tunnels were on, and load reads them back', () async {
    await store().save(
      const TunnelBook(tunnels: [database, proxy]),
      on: {'b2'},
    );

    final loaded = await store().load();

    expect(loaded.book.tunnels, [database, proxy]);
    expect(loaded.on, {'b2'});
  });

  test('a file from before Taka remembered them has none on', () async {
    await file.create(recursive: true);
    await file.writeAsString(
      jsonEncode({
        'version': 1,
        'tunnels': [database.toJson()],
      }),
    );

    final loaded = await store().load();

    expect(loaded.book.tunnels, [database]);
    expect(loaded.on, <String>{});
  });

  test('load ignores an on list it cannot read', () async {
    await file.create(recursive: true);
    await file.writeAsString(
      jsonEncode({
        'version': 1,
        'tunnels': [database.toJson()],
        'on': 'a1',
      }),
    );

    expect((await store().load()).on, isEmpty);
  });

  test('save lists the tunnels that are on in their order', () async {
    await store().save(
      const TunnelBook(tunnels: [database, proxy]),
      on: {'b2', 'a1', 'gone'},
    );

    expect(
      jsonDecode(await file.readAsString()),
      containsPair('on', ['a1', 'b2']),
    );
  });
}
