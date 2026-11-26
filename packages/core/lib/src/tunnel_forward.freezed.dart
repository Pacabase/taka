// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tunnel_forward.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TunnelForward {

 int get localPort;
/// Create a copy of TunnelForward
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TunnelForwardCopyWith<TunnelForward> get copyWith => _$TunnelForwardCopyWithImpl<TunnelForward>(this as TunnelForward, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TunnelForward;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TunnelForward&&(identical(other.localPort, _this.localPort) || other.localPort == _this.localPort));
}


@override
int get hashCode {
  final _this = this as TunnelForward;
  return Object.hash(runtimeType,_this.localPort);
}

@override
String toString() {
  final _this = this as TunnelForward;
  return 'TunnelForward(localPort: ${_this.localPort})';
}


}

/// @nodoc
abstract mixin class $TunnelForwardCopyWith<$Res>  {
  factory $TunnelForwardCopyWith(TunnelForward value, $Res Function(TunnelForward) _then) = _$TunnelForwardCopyWithImpl;
@useResult
$Res call({
 int localPort
});




}
/// @nodoc
class _$TunnelForwardCopyWithImpl<$Res>
    implements $TunnelForwardCopyWith<$Res> {
  _$TunnelForwardCopyWithImpl(this._self, this._then);

  final TunnelForward _self;
  final $Res Function(TunnelForward) _then;

/// Create a copy of TunnelForward
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? localPort = null,}) {
  return _then(_self.copyWith(
localPort: null == localPort ? _self.localPort : localPort // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TunnelForward].
extension TunnelForwardPatterns on TunnelForward {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LocalForward value)?  local,TResult Function( SocketForward value)?  socket,TResult Function( SocksProxy value)?  socks,TResult Function( RemoteForward value)?  remote,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LocalForward() when local != null:
return local(_that);case SocketForward() when socket != null:
return socket(_that);case SocksProxy() when socks != null:
return socks(_that);case RemoteForward() when remote != null:
return remote(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LocalForward value)  local,required TResult Function( SocketForward value)  socket,required TResult Function( SocksProxy value)  socks,required TResult Function( RemoteForward value)  remote,}){
final _that = this;
switch (_that) {
case LocalForward():
return local(_that);case SocketForward():
return socket(_that);case SocksProxy():
return socks(_that);case RemoteForward():
return remote(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LocalForward value)?  local,TResult? Function( SocketForward value)?  socket,TResult? Function( SocksProxy value)?  socks,TResult? Function( RemoteForward value)?  remote,}){
final _that = this;
switch (_that) {
case LocalForward() when local != null:
return local(_that);case SocketForward() when socket != null:
return socket(_that);case SocksProxy() when socks != null:
return socks(_that);case RemoteForward() when remote != null:
return remote(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String bindAddress,  int localPort,  String remoteHost,  int remotePort)?  local,TResult Function( String bindAddress,  int localPort,  String remoteSocket)?  socket,TResult Function( String bindAddress,  int localPort)?  socks,TResult Function( int remotePort,  String localHost,  int localPort)?  remote,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LocalForward() when local != null:
return local(_that.bindAddress,_that.localPort,_that.remoteHost,_that.remotePort);case SocketForward() when socket != null:
return socket(_that.bindAddress,_that.localPort,_that.remoteSocket);case SocksProxy() when socks != null:
return socks(_that.bindAddress,_that.localPort);case RemoteForward() when remote != null:
return remote(_that.remotePort,_that.localHost,_that.localPort);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String bindAddress,  int localPort,  String remoteHost,  int remotePort)  local,required TResult Function( String bindAddress,  int localPort,  String remoteSocket)  socket,required TResult Function( String bindAddress,  int localPort)  socks,required TResult Function( int remotePort,  String localHost,  int localPort)  remote,}) {final _that = this;
switch (_that) {
case LocalForward():
return local(_that.bindAddress,_that.localPort,_that.remoteHost,_that.remotePort);case SocketForward():
return socket(_that.bindAddress,_that.localPort,_that.remoteSocket);case SocksProxy():
return socks(_that.bindAddress,_that.localPort);case RemoteForward():
return remote(_that.remotePort,_that.localHost,_that.localPort);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String bindAddress,  int localPort,  String remoteHost,  int remotePort)?  local,TResult? Function( String bindAddress,  int localPort,  String remoteSocket)?  socket,TResult? Function( String bindAddress,  int localPort)?  socks,TResult? Function( int remotePort,  String localHost,  int localPort)?  remote,}) {final _that = this;
switch (_that) {
case LocalForward() when local != null:
return local(_that.bindAddress,_that.localPort,_that.remoteHost,_that.remotePort);case SocketForward() when socket != null:
return socket(_that.bindAddress,_that.localPort,_that.remoteSocket);case SocksProxy() when socks != null:
return socks(_that.bindAddress,_that.localPort);case RemoteForward() when remote != null:
return remote(_that.remotePort,_that.localHost,_that.localPort);case _:
  return null;

}
}

}

/// @nodoc


class LocalForward extends TunnelForward {
  const LocalForward({this.bindAddress = '127.0.0.1', required this.localPort, required this.remoteHost, required this.remotePort}): super._();
  

@JsonKey() final  String bindAddress;
@override final  int localPort;
 final  String remoteHost;
 final  int remotePort;

/// Create a copy of TunnelForward
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalForwardCopyWith<LocalForward> get copyWith => _$LocalForwardCopyWithImpl<LocalForward>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalForward&&(identical(other.bindAddress, bindAddress) || other.bindAddress == bindAddress)&&(identical(other.localPort, localPort) || other.localPort == localPort)&&(identical(other.remoteHost, remoteHost) || other.remoteHost == remoteHost)&&(identical(other.remotePort, remotePort) || other.remotePort == remotePort));
}


@override
int get hashCode {
    return Object.hash(runtimeType,bindAddress,localPort,remoteHost,remotePort);
}

@override
String toString() {
    return 'TunnelForward.local(bindAddress: $bindAddress, localPort: $localPort, remoteHost: $remoteHost, remotePort: $remotePort)';
}


}

/// @nodoc
abstract mixin class $LocalForwardCopyWith<$Res> implements $TunnelForwardCopyWith<$Res> {
  factory $LocalForwardCopyWith(LocalForward value, $Res Function(LocalForward) _then) = _$LocalForwardCopyWithImpl;
@override @useResult
$Res call({
 String bindAddress, int localPort, String remoteHost, int remotePort
});




}
/// @nodoc
class _$LocalForwardCopyWithImpl<$Res>
    implements $LocalForwardCopyWith<$Res> {
  _$LocalForwardCopyWithImpl(this._self, this._then);

  final LocalForward _self;
  final $Res Function(LocalForward) _then;

/// Create a copy of TunnelForward
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bindAddress = null,Object? localPort = null,Object? remoteHost = null,Object? remotePort = null,}) {
  return _then(LocalForward(
bindAddress: null == bindAddress ? _self.bindAddress : bindAddress // ignore: cast_nullable_to_non_nullable
as String,localPort: null == localPort ? _self.localPort : localPort // ignore: cast_nullable_to_non_nullable
as int,remoteHost: null == remoteHost ? _self.remoteHost : remoteHost // ignore: cast_nullable_to_non_nullable
as String,remotePort: null == remotePort ? _self.remotePort : remotePort // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class SocketForward extends TunnelForward {
  const SocketForward({this.bindAddress = '127.0.0.1', required this.localPort, required this.remoteSocket}): super._();
  

@JsonKey() final  String bindAddress;
@override final  int localPort;
 final  String remoteSocket;

/// Create a copy of TunnelForward
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocketForwardCopyWith<SocketForward> get copyWith => _$SocketForwardCopyWithImpl<SocketForward>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SocketForward&&(identical(other.bindAddress, bindAddress) || other.bindAddress == bindAddress)&&(identical(other.localPort, localPort) || other.localPort == localPort)&&(identical(other.remoteSocket, remoteSocket) || other.remoteSocket == remoteSocket));
}


@override
int get hashCode {
    return Object.hash(runtimeType,bindAddress,localPort,remoteSocket);
}

@override
String toString() {
    return 'TunnelForward.socket(bindAddress: $bindAddress, localPort: $localPort, remoteSocket: $remoteSocket)';
}


}

/// @nodoc
abstract mixin class $SocketForwardCopyWith<$Res> implements $TunnelForwardCopyWith<$Res> {
  factory $SocketForwardCopyWith(SocketForward value, $Res Function(SocketForward) _then) = _$SocketForwardCopyWithImpl;
@override @useResult
$Res call({
 String bindAddress, int localPort, String remoteSocket
});




}
/// @nodoc
class _$SocketForwardCopyWithImpl<$Res>
    implements $SocketForwardCopyWith<$Res> {
  _$SocketForwardCopyWithImpl(this._self, this._then);

  final SocketForward _self;
  final $Res Function(SocketForward) _then;

/// Create a copy of TunnelForward
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bindAddress = null,Object? localPort = null,Object? remoteSocket = null,}) {
  return _then(SocketForward(
bindAddress: null == bindAddress ? _self.bindAddress : bindAddress // ignore: cast_nullable_to_non_nullable
as String,localPort: null == localPort ? _self.localPort : localPort // ignore: cast_nullable_to_non_nullable
as int,remoteSocket: null == remoteSocket ? _self.remoteSocket : remoteSocket // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SocksProxy extends TunnelForward {
  const SocksProxy({this.bindAddress = '127.0.0.1', required this.localPort}): super._();
  

@JsonKey() final  String bindAddress;
@override final  int localPort;

/// Create a copy of TunnelForward
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocksProxyCopyWith<SocksProxy> get copyWith => _$SocksProxyCopyWithImpl<SocksProxy>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SocksProxy&&(identical(other.bindAddress, bindAddress) || other.bindAddress == bindAddress)&&(identical(other.localPort, localPort) || other.localPort == localPort));
}


@override
int get hashCode {
    return Object.hash(runtimeType,bindAddress,localPort);
}

@override
String toString() {
    return 'TunnelForward.socks(bindAddress: $bindAddress, localPort: $localPort)';
}


}

/// @nodoc
abstract mixin class $SocksProxyCopyWith<$Res> implements $TunnelForwardCopyWith<$Res> {
  factory $SocksProxyCopyWith(SocksProxy value, $Res Function(SocksProxy) _then) = _$SocksProxyCopyWithImpl;
@override @useResult
$Res call({
 String bindAddress, int localPort
});




}
/// @nodoc
class _$SocksProxyCopyWithImpl<$Res>
    implements $SocksProxyCopyWith<$Res> {
  _$SocksProxyCopyWithImpl(this._self, this._then);

  final SocksProxy _self;
  final $Res Function(SocksProxy) _then;

/// Create a copy of TunnelForward
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bindAddress = null,Object? localPort = null,}) {
  return _then(SocksProxy(
bindAddress: null == bindAddress ? _self.bindAddress : bindAddress // ignore: cast_nullable_to_non_nullable
as String,localPort: null == localPort ? _self.localPort : localPort // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class RemoteForward extends TunnelForward {
  const RemoteForward({required this.remotePort, this.localHost = 'localhost', required this.localPort}): super._();
  

 final  int remotePort;
@JsonKey() final  String localHost;
@override final  int localPort;

/// Create a copy of TunnelForward
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteForwardCopyWith<RemoteForward> get copyWith => _$RemoteForwardCopyWithImpl<RemoteForward>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteForward&&(identical(other.remotePort, remotePort) || other.remotePort == remotePort)&&(identical(other.localHost, localHost) || other.localHost == localHost)&&(identical(other.localPort, localPort) || other.localPort == localPort));
}


@override
int get hashCode {
    return Object.hash(runtimeType,remotePort,localHost,localPort);
}

@override
String toString() {
    return 'TunnelForward.remote(remotePort: $remotePort, localHost: $localHost, localPort: $localPort)';
}


}

/// @nodoc
abstract mixin class $RemoteForwardCopyWith<$Res> implements $TunnelForwardCopyWith<$Res> {
  factory $RemoteForwardCopyWith(RemoteForward value, $Res Function(RemoteForward) _then) = _$RemoteForwardCopyWithImpl;
@override @useResult
$Res call({
 int remotePort, String localHost, int localPort
});




}
/// @nodoc
class _$RemoteForwardCopyWithImpl<$Res>
    implements $RemoteForwardCopyWith<$Res> {
  _$RemoteForwardCopyWithImpl(this._self, this._then);

  final RemoteForward _self;
  final $Res Function(RemoteForward) _then;

/// Create a copy of TunnelForward
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? remotePort = null,Object? localHost = null,Object? localPort = null,}) {
  return _then(RemoteForward(
remotePort: null == remotePort ? _self.remotePort : remotePort // ignore: cast_nullable_to_non_nullable
as int,localHost: null == localHost ? _self.localHost : localHost // ignore: cast_nullable_to_non_nullable
as String,localPort: null == localPort ? _self.localPort : localPort // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
