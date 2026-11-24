// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_prompt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginPrompt {

 int get id; String get tunnel; SshPrompt get prompt;
/// Create a copy of LoginPrompt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginPromptCopyWith<LoginPrompt> get copyWith => _$LoginPromptCopyWithImpl<LoginPrompt>(this as LoginPrompt, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LoginPrompt;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginPrompt&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.tunnel, _this.tunnel) || other.tunnel == _this.tunnel)&&(identical(other.prompt, _this.prompt) || other.prompt == _this.prompt));
}


@override
int get hashCode {
  final _this = this as LoginPrompt;
  return Object.hash(runtimeType,_this.id,_this.tunnel,_this.prompt);
}

@override
String toString() {
  final _this = this as LoginPrompt;
  return 'LoginPrompt(id: ${_this.id}, tunnel: ${_this.tunnel}, prompt: ${_this.prompt})';
}


}

/// @nodoc
abstract mixin class $LoginPromptCopyWith<$Res>  {
  factory $LoginPromptCopyWith(LoginPrompt value, $Res Function(LoginPrompt) _then) = _$LoginPromptCopyWithImpl;
@useResult
$Res call({
 int id, String tunnel, SshPrompt prompt
});




}
/// @nodoc
class _$LoginPromptCopyWithImpl<$Res>
    implements $LoginPromptCopyWith<$Res> {
  _$LoginPromptCopyWithImpl(this._self, this._then);

  final LoginPrompt _self;
  final $Res Function(LoginPrompt) _then;

/// Create a copy of LoginPrompt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tunnel = null,Object? prompt = null,}) {
  return _then(LoginPrompt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,tunnel: null == tunnel ? _self.tunnel : tunnel // ignore: cast_nullable_to_non_nullable
as String,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as SshPrompt,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginPrompt].
extension LoginPromptPatterns on LoginPrompt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginPrompt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginPrompt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginPrompt value)  $default,){
final _that = this;
switch (_that) {
case _LoginPrompt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginPrompt value)?  $default,){
final _that = this;
switch (_that) {
case _LoginPrompt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String tunnel,  SshPrompt prompt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginPrompt() when $default != null:
return $default(_that.id,_that.tunnel,_that.prompt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String tunnel,  SshPrompt prompt)  $default,) {final _that = this;
switch (_that) {
case _LoginPrompt():
return $default(_that.id,_that.tunnel,_that.prompt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String tunnel,  SshPrompt prompt)?  $default,) {final _that = this;
switch (_that) {
case _LoginPrompt() when $default != null:
return $default(_that.id,_that.tunnel,_that.prompt);case _:
  return null;

}
}

}

/// @nodoc


class _LoginPrompt extends LoginPrompt {
  const _LoginPrompt({required this.id, required this.tunnel, required this.prompt}): super._();
  

@override final  int id;
@override final  String tunnel;
@override final  SshPrompt prompt;

/// Create a copy of LoginPrompt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginPromptCopyWith<_LoginPrompt> get copyWith => __$LoginPromptCopyWithImpl<_LoginPrompt>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginPrompt&&(identical(other.id, id) || other.id == id)&&(identical(other.tunnel, tunnel) || other.tunnel == tunnel)&&(identical(other.prompt, prompt) || other.prompt == prompt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,tunnel,prompt);
}

@override
String toString() {
    return 'LoginPrompt(id: $id, tunnel: $tunnel, prompt: $prompt)';
}


}

/// @nodoc
abstract mixin class _$LoginPromptCopyWith<$Res> implements $LoginPromptCopyWith<$Res> {
  factory _$LoginPromptCopyWith(_LoginPrompt value, $Res Function(_LoginPrompt) _then) = __$LoginPromptCopyWithImpl;
@override @useResult
$Res call({
 int id, String tunnel, SshPrompt prompt
});




}
/// @nodoc
class __$LoginPromptCopyWithImpl<$Res>
    implements _$LoginPromptCopyWith<$Res> {
  __$LoginPromptCopyWithImpl(this._self, this._then);

  final _LoginPrompt _self;
  final $Res Function(_LoginPrompt) _then;

/// Create a copy of LoginPrompt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tunnel = null,Object? prompt = null,}) {
  return _then(_LoginPrompt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,tunnel: null == tunnel ? _self.tunnel : tunnel // ignore: cast_nullable_to_non_nullable
as String,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as SshPrompt,
  ));
}


}

// dart format on
