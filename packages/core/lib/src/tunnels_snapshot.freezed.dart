// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tunnels_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TunnelStatus {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TunnelStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'TunnelStatus()';
}


}

/// @nodoc
class $TunnelStatusCopyWith<$Res>  {
$TunnelStatusCopyWith(TunnelStatus _, $Res Function(TunnelStatus) __);
}


/// Adds pattern-matching-related methods to [TunnelStatus].
extension TunnelStatusPatterns on TunnelStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Stopped value)?  stopped,TResult Function( Connecting value)?  connecting,TResult Function( Connected value)?  connected,TResult Function( Failed value)?  failed,TResult Function( Reconnecting value)?  reconnecting,TResult Function( UnknownHostKey value)?  unknownHostKey,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Stopped() when stopped != null:
return stopped(_that);case Connecting() when connecting != null:
return connecting(_that);case Connected() when connected != null:
return connected(_that);case Failed() when failed != null:
return failed(_that);case Reconnecting() when reconnecting != null:
return reconnecting(_that);case UnknownHostKey() when unknownHostKey != null:
return unknownHostKey(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Stopped value)  stopped,required TResult Function( Connecting value)  connecting,required TResult Function( Connected value)  connected,required TResult Function( Failed value)  failed,required TResult Function( Reconnecting value)  reconnecting,required TResult Function( UnknownHostKey value)  unknownHostKey,}){
final _that = this;
switch (_that) {
case Stopped():
return stopped(_that);case Connecting():
return connecting(_that);case Connected():
return connected(_that);case Failed():
return failed(_that);case Reconnecting():
return reconnecting(_that);case UnknownHostKey():
return unknownHostKey(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Stopped value)?  stopped,TResult? Function( Connecting value)?  connecting,TResult? Function( Connected value)?  connected,TResult? Function( Failed value)?  failed,TResult? Function( Reconnecting value)?  reconnecting,TResult? Function( UnknownHostKey value)?  unknownHostKey,}){
final _that = this;
switch (_that) {
case Stopped() when stopped != null:
return stopped(_that);case Connecting() when connecting != null:
return connecting(_that);case Connected() when connected != null:
return connected(_that);case Failed() when failed != null:
return failed(_that);case Reconnecting() when reconnecting != null:
return reconnecting(_that);case UnknownHostKey() when unknownHostKey != null:
return unknownHostKey(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  stopped,TResult Function()?  connecting,TResult Function( String warning)?  connected,TResult Function( String message)?  failed,TResult Function( String reason)?  reconnecting,TResult Function( String host,  String type,  String fingerprint)?  unknownHostKey,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Stopped() when stopped != null:
return stopped();case Connecting() when connecting != null:
return connecting();case Connected() when connected != null:
return connected(_that.warning);case Failed() when failed != null:
return failed(_that.message);case Reconnecting() when reconnecting != null:
return reconnecting(_that.reason);case UnknownHostKey() when unknownHostKey != null:
return unknownHostKey(_that.host,_that.type,_that.fingerprint);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  stopped,required TResult Function()  connecting,required TResult Function( String warning)  connected,required TResult Function( String message)  failed,required TResult Function( String reason)  reconnecting,required TResult Function( String host,  String type,  String fingerprint)  unknownHostKey,}) {final _that = this;
switch (_that) {
case Stopped():
return stopped();case Connecting():
return connecting();case Connected():
return connected(_that.warning);case Failed():
return failed(_that.message);case Reconnecting():
return reconnecting(_that.reason);case UnknownHostKey():
return unknownHostKey(_that.host,_that.type,_that.fingerprint);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  stopped,TResult? Function()?  connecting,TResult? Function( String warning)?  connected,TResult? Function( String message)?  failed,TResult? Function( String reason)?  reconnecting,TResult? Function( String host,  String type,  String fingerprint)?  unknownHostKey,}) {final _that = this;
switch (_that) {
case Stopped() when stopped != null:
return stopped();case Connecting() when connecting != null:
return connecting();case Connected() when connected != null:
return connected(_that.warning);case Failed() when failed != null:
return failed(_that.message);case Reconnecting() when reconnecting != null:
return reconnecting(_that.reason);case UnknownHostKey() when unknownHostKey != null:
return unknownHostKey(_that.host,_that.type,_that.fingerprint);case _:
  return null;

}
}

}

/// @nodoc


class Stopped extends TunnelStatus {
  const Stopped(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Stopped);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'TunnelStatus.stopped()';
}


}




/// @nodoc


class Connecting extends TunnelStatus {
  const Connecting(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Connecting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'TunnelStatus.connecting()';
}


}




/// @nodoc


class Connected extends TunnelStatus {
  const Connected({this.warning = ''}): super._();
  

@JsonKey() final  String warning;

/// Create a copy of TunnelStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectedCopyWith<Connected> get copyWith => _$ConnectedCopyWithImpl<Connected>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Connected&&(identical(other.warning, warning) || other.warning == warning));
}


@override
int get hashCode {
    return Object.hash(runtimeType,warning);
}

@override
String toString() {
    return 'TunnelStatus.connected(warning: $warning)';
}


}

/// @nodoc
abstract mixin class $ConnectedCopyWith<$Res> implements $TunnelStatusCopyWith<$Res> {
  factory $ConnectedCopyWith(Connected value, $Res Function(Connected) _then) = _$ConnectedCopyWithImpl;
@useResult
$Res call({
 String warning
});




}
/// @nodoc
class _$ConnectedCopyWithImpl<$Res>
    implements $ConnectedCopyWith<$Res> {
  _$ConnectedCopyWithImpl(this._self, this._then);

  final Connected _self;
  final $Res Function(Connected) _then;

/// Create a copy of TunnelStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? warning = null,}) {
  return _then(Connected(
warning: null == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class Failed extends TunnelStatus {
  const Failed(this.message): super._();
  

 final  String message;

/// Create a copy of TunnelStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FailedCopyWith<Failed> get copyWith => _$FailedCopyWithImpl<Failed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Failed&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'TunnelStatus.failed(message: $message)';
}


}

/// @nodoc
abstract mixin class $FailedCopyWith<$Res> implements $TunnelStatusCopyWith<$Res> {
  factory $FailedCopyWith(Failed value, $Res Function(Failed) _then) = _$FailedCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$FailedCopyWithImpl<$Res>
    implements $FailedCopyWith<$Res> {
  _$FailedCopyWithImpl(this._self, this._then);

  final Failed _self;
  final $Res Function(Failed) _then;

/// Create a copy of TunnelStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(Failed(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class Reconnecting extends TunnelStatus {
  const Reconnecting(this.reason): super._();
  

 final  String reason;

/// Create a copy of TunnelStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReconnectingCopyWith<Reconnecting> get copyWith => _$ReconnectingCopyWithImpl<Reconnecting>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Reconnecting&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'TunnelStatus.reconnecting(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $ReconnectingCopyWith<$Res> implements $TunnelStatusCopyWith<$Res> {
  factory $ReconnectingCopyWith(Reconnecting value, $Res Function(Reconnecting) _then) = _$ReconnectingCopyWithImpl;
@useResult
$Res call({
 String reason
});




}
/// @nodoc
class _$ReconnectingCopyWithImpl<$Res>
    implements $ReconnectingCopyWith<$Res> {
  _$ReconnectingCopyWithImpl(this._self, this._then);

  final Reconnecting _self;
  final $Res Function(Reconnecting) _then;

/// Create a copy of TunnelStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(Reconnecting(
null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UnknownHostKey extends TunnelStatus {
  const UnknownHostKey({required this.host, required this.type, required this.fingerprint}): super._();
  

 final  String host;
 final  String type;
 final  String fingerprint;

/// Create a copy of TunnelStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnknownHostKeyCopyWith<UnknownHostKey> get copyWith => _$UnknownHostKeyCopyWithImpl<UnknownHostKey>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UnknownHostKey&&(identical(other.host, host) || other.host == host)&&(identical(other.type, type) || other.type == type)&&(identical(other.fingerprint, fingerprint) || other.fingerprint == fingerprint));
}


@override
int get hashCode {
    return Object.hash(runtimeType,host,type,fingerprint);
}

@override
String toString() {
    return 'TunnelStatus.unknownHostKey(host: $host, type: $type, fingerprint: $fingerprint)';
}


}

/// @nodoc
abstract mixin class $UnknownHostKeyCopyWith<$Res> implements $TunnelStatusCopyWith<$Res> {
  factory $UnknownHostKeyCopyWith(UnknownHostKey value, $Res Function(UnknownHostKey) _then) = _$UnknownHostKeyCopyWithImpl;
@useResult
$Res call({
 String host, String type, String fingerprint
});




}
/// @nodoc
class _$UnknownHostKeyCopyWithImpl<$Res>
    implements $UnknownHostKeyCopyWith<$Res> {
  _$UnknownHostKeyCopyWithImpl(this._self, this._then);

  final UnknownHostKey _self;
  final $Res Function(UnknownHostKey) _then;

/// Create a copy of TunnelStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? host = null,Object? type = null,Object? fingerprint = null,}) {
  return _then(UnknownHostKey(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,fingerprint: null == fingerprint ? _self.fingerprint : fingerprint // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$TunnelsSnapshot {

 List<Tunnel> get tunnels; Map<String, TunnelStatus> get statuses;
/// Create a copy of TunnelsSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TunnelsSnapshotCopyWith<TunnelsSnapshot> get copyWith => _$TunnelsSnapshotCopyWithImpl<TunnelsSnapshot>(this as TunnelsSnapshot, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TunnelsSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TunnelsSnapshot&&const DeepCollectionEquality().equals(other.tunnels, _this.tunnels)&&const DeepCollectionEquality().equals(other.statuses, _this.statuses));
}


@override
int get hashCode {
  final _this = this as TunnelsSnapshot;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.tunnels),const DeepCollectionEquality().hash(_this.statuses));
}

@override
String toString() {
  final _this = this as TunnelsSnapshot;
  return 'TunnelsSnapshot(tunnels: ${_this.tunnels}, statuses: ${_this.statuses})';
}


}

/// @nodoc
abstract mixin class $TunnelsSnapshotCopyWith<$Res>  {
  factory $TunnelsSnapshotCopyWith(TunnelsSnapshot value, $Res Function(TunnelsSnapshot) _then) = _$TunnelsSnapshotCopyWithImpl;
@useResult
$Res call({
 List<Tunnel> tunnels, Map<String, TunnelStatus> statuses
});




}
/// @nodoc
class _$TunnelsSnapshotCopyWithImpl<$Res>
    implements $TunnelsSnapshotCopyWith<$Res> {
  _$TunnelsSnapshotCopyWithImpl(this._self, this._then);

  final TunnelsSnapshot _self;
  final $Res Function(TunnelsSnapshot) _then;

/// Create a copy of TunnelsSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tunnels = null,Object? statuses = null,}) {
  return _then(TunnelsSnapshot(
tunnels: null == tunnels ? _self.tunnels : tunnels // ignore: cast_nullable_to_non_nullable
as List<Tunnel>,statuses: null == statuses ? _self.statuses : statuses // ignore: cast_nullable_to_non_nullable
as Map<String, TunnelStatus>,
  ));
}

}


/// Adds pattern-matching-related methods to [TunnelsSnapshot].
extension TunnelsSnapshotPatterns on TunnelsSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TunnelsSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TunnelsSnapshot() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TunnelsSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _TunnelsSnapshot():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TunnelsSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _TunnelsSnapshot() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Tunnel> tunnels,  Map<String, TunnelStatus> statuses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TunnelsSnapshot() when $default != null:
return $default(_that.tunnels,_that.statuses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Tunnel> tunnels,  Map<String, TunnelStatus> statuses)  $default,) {final _that = this;
switch (_that) {
case _TunnelsSnapshot():
return $default(_that.tunnels,_that.statuses);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Tunnel> tunnels,  Map<String, TunnelStatus> statuses)?  $default,) {final _that = this;
switch (_that) {
case _TunnelsSnapshot() when $default != null:
return $default(_that.tunnels,_that.statuses);case _:
  return null;

}
}

}

/// @nodoc


class _TunnelsSnapshot extends TunnelsSnapshot {
  const _TunnelsSnapshot({ List<Tunnel> tunnels = const [],  Map<String, TunnelStatus> statuses = const {}}): _tunnels = tunnels,_statuses = statuses,super._();
  

 final  List<Tunnel> _tunnels;
@override@JsonKey() List<Tunnel> get tunnels {
  if (_tunnels is EqualUnmodifiableListView) return _tunnels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tunnels);
}

 final  Map<String, TunnelStatus> _statuses;
@override@JsonKey() Map<String, TunnelStatus> get statuses {
  if (_statuses is EqualUnmodifiableMapView) return _statuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_statuses);
}


/// Create a copy of TunnelsSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TunnelsSnapshotCopyWith<_TunnelsSnapshot> get copyWith => __$TunnelsSnapshotCopyWithImpl<_TunnelsSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TunnelsSnapshot&&const DeepCollectionEquality().equals(other.tunnels, _tunnels)&&const DeepCollectionEquality().equals(other.statuses, _statuses));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_tunnels),const DeepCollectionEquality().hash(_statuses));
}

@override
String toString() {
    return 'TunnelsSnapshot(tunnels: $tunnels, statuses: $statuses)';
}


}

/// @nodoc
abstract mixin class _$TunnelsSnapshotCopyWith<$Res> implements $TunnelsSnapshotCopyWith<$Res> {
  factory _$TunnelsSnapshotCopyWith(_TunnelsSnapshot value, $Res Function(_TunnelsSnapshot) _then) = __$TunnelsSnapshotCopyWithImpl;
@override @useResult
$Res call({
 List<Tunnel> tunnels, Map<String, TunnelStatus> statuses
});




}
/// @nodoc
class __$TunnelsSnapshotCopyWithImpl<$Res>
    implements _$TunnelsSnapshotCopyWith<$Res> {
  __$TunnelsSnapshotCopyWithImpl(this._self, this._then);

  final _TunnelsSnapshot _self;
  final $Res Function(_TunnelsSnapshot) _then;

/// Create a copy of TunnelsSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tunnels = null,Object? statuses = null,}) {
  return _then(_TunnelsSnapshot(
tunnels: null == tunnels ? _self._tunnels : tunnels // ignore: cast_nullable_to_non_nullable
as List<Tunnel>,statuses: null == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as Map<String, TunnelStatus>,
  ));
}


}

// dart format on
