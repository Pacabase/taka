part of 'tunnels_bloc.dart';

@freezed
sealed class TunnelsState with _$TunnelsState {
  const factory loading() = Loading;

  const factory ready(TunnelsSnapshot snapshot) = Ready;

  const factory closed() = Closed;
}
