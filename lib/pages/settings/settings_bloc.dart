import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_bloc.freezed.dart';
part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc({required AgentClient agent})
    extends Bloc<SettingsEvent, SettingsState> {
  @override
  String toString() => 'SettingsBloc';

  this : super(const Loading()) {
    on<Started>(
      (event, emit) => emit.forEach(agent.settings, onData: Ready.new),
    );

    on<Send>((event, emit) => agent.send(event.command));
  }
}
