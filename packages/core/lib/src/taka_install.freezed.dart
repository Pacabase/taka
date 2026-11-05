// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taka_install.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TakaInstall {

 String get app; String get agent; String? get agentBundle; String get agentAssets;
/// Create a copy of TakaInstall
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TakaInstallCopyWith<TakaInstall> get copyWith => _$TakaInstallCopyWithImpl<TakaInstall>(this as TakaInstall, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TakaInstall;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TakaInstall&&(identical(other.app, _this.app) || other.app == _this.app)&&(identical(other.agent, _this.agent) || other.agent == _this.agent)&&(identical(other.agentBundle, _this.agentBundle) || other.agentBundle == _this.agentBundle)&&(identical(other.agentAssets, _this.agentAssets) || other.agentAssets == _this.agentAssets));
}


@override
int get hashCode {
  final _this = this as TakaInstall;
  return Object.hash(runtimeType,_this.app,_this.agent,_this.agentBundle,_this.agentAssets);
}

@override
String toString() {
  final _this = this as TakaInstall;
  return 'TakaInstall(app: ${_this.app}, agent: ${_this.agent}, agentBundle: ${_this.agentBundle}, agentAssets: ${_this.agentAssets})';
}


}

/// @nodoc
abstract mixin class $TakaInstallCopyWith<$Res>  {
  factory $TakaInstallCopyWith(TakaInstall value, $Res Function(TakaInstall) _then) = _$TakaInstallCopyWithImpl;
@useResult
$Res call({
 String app, String agent, String? agentBundle, String agentAssets
});




}
/// @nodoc
class _$TakaInstallCopyWithImpl<$Res>
    implements $TakaInstallCopyWith<$Res> {
  _$TakaInstallCopyWithImpl(this._self, this._then);

  final TakaInstall _self;
  final $Res Function(TakaInstall) _then;

/// Create a copy of TakaInstall
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? app = null,Object? agent = null,Object? agentBundle = freezed,Object? agentAssets = null,}) {
  return _then(TakaInstall(
app: null == app ? _self.app : app // ignore: cast_nullable_to_non_nullable
as String,agent: null == agent ? _self.agent : agent // ignore: cast_nullable_to_non_nullable
as String,agentBundle: freezed == agentBundle ? _self.agentBundle : agentBundle // ignore: cast_nullable_to_non_nullable
as String?,agentAssets: null == agentAssets ? _self.agentAssets : agentAssets // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TakaInstall].
extension TakaInstallPatterns on TakaInstall {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TakaInstall value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TakaInstall() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TakaInstall value)  $default,){
final _that = this;
switch (_that) {
case _TakaInstall():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TakaInstall value)?  $default,){
final _that = this;
switch (_that) {
case _TakaInstall() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String app,  String agent,  String? agentBundle,  String agentAssets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TakaInstall() when $default != null:
return $default(_that.app,_that.agent,_that.agentBundle,_that.agentAssets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String app,  String agent,  String? agentBundle,  String agentAssets)  $default,) {final _that = this;
switch (_that) {
case _TakaInstall():
return $default(_that.app,_that.agent,_that.agentBundle,_that.agentAssets);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String app,  String agent,  String? agentBundle,  String agentAssets)?  $default,) {final _that = this;
switch (_that) {
case _TakaInstall() when $default != null:
return $default(_that.app,_that.agent,_that.agentBundle,_that.agentAssets);case _:
  return null;

}
}

}

/// @nodoc


class _TakaInstall extends TakaInstall {
  const _TakaInstall({required this.app, required this.agent, this.agentBundle, required this.agentAssets}): super._();
  

@override final  String app;
@override final  String agent;
@override final  String? agentBundle;
@override final  String agentAssets;

/// Create a copy of TakaInstall
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TakaInstallCopyWith<_TakaInstall> get copyWith => __$TakaInstallCopyWithImpl<_TakaInstall>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TakaInstall&&(identical(other.app, app) || other.app == app)&&(identical(other.agent, agent) || other.agent == agent)&&(identical(other.agentBundle, agentBundle) || other.agentBundle == agentBundle)&&(identical(other.agentAssets, agentAssets) || other.agentAssets == agentAssets));
}


@override
int get hashCode {
    return Object.hash(runtimeType,app,agent,agentBundle,agentAssets);
}

@override
String toString() {
    return 'TakaInstall(app: $app, agent: $agent, agentBundle: $agentBundle, agentAssets: $agentAssets)';
}


}

/// @nodoc
abstract mixin class _$TakaInstallCopyWith<$Res> implements $TakaInstallCopyWith<$Res> {
  factory _$TakaInstallCopyWith(_TakaInstall value, $Res Function(_TakaInstall) _then) = __$TakaInstallCopyWithImpl;
@override @useResult
$Res call({
 String app, String agent, String? agentBundle, String agentAssets
});




}
/// @nodoc
class __$TakaInstallCopyWithImpl<$Res>
    implements _$TakaInstallCopyWith<$Res> {
  __$TakaInstallCopyWithImpl(this._self, this._then);

  final _TakaInstall _self;
  final $Res Function(_TakaInstall) _then;

/// Create a copy of TakaInstall
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? app = null,Object? agent = null,Object? agentBundle = freezed,Object? agentAssets = null,}) {
  return _then(_TakaInstall(
app: null == app ? _self.app : app // ignore: cast_nullable_to_non_nullable
as String,agent: null == agent ? _self.agent : agent // ignore: cast_nullable_to_non_nullable
as String,agentBundle: freezed == agentBundle ? _self.agentBundle : agentBundle // ignore: cast_nullable_to_non_nullable
as String?,agentAssets: null == agentAssets ? _self.agentAssets : agentAssets // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
