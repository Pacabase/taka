import 'package:taka_core/src/tunnel.dart';

abstract interface class TunnelStore {
  Future<List<Tunnel>> load();

  /// Replaces the saved tunnels, in order.
  Future<void> save(List<Tunnel> tunnels);
}
