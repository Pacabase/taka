// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agent_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AgentMessage {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentMessage);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AgentMessage()';
}


}

/// @nodoc
class $AgentMessageCopyWith<$Res>  {
$AgentMessageCopyWith(AgentMessage _, $Res Function(AgentMessage) __);
}


/// Adds pattern-matching-related methods to [AgentMessage].
extension AgentMessagePatterns on AgentMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AgentIdentity value)?  identity,TResult Function( AgentSnapshot value)?  snapshot,TResult Function( OpenTunnel value)?  openTunnel,TResult Function( SettingsChanged value)?  settings,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AgentIdentity() when identity != null:
return identity(_that);case AgentSnapshot() when snapshot != null:
return snapshot(_that);case OpenTunnel() when openTunnel != null:
return openTunnel(_that);case SettingsChanged() when settings != null:
return settings(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AgentIdentity value)  identity,required TResult Function( AgentSnapshot value)  snapshot,required TResult Function( OpenTunnel value)  openTunnel,required TResult Function( SettingsChanged value)  settings,}){
final _that = this;
switch (_that) {
case AgentIdentity():
return identity(_that);case AgentSnapshot():
return snapshot(_that);case OpenTunnel():
return openTunnel(_that);case SettingsChanged():
return settings(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AgentIdentity value)?  identity,TResult? Function( AgentSnapshot value)?  snapshot,TResult? Function( OpenTunnel value)?  openTunnel,TResult? Function( SettingsChanged value)?  settings,}){
final _that = this;
switch (_that) {
case AgentIdentity() when identity != null:
return identity(_that);case AgentSnapshot() when snapshot != null:
return snapshot(_that);case OpenTunnel() when openTunnel != null:
return openTunnel(_that);case SettingsChanged() when settings != null:
return settings(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String identity)?  identity,TResult Function( TunnelsSnapshot snapshot)?  snapshot,TResult Function( String? id)?  openTunnel,TResult Function( AgentSettings settings)?  settings,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AgentIdentity() when identity != null:
return identity(_that.identity);case AgentSnapshot() when snapshot != null:
return snapshot(_that.snapshot);case OpenTunnel() when openTunnel != null:
return openTunnel(_that.id);case SettingsChanged() when settings != null:
return settings(_that.settings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String identity)  identity,required TResult Function( TunnelsSnapshot snapshot)  snapshot,required TResult Function( String? id)  openTunnel,required TResult Function( AgentSettings settings)  settings,}) {final _that = this;
switch (_that) {
case AgentIdentity():
return identity(_that.identity);case AgentSnapshot():
return snapshot(_that.snapshot);case OpenTunnel():
return openTunnel(_that.id);case SettingsChanged():
return settings(_that.settings);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String identity)?  identity,TResult? Function( TunnelsSnapshot snapshot)?  snapshot,TResult? Function( String? id)?  openTunnel,TResult? Function( AgentSettings settings)?  settings,}) {final _that = this;
switch (_that) {
case AgentIdentity() when identity != null:
return identity(_that.identity);case AgentSnapshot() when snapshot != null:
return snapshot(_that.snapshot);case OpenTunnel() when openTunnel != null:
return openTunnel(_that.id);case SettingsChanged() when settings != null:
return settings(_that.settings);case _:
  return null;

}
}

}

/// @nodoc


class AgentIdentity extends AgentMessage {
  const AgentIdentity(this.identity): super._();
  

 final  String identity;

/// Create a copy of AgentMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgentIdentityCopyWith<AgentIdentity> get copyWith => _$AgentIdentityCopyWithImpl<AgentIdentity>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentIdentity&&(identical(other.identity, identity) || other.identity == identity));
}


@override
int get hashCode {
    return Object.hash(runtimeType,identity);
}

@override
String toString() {
    return 'AgentMessage.identity(identity: $identity)';
}


}

/// @nodoc
abstract mixin class $AgentIdentityCopyWith<$Res> implements $AgentMessageCopyWith<$Res> {
  factory $AgentIdentityCopyWith(AgentIdentity value, $Res Function(AgentIdentity) _then) = _$AgentIdentityCopyWithImpl;
@useResult
$Res call({
 String identity
});




}
/// @nodoc
class _$AgentIdentityCopyWithImpl<$Res>
    implements $AgentIdentityCopyWith<$Res> {
  _$AgentIdentityCopyWithImpl(this._self, this._then);

  final AgentIdentity _self;
  final $Res Function(AgentIdentity) _then;

/// Create a copy of AgentMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? identity = null,}) {
  return _then(AgentIdentity(
null == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AgentSnapshot extends AgentMessage {
  const AgentSnapshot(this.snapshot): super._();
  

 final  TunnelsSnapshot snapshot;

/// Create a copy of AgentMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgentSnapshotCopyWith<AgentSnapshot> get copyWith => _$AgentSnapshotCopyWithImpl<AgentSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentSnapshot&&(identical(other.snapshot, snapshot) || other.snapshot == snapshot));
}


@override
int get hashCode {
    return Object.hash(runtimeType,snapshot);
}

@override
String toString() {
    return 'AgentMessage.snapshot(snapshot: $snapshot)';
}


}

/// @nodoc
abstract mixin class $AgentSnapshotCopyWith<$Res> implements $AgentMessageCopyWith<$Res> {
  factory $AgentSnapshotCopyWith(AgentSnapshot value, $Res Function(AgentSnapshot) _then) = _$AgentSnapshotCopyWithImpl;
@useResult
$Res call({
 TunnelsSnapshot snapshot
});


$TunnelsSnapshotCopyWith<$Res> get snapshot;

}
/// @nodoc
class _$AgentSnapshotCopyWithImpl<$Res>
    implements $AgentSnapshotCopyWith<$Res> {
  _$AgentSnapshotCopyWithImpl(this._self, this._then);

  final AgentSnapshot _self;
  final $Res Function(AgentSnapshot) _then;

/// Create a copy of AgentMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? snapshot = null,}) {
  return _then(AgentSnapshot(
null == snapshot ? _self.snapshot : snapshot // ignore: cast_nullable_to_non_nullable
as TunnelsSnapshot,
  ));
}

/// Create a copy of AgentMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TunnelsSnapshotCopyWith<$Res> get snapshot {
  
  return $TunnelsSnapshotCopyWith<$Res>(_self.snapshot, (value) {
    return _then(_self.copyWith(snapshot: value));
  });
}
}

/// @nodoc


class OpenTunnel extends AgentMessage {
  const OpenTunnel([this.id]): super._();
  

 final  String? id;

/// Create a copy of AgentMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenTunnelCopyWith<OpenTunnel> get copyWith => _$OpenTunnelCopyWithImpl<OpenTunnel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenTunnel&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id);
}

@override
String toString() {
    return 'AgentMessage.openTunnel(id: $id)';
}


}

/// @nodoc
abstract mixin class $OpenTunnelCopyWith<$Res> implements $AgentMessageCopyWith<$Res> {
  factory $OpenTunnelCopyWith(OpenTunnel value, $Res Function(OpenTunnel) _then) = _$OpenTunnelCopyWithImpl;
@useResult
$Res call({
 String? id
});




}
/// @nodoc
class _$OpenTunnelCopyWithImpl<$Res>
    implements $OpenTunnelCopyWith<$Res> {
  _$OpenTunnelCopyWithImpl(this._self, this._then);

  final OpenTunnel _self;
  final $Res Function(OpenTunnel) _then;

/// Create a copy of AgentMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = freezed,}) {
  return _then(OpenTunnel(
freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class SettingsChanged extends AgentMessage {
  const SettingsChanged(this.settings): super._();
  

 final  AgentSettings settings;

/// Create a copy of AgentMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsChangedCopyWith<SettingsChanged> get copyWith => _$SettingsChangedCopyWithImpl<SettingsChanged>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsChanged&&(identical(other.settings, settings) || other.settings == settings));
}


@override
int get hashCode {
    return Object.hash(runtimeType,settings);
}

@override
String toString() {
    return 'AgentMessage.settings(settings: $settings)';
}


}

/// @nodoc
abstract mixin class $SettingsChangedCopyWith<$Res> implements $AgentMessageCopyWith<$Res> {
  factory $SettingsChangedCopyWith(SettingsChanged value, $Res Function(SettingsChanged) _then) = _$SettingsChangedCopyWithImpl;
@useResult
$Res call({
 AgentSettings settings
});


$AgentSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class _$SettingsChangedCopyWithImpl<$Res>
    implements $SettingsChangedCopyWith<$Res> {
  _$SettingsChangedCopyWithImpl(this._self, this._then);

  final SettingsChanged _self;
  final $Res Function(SettingsChanged) _then;

/// Create a copy of AgentMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? settings = null,}) {
  return _then(SettingsChanged(
null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as AgentSettings,
  ));
}

/// Create a copy of AgentMessage
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
