import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:taka/pages/tunnels/tunnels_bloc.dart';

part 'tunnels_screen_cubit.freezed.dart';

@freezed
sealed class TunnelsScreen with _$TunnelsScreen {
  const factory list() = ListScreen;

  const factory newTunnel(TunnelKind kind) = NewTunnelScreen;

  const factory editTunnel(Tunnel tunnel) = EditTunnelScreen;

  const factory editGroup(String group, TunnelColour? colour) = EditGroupScreen;
}

/// [requests] counts the tray's requests it opened a form for, each of which
/// brings the tunnels window to the front of its own dialogs and pages.
@freezed
sealed class TunnelsScreenState with _$TunnelsScreenState {
  const factory({
    @Default(ListScreen()) TunnelsScreen screen,
    @Default(<String>[]) List<String> hosts,
    @Default(0) int requests,
  }) = _TunnelsScreenState;
}

/// Which screen the tunnels window shows, and the SSH hosts its form offers.
class TunnelsScreenCubit({
  required final TunnelsBloc tunnels,
  required final Stream<OpenTunnel> tunnelRequests,
  final Future<List<String>> Function() sshHosts = configuredSshHosts,
}) extends Cubit<TunnelsScreenState> {
  late final StreamSubscription<TunnelsState> _snapshots;
  late final StreamSubscription<OpenTunnel> _requests;
  // A window opened from the tray gets the request before its first snapshot.
  OpenTunnel? _early;

  @override
  String toString() => 'TunnelsScreenCubit';

  this : super(const TunnelsScreenState()) {
    _snapshots = tunnels.stream.listen(_changed);
    _requests = tunnelRequests.listen(_requested);
  }

  // Read on every open, so edits to ~/.ssh/config show up.
  void openTunnel([Tunnel? tunnel, TunnelKind kind = TunnelKind.local]) {
    emit(
      state.copyWith(
        screen: switch (tunnel) {
          final tunnel? => EditTunnelScreen(tunnel),
          null => NewTunnelScreen(kind),
        },
      ),
    );
    unawaited(
      sshHosts().then((hosts) {
        if (!isClosed) emit(state.copyWith(hosts: hosts));
      }),
    );
  }

  void editGroup(String group, TunnelColour? colour) =>
      emit(state.copyWith(screen: EditGroupScreen(group, colour)));

  void closeForm() => emit(state.copyWith(screen: const ListScreen()));

  void _requested(OpenTunnel request) {
    if (tunnels.state case Ready(:final snapshot)) {
      _open(snapshot, request);
    } else {
      _early = request;
    }
  }

  void _changed(TunnelsState tunnels) {
    if (tunnels case Ready(:final snapshot)) {
      if (_early case final request?) {
        _early = null;
        _open(snapshot, request);
      }
      // A group whose tunnels went, from the tray say, has nothing to edit.
      if (state.screen case EditGroupScreen(:final group)
          when !snapshot.tunnels.groups.contains(group)) {
        closeForm();
      }
    }
  }

  void _open(TunnelsSnapshot snapshot, OpenTunnel request) {
    final tunnel = snapshot.tunnels
        .where((tunnel) => tunnel.id == request.id)
        .firstOrNull;
    if (request.id != null && tunnel == null) return;

    emit(state.copyWith(requests: state.requests + 1));
    openTunnel(tunnel);
  }

  @override
  Future<void> close() async {
    await _snapshots.cancel();
    await _requests.cancel();
    return super.close();
  }
}
