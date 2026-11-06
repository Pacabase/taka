// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SettingsEvent()';
}


}

/// @nodoc
class $SettingsEventCopyWith<$Res>  {
$SettingsEventCopyWith(SettingsEvent _, $Res Function(SettingsEvent) __);
}


/// Adds pattern-matching-related methods to [SettingsEvent].
extension SettingsEventPatterns on SettingsEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Started value)?  started,TResult Function( Send value)?  send,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Started() when started != null:
return started(_that);case Send() when send != null:
return send(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Started value)  started,required TResult Function( Send value)  send,}){
final _that = this;
switch (_that) {
case Started():
return started(_that);case Send():
return send(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Started value)?  started,TResult? Function( Send value)?  send,}){
final _that = this;
switch (_that) {
case Started() when started != null:
return started(_that);case Send() when send != null:
return send(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function( AgentCommand command)?  send,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Started() when started != null:
return started();case Send() when send != null:
return send(_that.command);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function( AgentCommand command)  send,}) {final _that = this;
switch (_that) {
case Started():
return started();case Send():
return send(_that.command);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function( AgentCommand command)?  send,}) {final _that = this;
switch (_that) {
case Started() when started != null:
return started();case Send() when send != null:
return send(_that.command);case _:
  return null;

}
}

}

/// @nodoc


class Started implements SettingsEvent {
  const Started();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Started);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SettingsEvent.started()';
}


}




/// @nodoc


class Send implements SettingsEvent {
  const Send(this.command);
  

 final  AgentCommand command;

/// Create a copy of SettingsEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendCopyWith<Send> get copyWith => _$SendCopyWithImpl<Send>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Send&&(identical(other.command, command) || other.command == command));
}


@override
int get hashCode {
    return Object.hash(runtimeType,command);
}

@override
String toString() {
    return 'SettingsEvent.send(command: $command)';
}


}

/// @nodoc
abstract mixin class $SendCopyWith<$Res> implements $SettingsEventCopyWith<$Res> {
  factory $SendCopyWith(Send value, $Res Function(Send) _then) = _$SendCopyWithImpl;
@useResult
$Res call({
 AgentCommand command
});


$AgentCommandCopyWith<$Res> get command;

}
/// @nodoc
class _$SendCopyWithImpl<$Res>
    implements $SendCopyWith<$Res> {
  _$SendCopyWithImpl(this._self, this._then);

  final Send _self;
  final $Res Function(Send) _then;

/// Create a copy of SettingsEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? command = null,}) {
  return _then(Send(
null == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as AgentCommand,
  ));
}

/// Create a copy of SettingsEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AgentCommandCopyWith<$Res> get command {
  
  return $AgentCommandCopyWith<$Res>(_self.command, (value) {
    return _then(_self.copyWith(command: value));
  });
}
}

/// @nodoc
mixin _$SettingsState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SettingsState()';
}


}

/// @nodoc
class $SettingsStateCopyWith<$Res>  {
$SettingsStateCopyWith(SettingsState _, $Res Function(SettingsState) __);
}


/// Adds pattern-matching-related methods to [SettingsState].
extension SettingsStatePatterns on SettingsState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Loading value)?  loading,TResult Function( Ready value)?  ready,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Loading() when loading != null:
return loading(_that);case Ready() when ready != null:
return ready(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Loading value)  loading,required TResult Function( Ready value)  ready,}){
final _that = this;
switch (_that) {
case Loading():
return loading(_that);case Ready():
return ready(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Loading value)?  loading,TResult? Function( Ready value)?  ready,}){
final _that = this;
switch (_that) {
case Loading() when loading != null:
return loading(_that);case Ready() when ready != null:
return ready(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( AgentSettings settings)?  ready,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Loading() when loading != null:
return loading();case Ready() when ready != null:
return ready(_that.settings);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( AgentSettings settings)  ready,}) {final _that = this;
switch (_that) {
case Loading():
return loading();case Ready():
return ready(_that.settings);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( AgentSettings settings)?  ready,}) {final _that = this;
switch (_that) {
case Loading() when loading != null:
return loading();case Ready() when ready != null:
return ready(_that.settings);case _:
  return null;

}
}

}

/// @nodoc


class Loading implements SettingsState {
  const Loading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SettingsState.loading()';
}


}




/// @nodoc


class Ready implements SettingsState {
  const Ready(this.settings);
  

 final  AgentSettings settings;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadyCopyWith<Ready> get copyWith => _$ReadyCopyWithImpl<Ready>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Ready&&(identical(other.settings, settings) || other.settings == settings));
}


@override
int get hashCode {
    return Object.hash(runtimeType,settings);
}

@override
String toString() {
    return 'SettingsState.ready(settings: $settings)';
}


}

/// @nodoc
abstract mixin class $ReadyCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory $ReadyCopyWith(Ready value, $Res Function(Ready) _then) = _$ReadyCopyWithImpl;
@useResult
$Res call({
 AgentSettings settings
});


$AgentSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class _$ReadyCopyWithImpl<$Res>
    implements $ReadyCopyWith<$Res> {
  _$ReadyCopyWithImpl(this._self, this._then);

  final Ready _self;
  final $Res Function(Ready) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? settings = null,}) {
  return _then(Ready(
null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as AgentSettings,
  ));
}

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AgentSettingsCopyWith<$Res> get settings {
  
  return $AgentSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}

// dart format on
