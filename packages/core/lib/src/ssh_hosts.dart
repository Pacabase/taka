import 'package:system_ssh/system_ssh.dart';

Future<List<String>> configuredSshHosts() =>
    const SystemSshClient().configuredHosts();
