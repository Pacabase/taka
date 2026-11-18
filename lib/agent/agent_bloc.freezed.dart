// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agent_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AgentEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AgentEvent()';
}


}

/// @nodoc
class $AgentEventCopyWith<$Res>  {
$AgentEventCopyWith(AgentEvent _, $Res Function(AgentEvent) __);
}


/// Adds pattern-matching-related methods to [AgentEvent].
extension AgentEventPatterns on AgentEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ConnectAgent value)?  connect,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ConnectAgent() when connect != null:
return connect(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ConnectAgent value)  connect,}){
final _that = this;
switch (_that) {
case ConnectAgent():
return connect(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ConnectAgent value)?  connect,}){
final _that = this;
switch (_that) {
case ConnectAgent() when connect != null:
return connect(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  connect,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ConnectAgent() when connect != null:
return connect();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  connect,}) {final _that = this;
switch (_that) {
case ConnectAgent():
return connect();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  connect,}) {final _that = this;
switch (_that) {
case ConnectAgent() when connect != null:
return connect();case _:
  return null;

}
}

}

/// @nodoc


class ConnectAgent implements AgentEvent {
  const ConnectAgent();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectAgent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AgentEvent.connect()';
}


}




/// @nodoc
mixin _$AgentState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AgentState()';
}


}

/// @nodoc
class $AgentStateCopyWith<$Res>  {
$AgentStateCopyWith(AgentState _, $Res Function(AgentState) __);
}


/// Adds pattern-matching-related methods to [AgentState].
extension AgentStatePatterns on AgentState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AgentConnecting value)?  connecting,TResult Function( AgentFailed value)?  failed,TResult Function( AgentConnected value)?  connected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AgentConnecting() when connecting != null:
return connecting(_that);case AgentFailed() when failed != null:
return failed(_that);case AgentConnected() when connected != null:
return connected(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AgentConnecting value)  connecting,required TResult Function( AgentFailed value)  failed,required TResult Function( AgentConnected value)  connected,}){
final _that = this;
switch (_that) {
case AgentConnecting():
return connecting(_that);case AgentFailed():
return failed(_that);case AgentConnected():
return connected(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AgentConnecting value)?  connecting,TResult? Function( AgentFailed value)?  failed,TResult? Function( AgentConnected value)?  connected,}){
final _that = this;
switch (_that) {
case AgentConnecting() when connecting != null:
return connecting(_that);case AgentFailed() when failed != null:
return failed(_that);case AgentConnected() when connected != null:
return connected(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  connecting,TResult Function( Object error)?  failed,TResult Function( AgentClient agent,  SettingsBloc settings)?  connected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AgentConnecting() when connecting != null:
return connecting();case AgentFailed() when failed != null:
return failed(_that.error);case AgentConnected() when connected != null:
return connected(_that.agent,_that.settings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  connecting,required TResult Function( Object error)  failed,required TResult Function( AgentClient agent,  SettingsBloc settings)  connected,}) {final _that = this;
switch (_that) {
case AgentConnecting():
return connecting();case AgentFailed():
return failed(_that.error);case AgentConnected():
return connected(_that.agent,_that.settings);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  connecting,TResult? Function( Object error)?  failed,TResult? Function( AgentClient agent,  SettingsBloc settings)?  connected,}) {final _that = this;
switch (_that) {
case AgentConnecting() when connecting != null:
return connecting();case AgentFailed() when failed != null:
return failed(_that.error);case AgentConnected() when connected != null:
return connected(_that.agent,_that.settings);case _:
  return null;

}
}

}

/// @nodoc


class AgentConnecting implements AgentState {
  const AgentConnecting();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentConnecting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AgentState.connecting()';
}


}




/// @nodoc


class AgentFailed implements AgentState {
  const AgentFailed(this.error);
  

 final  Object error;

/// Create a copy of AgentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgentFailedCopyWith<AgentFailed> get copyWith => _$AgentFailedCopyWithImpl<AgentFailed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentFailed&&const DeepCollectionEquality().equals(other.error, error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(error));
}

@override
String toString() {
    return 'AgentState.failed(error: $error)';
}


}

/// @nodoc
abstract mixin class $AgentFailedCopyWith<$Res> implements $AgentStateCopyWith<$Res> {
  factory $AgentFailedCopyWith(AgentFailed value, $Res Function(AgentFailed) _then) = _$AgentFailedCopyWithImpl;
@useResult
$Res call({
 Object error
});




}
/// @nodoc
class _$AgentFailedCopyWithImpl<$Res>
    implements $AgentFailedCopyWith<$Res> {
  _$AgentFailedCopyWithImpl(this._self, this._then);

  final AgentFailed _self;
  final $Res Function(AgentFailed) _then;

/// Create a copy of AgentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(AgentFailed(
null == error ? _self.error : error ,
  ));
}


}

/// @nodoc


class AgentConnected implements AgentState {
  const AgentConnected(this.agent, this.settings);
  

 final  AgentClient agent;
 final  SettingsBloc settings;

/// Create a copy of AgentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgentConnectedCopyWith<AgentConnected> get copyWith => _$AgentConnectedCopyWithImpl<AgentConnected>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentConnected&&(identical(other.agent, agent) || other.agent == agent)&&(identical(other.settings, settings) || other.settings == settings));
}


@override
int get hashCode {
    return Object.hash(runtimeType,agent,settings);
}

@override
String toString() {
    return 'AgentState.connected(agent: $agent, settings: $settings)';
}


}

/// @nodoc
abstract mixin class $AgentConnectedCopyWith<$Res> implements $AgentStateCopyWith<$Res> {
  factory $AgentConnectedCopyWith(AgentConnected value, $Res Function(AgentConnected) _then) = _$AgentConnectedCopyWithImpl;
@useResult
$Res call({
 AgentClient agent, SettingsBloc settings
});




}
/// @nodoc
class _$AgentConnectedCopyWithImpl<$Res>
    implements $AgentConnectedCopyWith<$Res> {
  _$AgentConnectedCopyWithImpl(this._self, this._then);

  final AgentConnected _self;
  final $Res Function(AgentConnected) _then;

/// Create a copy of AgentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? agent = null,Object? settings = null,}) {
  return _then(AgentConnected(
null == agent ? _self.agent : agent // ignore: cast_nullable_to_non_nullable
as AgentClient,null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as SettingsBloc,
  ));
}


}

// dart format on
