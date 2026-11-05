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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SettingsStarted value)?  started,TResult Function( ChangeSetting value)?  change,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SettingsStarted() when started != null:
return started(_that);case ChangeSetting() when change != null:
return change(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SettingsStarted value)  started,required TResult Function( ChangeSetting value)  change,}){
final _that = this;
switch (_that) {
case SettingsStarted():
return started(_that);case ChangeSetting():
return change(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SettingsStarted value)?  started,TResult? Function( ChangeSetting value)?  change,}){
final _that = this;
switch (_that) {
case SettingsStarted() when started != null:
return started(_that);case ChangeSetting() when change != null:
return change(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function( AgentCommand command)?  change,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SettingsStarted() when started != null:
return started();case ChangeSetting() when change != null:
return change(_that.command);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function( AgentCommand command)  change,}) {final _that = this;
switch (_that) {
case SettingsStarted():
return started();case ChangeSetting():
return change(_that.command);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function( AgentCommand command)?  change,}) {final _that = this;
switch (_that) {
case SettingsStarted() when started != null:
return started();case ChangeSetting() when change != null:
return change(_that.command);case _:
  return null;

}
}

}

/// @nodoc


class SettingsStarted implements SettingsEvent {
  const SettingsStarted();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsStarted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SettingsEvent.started()';
}


}




/// @nodoc


class ChangeSetting implements SettingsEvent {
  const ChangeSetting(this.command);
  

 final  AgentCommand command;

/// Create a copy of SettingsEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangeSettingCopyWith<ChangeSetting> get copyWith => _$ChangeSettingCopyWithImpl<ChangeSetting>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangeSetting&&(identical(other.command, command) || other.command == command));
}


@override
int get hashCode {
    return Object.hash(runtimeType,command);
}

@override
String toString() {
    return 'SettingsEvent.change(command: $command)';
}


}

/// @nodoc
abstract mixin class $ChangeSettingCopyWith<$Res> implements $SettingsEventCopyWith<$Res> {
  factory $ChangeSettingCopyWith(ChangeSetting value, $Res Function(ChangeSetting) _then) = _$ChangeSettingCopyWithImpl;
@useResult
$Res call({
 AgentCommand command
});


$AgentCommandCopyWith<$Res> get command;

}
/// @nodoc
class _$ChangeSettingCopyWithImpl<$Res>
    implements $ChangeSettingCopyWith<$Res> {
  _$ChangeSettingCopyWithImpl(this._self, this._then);

  final ChangeSetting _self;
  final $Res Function(ChangeSetting) _then;

/// Create a copy of SettingsEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? command = null,}) {
  return _then(ChangeSetting(
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SettingsLoading value)?  loading,TResult Function( SettingsReady value)?  ready,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SettingsLoading() when loading != null:
return loading(_that);case SettingsReady() when ready != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SettingsLoading value)  loading,required TResult Function( SettingsReady value)  ready,}){
final _that = this;
switch (_that) {
case SettingsLoading():
return loading(_that);case SettingsReady():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SettingsLoading value)?  loading,TResult? Function( SettingsReady value)?  ready,}){
final _that = this;
switch (_that) {
case SettingsLoading() when loading != null:
return loading(_that);case SettingsReady() when ready != null:
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
case SettingsLoading() when loading != null:
return loading();case SettingsReady() when ready != null:
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
case SettingsLoading():
return loading();case SettingsReady():
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
case SettingsLoading() when loading != null:
return loading();case SettingsReady() when ready != null:
return ready(_that.settings);case _:
  return null;

}
}

}

/// @nodoc


class SettingsLoading implements SettingsState {
  const SettingsLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SettingsState.loading()';
}


}




/// @nodoc


class SettingsReady implements SettingsState {
  const SettingsReady(this.settings);
  

 final  AgentSettings settings;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsReadyCopyWith<SettingsReady> get copyWith => _$SettingsReadyCopyWithImpl<SettingsReady>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsReady&&(identical(other.settings, settings) || other.settings == settings));
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
abstract mixin class $SettingsReadyCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory $SettingsReadyCopyWith(SettingsReady value, $Res Function(SettingsReady) _then) = _$SettingsReadyCopyWithImpl;
@useResult
$Res call({
 AgentSettings settings
});


$AgentSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class _$SettingsReadyCopyWithImpl<$Res>
    implements $SettingsReadyCopyWith<$Res> {
  _$SettingsReadyCopyWithImpl(this._self, this._then);

  final SettingsReady _self;
  final $Res Function(SettingsReady) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? settings = null,}) {
  return _then(SettingsReady(
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
