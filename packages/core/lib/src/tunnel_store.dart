import 'package:core/src/tunnel.dart';

abstract interface class TunnelStore {
  /// The saved tunnels, and the ids of those that were on.
  Future<({List<Tunnel> tunnels, Set<String> on})> load();

  Future<void> save(List<Tunnel> tunnels, {required Set<String> on});
}
