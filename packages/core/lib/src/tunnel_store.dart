import 'package:core/src/tunnel.dart';

abstract interface class TunnelStore {
  Future<List<Tunnel>> load();

  Future<void> save(List<Tunnel> tunnels);
}
