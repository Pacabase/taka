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

 String get id; String get name; String get sshHost; TunnelForward get forward; String? get group;/// Shown when its group has no colour of its own.
 TunnelColour? get colour;
/// Create a copy of Tunnel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TunnelCopyWith<Tunnel> get copyWith => _$TunnelCopyWithImpl<Tunnel>(this as Tunnel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Tunnel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tunnel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.sshHost, _this.sshHost) || other.sshHost == _this.sshHost)&&(identical(other.forward, _this.forward) || other.forward == _this.forward)&&(identical(other.group, _this.group) || other.group == _this.group)&&(identical(other.colour, _this.colour) || other.colour == _this.colour));
}


@override
int get hashCode {
  final _this = this as Tunnel;
  return Object.hash(runtimeType,_this.id,_this.name,_this.sshHost,_this.forward,_this.group,_this.colour);
}



}

/// @nodoc
abstract mixin class $TunnelCopyWith<$Res>  {
  factory $TunnelCopyWith(Tunnel value, $Res Function(Tunnel) _then) = _$TunnelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String sshHost, TunnelForward forward, String? group, TunnelColour? colour
});


$TunnelForwardCopyWith<$Res> get forward;

}
/// @nodoc
class _$TunnelCopyWithImpl<$Res>
    implements $TunnelCopyWith<$Res> {
  _$TunnelCopyWithImpl(this._self, this._then);

  final Tunnel _self;
  final $Res Function(Tunnel) _then;

/// Create a copy of Tunnel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? sshHost = null,Object? forward = null,Object? group = freezed,Object? colour = freezed,}) {
  return _then(Tunnel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sshHost: null == sshHost ? _self.sshHost : sshHost // ignore: cast_nullable_to_non_nullable
as String,forward: null == forward ? _self.forward : forward // ignore: cast_nullable_to_non_nullable
as TunnelForward,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String?,colour: freezed == colour ? _self.colour : colour // ignore: cast_nullable_to_non_nullable
as TunnelColour?,
  ));
}
/// Create a copy of Tunnel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TunnelForwardCopyWith<$Res> get forward {
  
  return $TunnelForwardCopyWith<$Res>(_self.forward, (value) {
    return _then(_self.copyWith(forward: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String sshHost,  TunnelForward forward,  String? group,  TunnelColour? colour)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tunnel() when $default != null:
return $default(_that.id,_that.name,_that.sshHost,_that.forward,_that.group,_that.colour);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String sshHost,  TunnelForward forward,  String? group,  TunnelColour? colour)  $default,) {final _that = this;
switch (_that) {
case _Tunnel():
return $default(_that.id,_that.name,_that.sshHost,_that.forward,_that.group,_that.colour);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String sshHost,  TunnelForward forward,  String? group,  TunnelColour? colour)?  $default,) {final _that = this;
switch (_that) {
case _Tunnel() when $default != null:
return $default(_that.id,_that.name,_that.sshHost,_that.forward,_that.group,_that.colour);case _:
  return null;

}
}

}

/// @nodoc


class _Tunnel extends Tunnel {
  const _Tunnel({required this.id, this.name = '', this.sshHost = '', required this.forward, this.group, this.colour}): super._();
  

@override final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String sshHost;
@override final  TunnelForward forward;
@override final  String? group;
/// Shown when its group has no colour of its own.
@override final  TunnelColour? colour;

/// Create a copy of Tunnel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TunnelCopyWith<_Tunnel> get copyWith => __$TunnelCopyWithImpl<_Tunnel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tunnel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sshHost, sshHost) || other.sshHost == sshHost)&&(identical(other.forward, forward) || other.forward == forward)&&(identical(other.group, group) || other.group == group)&&(identical(other.colour, colour) || other.colour == colour));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,sshHost,forward,group,colour);
}



}

/// @nodoc
abstract mixin class _$TunnelCopyWith<$Res> implements $TunnelCopyWith<$Res> {
  factory _$TunnelCopyWith(_Tunnel value, $Res Function(_Tunnel) _then) = __$TunnelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String sshHost, TunnelForward forward, String? group, TunnelColour? colour
});


@override $TunnelForwardCopyWith<$Res> get forward;

}
/// @nodoc
class __$TunnelCopyWithImpl<$Res>
    implements _$TunnelCopyWith<$Res> {
  __$TunnelCopyWithImpl(this._self, this._then);

  final _Tunnel _self;
  final $Res Function(_Tunnel) _then;

/// Create a copy of Tunnel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? sshHost = null,Object? forward = null,Object? group = freezed,Object? colour = freezed,}) {
  return _then(_Tunnel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sshHost: null == sshHost ? _self.sshHost : sshHost // ignore: cast_nullable_to_non_nullable
as String,forward: null == forward ? _self.forward : forward // ignore: cast_nullable_to_non_nullable
as TunnelForward,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String?,colour: freezed == colour ? _self.colour : colour // ignore: cast_nullable_to_non_nullable
as TunnelColour?,
  ));
}

/// Create a copy of Tunnel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TunnelForwardCopyWith<$Res> get forward {
  
  return $TunnelForwardCopyWith<$Res>(_self.forward, (value) {
    return _then(_self.copyWith(forward: value));
  });
}
}

// dart format on
