// Writes assets/agent_licences.json: the licences of the packages the
// background helper ships that the window doesn't, which Flutter collects for
// the window alone. Run from the repo root with `fvm dart run tool/agent_licences.dart`.
import 'dart:convert';
import 'dart:io';

const _output = 'assets/agent_licences.json';
const _licenceFiles = ['LICENSE', 'LICENSE.md', 'LICENSE.txt', 'COPYING'];

Future<void> main() async {
  final agent = await _runtimePackages('packages/agent');
  final window = await _runtimePackages('.');
  final locations = _packageLocations('packages/agent');

  final licences = [
    for (final name in agent.difference(window).toList()..sort())
      if (locations[name] case final location?)
        {'package': name, 'licence': _licence(name, location)},
  ];
  File(_output).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(licences)}\n',
  );
  stdout.writeln('Wrote ${licences.length} licences to $_output');
}

// The packages [directory]'s code runs with, leaving out dev ones and this
// repo's own path packages.
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

Map<String, Directory> _packageLocations(String directory) {
  final config = File('$directory/.dart_tool/package_config.json');
  final base = config.parent.uri;
  return {
    for (final package
        in (jsonDecode(config.readAsStringSync()) as Map)['packages'] as List)
      (package as Map)['name'] as String: Directory.fromUri(
        base.resolve('${package['rootUri']}/'),
      ),
  };
}

String _licence(String name, Directory location) {
  for (final file in _licenceFiles) {
    final licence = File('${location.path}$file');
    if (licence.existsSync()) return licence.readAsStringSync().trim();
  }
  throw StateError('$name has no licence file in ${location.path}');
}
