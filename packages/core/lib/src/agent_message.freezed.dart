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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AgentIdentity value)?  identity,TResult Function( AgentSnapshot value)?  snapshot,TResult Function( ShowAbout value)?  showAbout,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AgentIdentity() when identity != null:
return identity(_that);case AgentSnapshot() when snapshot != null:
return snapshot(_that);case ShowAbout() when showAbout != null:
return showAbout(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AgentIdentity value)  identity,required TResult Function( AgentSnapshot value)  snapshot,required TResult Function( ShowAbout value)  showAbout,}){
final _that = this;
switch (_that) {
case AgentIdentity():
return identity(_that);case AgentSnapshot():
return snapshot(_that);case ShowAbout():
return showAbout(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AgentIdentity value)?  identity,TResult? Function( AgentSnapshot value)?  snapshot,TResult? Function( ShowAbout value)?  showAbout,}){
final _that = this;
switch (_that) {
case AgentIdentity() when identity != null:
return identity(_that);case AgentSnapshot() when snapshot != null:
return snapshot(_that);case ShowAbout() when showAbout != null:
return showAbout(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String identity)?  identity,TResult Function( TunnelsSnapshot snapshot)?  snapshot,TResult Function()?  showAbout,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AgentIdentity() when identity != null:
return identity(_that.identity);case AgentSnapshot() when snapshot != null:
return snapshot(_that.snapshot);case ShowAbout() when showAbout != null:
return showAbout();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String identity)  identity,required TResult Function( TunnelsSnapshot snapshot)  snapshot,required TResult Function()  showAbout,}) {final _that = this;
switch (_that) {
case AgentIdentity():
return identity(_that.identity);case AgentSnapshot():
return snapshot(_that.snapshot);case ShowAbout():
return showAbout();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String identity)?  identity,TResult? Function( TunnelsSnapshot snapshot)?  snapshot,TResult? Function()?  showAbout,}) {final _that = this;
switch (_that) {
case AgentIdentity() when identity != null:
return identity(_that.identity);case AgentSnapshot() when snapshot != null:
return snapshot(_that.snapshot);case ShowAbout() when showAbout != null:
return showAbout();case _:
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


class ShowAbout extends AgentMessage {
  const ShowAbout(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ShowAbout);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AgentMessage.showAbout()';
}


}




// dart format on
