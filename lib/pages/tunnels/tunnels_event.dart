part of 'tunnels_bloc.dart';

@freezed
sealed class TunnelsEvent with _$TunnelsEvent {
  const factory started() = Started;

  const factory save(Tunnel tunnel) = Save;

  const factory remove(String id) = Remove;

  const factory toggle(String id) = Toggle;
}
