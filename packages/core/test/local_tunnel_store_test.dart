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
    localPort: 15432,
    remoteHost: 'db.internal',
    remotePort: 5432,
  );
  const proxy = Tunnel(
    id: 'b2',
    kind: TunnelKind.socks,
    sshHost: 'bastion',
    localPort: 1080,
  );

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('taka_store_test');
    file = File('${directory.path}/nested/tunnels.json');
  });

  tearDown(() => directory.delete(recursive: true));

  LocalTunnelStore store() => LocalTunnelStore(file: file);

  test('load is empty when there is no file', () async {
    expect(await store().load(), isEmpty);
  });

  test('save creates the folder and load reads the tunnels in order', () async {
    await store().save([proxy, database]);

    expect(await store().load(), [proxy, database]);
  });

  test('save writes a versioned file', () async {
    await store().save([proxy]);

    expect(jsonDecode(await file.readAsString()), {
      'version': 1,
      'tunnels': [proxy.toJson()],
    });
  });

  test('save replaces what was saved before', () async {
    await store().save([database, proxy]);
    await store().save([proxy]);

    expect(await store().load(), [proxy]);
  });

  test('saves made together land in order', () async {
    final saving = store();

    await Future.wait([
      saving.save([database]),
      saving.save([database, proxy]),
      saving.save([proxy]),
    ]);

    expect(await store().load(), [proxy]);
  });

  test('load rejects a file of another version', () async {
    await file.create(recursive: true);
    await file.writeAsString(
      jsonEncode({'version': 2, 'tunnels': <Object?>[]}),
    );

    expect(store().load(), throwsFormatException);
  });

  for (final (name, contents) in [
    ('not JSON', '{"version": 1, "tunn'),
    ('a list', '[]'),
    ('missing tunnels', '{"version": 1}'),
    ('a tunnel without an id', '{"version": 1, "tunnels": [{"localPort": 1}]}'),
    ('a tunnel that is not an object', '{"version": 1, "tunnels": [3]}'),
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
      jsonEncode({'version': 2, 'tunnels': <Object?>[]}),
    );
    final saving = store();
    await expectLater(saving.load(), throwsFormatException);

    await expectLater(
      saving.save([proxy]),
      throwsA(isA<FileSystemException>()),
    );
    expect(jsonDecode(await file.readAsString()), containsPair('version', 2));
  });

  test('a failed save does not stop the next one', () async {
    final saving = store();
    await Directory(file.path).create(recursive: true);

    await expectLater(
      saving.save([proxy]),
      throwsA(isA<FileSystemException>()),
    );
    await Directory(file.path).delete();
    await saving.save([database]);

    expect(await store().load(), [database]);
  });

  test('save leaves no temporary file behind', () async {
    await store().save([proxy]);

    expect(file.parent.listSync().map((entry) => entry.path), [file.path]);
  });
}
