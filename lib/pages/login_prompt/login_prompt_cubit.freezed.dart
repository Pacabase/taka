// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_prompt_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginPromptState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginPromptState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LoginPromptState()';
}


}

/// @nodoc
class $LoginPromptStateCopyWith<$Res>  {
$LoginPromptStateCopyWith(LoginPromptState _, $Res Function(LoginPromptState) __);
}


/// Adds pattern-matching-related methods to [LoginPromptState].
extension LoginPromptStatePatterns on LoginPromptState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NoPrompt value)?  none,TResult Function( Asking value)?  asking,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NoPrompt() when none != null:
return none(_that);case Asking() when asking != null:
return asking(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NoPrompt value)  none,required TResult Function( Asking value)  asking,}){
final _that = this;
switch (_that) {
case NoPrompt():
return none(_that);case Asking():
return asking(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NoPrompt value)?  none,TResult? Function( Asking value)?  asking,}){
final _that = this;
switch (_that) {
case NoPrompt() when none != null:
return none(_that);case Asking() when asking != null:
return asking(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  none,TResult Function( LoginPrompt prompt)?  asking,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NoPrompt() when none != null:
return none();case Asking() when asking != null:
return asking(_that.prompt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  none,required TResult Function( LoginPrompt prompt)  asking,}) {final _that = this;
switch (_that) {
case NoPrompt():
return none();case Asking():
return asking(_that.prompt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  none,TResult? Function( LoginPrompt prompt)?  asking,}) {final _that = this;
switch (_that) {
case NoPrompt() when none != null:
return none();case Asking() when asking != null:
return asking(_that.prompt);case _:
  return null;

}
}

}

/// @nodoc


class NoPrompt implements LoginPromptState {
  const NoPrompt();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NoPrompt);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LoginPromptState.none()';
}


}




/// @nodoc


class Asking implements LoginPromptState {
  const Asking(this.prompt);
  

 final  LoginPrompt prompt;

/// Create a copy of LoginPromptState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AskingCopyWith<Asking> get copyWith => _$AskingCopyWithImpl<Asking>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Asking&&(identical(other.prompt, prompt) || other.prompt == prompt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,prompt);
}

@override
String toString() {
    return 'LoginPromptState.asking(prompt: $prompt)';
}


}

/// @nodoc
abstract mixin class $AskingCopyWith<$Res> implements $LoginPromptStateCopyWith<$Res> {
  factory $AskingCopyWith(Asking value, $Res Function(Asking) _then) = _$AskingCopyWithImpl;
@useResult
$Res call({
 LoginPrompt prompt
});


$LoginPromptCopyWith<$Res> get prompt;

}
/// @nodoc
class _$AskingCopyWithImpl<$Res>
    implements $AskingCopyWith<$Res> {
  _$AskingCopyWithImpl(this._self, this._then);

  final Asking _self;
  final $Res Function(Asking) _then;

/// Create a copy of LoginPromptState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? prompt = null,}) {
  return _then(Asking(
null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as LoginPrompt,
  ));
}

/// Create a copy of LoginPromptState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LoginPromptCopyWith<$Res> get prompt {
  
  return $LoginPromptCopyWith<$Res>(_self.prompt, (value) {
    return _then(_self.copyWith(prompt: value));
  });
}
}

// dart format on
