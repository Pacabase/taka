// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tunnel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Tunnel {

 String get id; String get name; TunnelKind get kind; String get sshHost; String? get bindAddress; String? get localHost; int get localPort; String? get remoteHost; int? get remotePort; String? get remoteSocket; String? get group;
/// Create a copy of Tunnel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TunnelCopyWith<Tunnel> get copyWith => _$TunnelCopyWithImpl<Tunnel>(this as Tunnel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Tunnel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tunnel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.sshHost, _this.sshHost) || other.sshHost == _this.sshHost)&&(identical(other.bindAddress, _this.bindAddress) || other.bindAddress == _this.bindAddress)&&(identical(other.localHost, _this.localHost) || other.localHost == _this.localHost)&&(identical(other.localPort, _this.localPort) || other.localPort == _this.localPort)&&(identical(other.remoteHost, _this.remoteHost) || other.remoteHost == _this.remoteHost)&&(identical(other.remotePort, _this.remotePort) || other.remotePort == _this.remotePort)&&(identical(other.remoteSocket, _this.remoteSocket) || other.remoteSocket == _this.remoteSocket)&&(identical(other.group, _this.group) || other.group == _this.group));
}


@override
int get hashCode {
  final _this = this as Tunnel;
  return Object.hash(runtimeType,_this.id,_this.name,_this.kind,_this.sshHost,_this.bindAddress,_this.localHost,_this.localPort,_this.remoteHost,_this.remotePort,_this.remoteSocket,_this.group);
}



}

/// @nodoc
abstract mixin class $TunnelCopyWith<$Res>  {
  factory $TunnelCopyWith(Tunnel value, $Res Function(Tunnel) _then) = _$TunnelCopyWithImpl;
@useResult
$Res call({
 String id, String name, TunnelKind kind, String sshHost, String? bindAddress, String? localHost, int localPort, String? remoteHost, int? remotePort, String? remoteSocket, String? group
});




}
/// @nodoc
class _$TunnelCopyWithImpl<$Res>
    implements $TunnelCopyWith<$Res> {
  _$TunnelCopyWithImpl(this._self, this._then);

  final Tunnel _self;
  final $Res Function(Tunnel) _then;

/// Create a copy of Tunnel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? kind = null,Object? sshHost = null,Object? bindAddress = freezed,Object? localHost = freezed,Object? localPort = null,Object? remoteHost = freezed,Object? remotePort = freezed,Object? remoteSocket = freezed,Object? group = freezed,}) {
  return _then(Tunnel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TunnelKind,sshHost: null == sshHost ? _self.sshHost : sshHost // ignore: cast_nullable_to_non_nullable
as String,bindAddress: freezed == bindAddress ? _self.bindAddress : bindAddress // ignore: cast_nullable_to_non_nullable
as String?,localHost: freezed == localHost ? _self.localHost : localHost // ignore: cast_nullable_to_non_nullable
as String?,localPort: null == localPort ? _self.localPort : localPort // ignore: cast_nullable_to_non_nullable
as int,remoteHost: freezed == remoteHost ? _self.remoteHost : remoteHost // ignore: cast_nullable_to_non_nullable
as String?,remotePort: freezed == remotePort ? _self.remotePort : remotePort // ignore: cast_nullable_to_non_nullable
as int?,remoteSocket: freezed == remoteSocket ? _self.remoteSocket : remoteSocket // ignore: cast_nullable_to_non_nullable
as String?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Tunnel].
extension TunnelPatterns on Tunnel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Tunnel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Tunnel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Tunnel value)  $default,){
final _that = this;
switch (_that) {
case _Tunnel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Tunnel value)?  $default,){
final _that = this;
switch (_that) {
case _Tunnel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  TunnelKind kind,  String sshHost,  String? bindAddress,  String? localHost,  int localPort,  String? remoteHost,  int? remotePort,  String? remoteSocket,  String? group)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tunnel() when $default != null:
return $default(_that.id,_that.name,_that.kind,_that.sshHost,_that.bindAddress,_that.localHost,_that.localPort,_that.remoteHost,_that.remotePort,_that.remoteSocket,_that.group);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  TunnelKind kind,  String sshHost,  String? bindAddress,  String? localHost,  int localPort,  String? remoteHost,  int? remotePort,  String? remoteSocket,  String? group)  $default,) {final _that = this;
switch (_that) {
case _Tunnel():
return $default(_that.id,_that.name,_that.kind,_that.sshHost,_that.bindAddress,_that.localHost,_that.localPort,_that.remoteHost,_that.remotePort,_that.remoteSocket,_that.group);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  TunnelKind kind,  String sshHost,  String? bindAddress,  String? localHost,  int localPort,  String? remoteHost,  int? remotePort,  String? remoteSocket,  String? group)?  $default,) {final _that = this;
switch (_that) {
case _Tunnel() when $default != null:
return $default(_that.id,_that.name,_that.kind,_that.sshHost,_that.bindAddress,_that.localHost,_that.localPort,_that.remoteHost,_that.remotePort,_that.remoteSocket,_that.group);case _:
  return null;

}
}

}

/// @nodoc


class _Tunnel extends Tunnel {
  const _Tunnel({required this.id, this.name = '', this.kind = TunnelKind.local, this.sshHost = '', this.bindAddress, this.localHost, required this.localPort, this.remoteHost, this.remotePort, this.remoteSocket, this.group}): super._();
  

@override final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  TunnelKind kind;
@override@JsonKey() final  String sshHost;
@override final  String? bindAddress;
@override final  String? localHost;
@override final  int localPort;
@override final  String? remoteHost;
@override final  int? remotePort;
@override final  String? remoteSocket;
@override final  String? group;

/// Create a copy of Tunnel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TunnelCopyWith<_Tunnel> get copyWith => __$TunnelCopyWithImpl<_Tunnel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tunnel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.sshHost, sshHost) || other.sshHost == sshHost)&&(identical(other.bindAddress, bindAddress) || other.bindAddress == bindAddress)&&(identical(other.localHost, localHost) || other.localHost == localHost)&&(identical(other.localPort, localPort) || other.localPort == localPort)&&(identical(other.remoteHost, remoteHost) || other.remoteHost == remoteHost)&&(identical(other.remotePort, remotePort) || other.remotePort == remotePort)&&(identical(other.remoteSocket, remoteSocket) || other.remoteSocket == remoteSocket)&&(identical(other.group, group) || other.group == group));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,kind,sshHost,bindAddress,localHost,localPort,remoteHost,remotePort,remoteSocket,group);
}



}

/// @nodoc
abstract mixin class _$TunnelCopyWith<$Res> implements $TunnelCopyWith<$Res> {
  factory _$TunnelCopyWith(_Tunnel value, $Res Function(_Tunnel) _then) = __$TunnelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, TunnelKind kind, String sshHost, String? bindAddress, String? localHost, int localPort, String? remoteHost, int? remotePort, String? remoteSocket, String? group
});




}
/// @nodoc
class __$TunnelCopyWithImpl<$Res>
    implements _$TunnelCopyWith<$Res> {
  __$TunnelCopyWithImpl(this._self, this._then);

  final _Tunnel _self;
  final $Res Function(_Tunnel) _then;

/// Create a copy of Tunnel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? kind = null,Object? sshHost = null,Object? bindAddress = freezed,Object? localHost = freezed,Object? localPort = null,Object? remoteHost = freezed,Object? remotePort = freezed,Object? remoteSocket = freezed,Object? group = freezed,}) {
  return _then(_Tunnel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TunnelKind,sshHost: null == sshHost ? _self.sshHost : sshHost // ignore: cast_nullable_to_non_nullable
as String,bindAddress: freezed == bindAddress ? _self.bindAddress : bindAddress // ignore: cast_nullable_to_non_nullable
as String?,localHost: freezed == localHost ? _self.localHost : localHost // ignore: cast_nullable_to_non_nullable
as String?,localPort: null == localPort ? _self.localPort : localPort // ignore: cast_nullable_to_non_nullable
as int,remoteHost: freezed == remoteHost ? _self.remoteHost : remoteHost // ignore: cast_nullable_to_non_nullable
as String?,remotePort: freezed == remotePort ? _self.remotePort : remotePort // ignore: cast_nullable_to_non_nullable
as int?,remoteSocket: freezed == remoteSocket ? _self.remoteSocket : remoteSocket // ignore: cast_nullable_to_non_nullable
as String?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
