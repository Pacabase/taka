import 'package:core/src/tunnel_book.dart';

/// The saved tunnels and the ids of those that were on.
typedef SavedTunnels = ({TunnelBook book, Set<String> on});

abstract interface class TunnelStore {
  Future<SavedTunnels> load();

  Future<void> save(TunnelBook book, {required Set<String> on});
}
