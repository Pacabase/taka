// Flutter lists licences for the window's packages only, so this writes those
// of the ones only the background helper ships to assets/agent_licences.json.
import 'dart:convert';
import 'dart:io';

const _output = 'assets/agent_licences.json';
// NOTICES first, as Flutter reads it, since it carries bundled notices too.
const _licenceFiles = [
  'NOTICES',
  'LICENSE',
  'LICENSE.md',
  'LICENSE.txt',
  'COPYING',
];

Future<void> main() async {
  final agentPackages = _packageRoots('packages/agent');
  // Flutter lists each package in the window's config, dev ones too, that has
  // a NOTICES or LICENSE file.
  final windowPackages = {
    for (final MapEntry(key: name, value: root) in _packageRoots('.').entries)
      if ([
        'NOTICES',
        'LICENSE',
      ].any((file) => File.fromUri(root.resolve(file)).existsSync()))
        name,
  };
  final agentRuntime = await _runtimePackages('packages/agent');
  final names = agentRuntime.difference(windowPackages).toList()..sort();

  final licences = [
    for (final name in names)
      {
        'package': name,
        'licence': _licence(
          name,
          agentPackages[name] ??
              (throw StateError(
                '$name is missing from packages/agent; run pub get there',
              )),
        ),
      },
  ];
  File(_output).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(licences)}\n',
  );
  stdout.writeln('Wrote ${licences.length} licences to $_output');
}

// What [directory]'s code runs with: not its dev packages, nor this repo's.
Future<Set<String>> _runtimePackages(String directory) async {
  final result = await Process.run(Platform.resolvedExecutable, [
    'pub',
    'deps',
    '--json',
  ], workingDirectory: directory);
  if (result.exitCode != 0) {
    throw ProcessException('dart', ['pub', 'deps'], '${result.stderr}');
  }

  final packages = {
    for (final package
        in (jsonDecode('${result.stdout}') as Map)['packages'] as List)
      (package as Map)['name'] as String: package,
  };
  final root = packages.values.firstWhere(
    (package) => package['kind'] == 'root',
  );
  final seen = <String>{};
  final waiting = [...(root['directDependencies'] as List).cast<String>()];
  while (waiting.isNotEmpty) {
    final name = waiting.removeLast();
    if (packages[name] case final package? when seen.add(name)) {
      waiting.addAll((package['dependencies'] as List).cast<String>());
    }
  }
  return {
    for (final name in seen)
      if (packages[name]!['source'] != 'path') name,
  };
}

Map<String, Uri> _packageRoots(String directory) {
  final config = File('$directory/.dart_tool/package_config.json');
  final base = config.parent.uri;
  return {
    for (final package
        in (jsonDecode(config.readAsStringSync()) as Map)['packages'] as List)
      (package as Map)['name'] as String: base.resolve(
        '${package['rootUri']}/',
      ),
  };
}

String _licence(String name, Uri root) {
  for (final file in _licenceFiles) {
    final licence = File.fromUri(root.resolve(file));
    if (licence.existsSync()) return licence.readAsStringSync().trim();
  }
  throw StateError('$name has no licence file in ${root.toFilePath()}');
}
