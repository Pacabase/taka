import 'package:core/src/tunnel.dart';
import 'package:core/src/tunnel_colour.dart';

/// The saved tunnels, the ids of those that were on, and each group's colour.
typedef SavedTunnels = ({
  List<Tunnel> tunnels,
  Set<String> on,
  Map<String, TunnelColour> groupColours,
});

abstract interface class TunnelStore {
  Future<SavedTunnels> load();

  Future<void> save(
    List<Tunnel> tunnels, {
    required Set<String> on,
    Map<String, TunnelColour> groupColours = const {},
  });
}
