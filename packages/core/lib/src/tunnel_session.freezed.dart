// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tunnel_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Phase {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Phase);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'Phase()';
}


}

/// @nodoc
class $PhaseCopyWith<$Res>  {
$PhaseCopyWith(Phase _, $Res Function(Phase) __);
}


/// Adds pattern-matching-related methods to [Phase].
extension PhasePatterns on Phase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Opening value)?  opening,TResult Function( Up value)?  up,TResult Function( Waiting value)?  waiting,TResult Function( AwaitingTrust value)?  awaitingTrust,TResult Function( Trusting value)?  trusting,TResult Function( GaveUp value)?  gaveUp,TResult Function( Ended value)?  ended,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Opening() when opening != null:
return opening(_that);case Up() when up != null:
return up(_that);case Waiting() when waiting != null:
return waiting(_that);case AwaitingTrust() when awaitingTrust != null:
return awaitingTrust(_that);case Trusting() when trusting != null:
return trusting(_that);case GaveUp() when gaveUp != null:
return gaveUp(_that);case Ended() when ended != null:
return ended(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Opening value)  opening,required TResult Function( Up value)  up,required TResult Function( Waiting value)  waiting,required TResult Function( AwaitingTrust value)  awaitingTrust,required TResult Function( Trusting value)  trusting,required TResult Function( GaveUp value)  gaveUp,required TResult Function( Ended value)  ended,}){
final _that = this;
switch (_that) {
case Opening():
return opening(_that);case Up():
return up(_that);case Waiting():
return waiting(_that);case AwaitingTrust():
return awaitingTrust(_that);case Trusting():
return trusting(_that);case GaveUp():
return gaveUp(_that);case Ended():
return ended(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Opening value)?  opening,TResult? Function( Up value)?  up,TResult? Function( Waiting value)?  waiting,TResult? Function( AwaitingTrust value)?  awaitingTrust,TResult? Function( Trusting value)?  trusting,TResult? Function( GaveUp value)?  gaveUp,TResult? Function( Ended value)?  ended,}){
final _that = this;
switch (_that) {
case Opening() when opening != null:
return opening(_that);case Up() when up != null:
return up(_that);case Waiting() when waiting != null:
return waiting(_that);case AwaitingTrust() when awaitingTrust != null:
return awaitingTrust(_that);case Trusting() when trusting != null:
return trusting(_that);case GaveUp() when gaveUp != null:
return gaveUp(_that);case Ended() when ended != null:
return ended(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Reconnecting? retrying)?  opening,TResult Function( _Opened tunnel,  String warning,  bool isVerifying)?  up,TResult Function( Reconnecting reconnecting,  bool forUnlock)?  waiting,TResult Function( SshHostKey key)?  awaitingTrust,TResult Function()?  trusting,TResult Function( Failed failed)?  gaveUp,TResult Function( TunnelStatus last,  Future<void> closed)?  ended,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Opening() when opening != null:
return opening(_that.retrying);case Up() when up != null:
return up(_that.tunnel,_that.warning,_that.isVerifying);case Waiting() when waiting != null:
return waiting(_that.reconnecting,_that.forUnlock);case AwaitingTrust() when awaitingTrust != null:
return awaitingTrust(_that.key);case Trusting() when trusting != null:
return trusting();case GaveUp() when gaveUp != null:
return gaveUp(_that.failed);case Ended() when ended != null:
return ended(_that.last,_that.closed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Reconnecting? retrying)  opening,required TResult Function( _Opened tunnel,  String warning,  bool isVerifying)  up,required TResult Function( Reconnecting reconnecting,  bool forUnlock)  waiting,required TResult Function( SshHostKey key)  awaitingTrust,required TResult Function()  trusting,required TResult Function( Failed failed)  gaveUp,required TResult Function( TunnelStatus last,  Future<void> closed)  ended,}) {final _that = this;
switch (_that) {
case Opening():
return opening(_that.retrying);case Up():
return up(_that.tunnel,_that.warning,_that.isVerifying);case Waiting():
return waiting(_that.reconnecting,_that.forUnlock);case AwaitingTrust():
return awaitingTrust(_that.key);case Trusting():
return trusting();case GaveUp():
return gaveUp(_that.failed);case Ended():
return ended(_that.last,_that.closed);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Reconnecting? retrying)?  opening,TResult? Function( _Opened tunnel,  String warning,  bool isVerifying)?  up,TResult? Function( Reconnecting reconnecting,  bool forUnlock)?  waiting,TResult? Function( SshHostKey key)?  awaitingTrust,TResult? Function()?  trusting,TResult? Function( Failed failed)?  gaveUp,TResult? Function( TunnelStatus last,  Future<void> closed)?  ended,}) {final _that = this;
switch (_that) {
case Opening() when opening != null:
return opening(_that.retrying);case Up() when up != null:
return up(_that.tunnel,_that.warning,_that.isVerifying);case Waiting() when waiting != null:
return waiting(_that.reconnecting,_that.forUnlock);case AwaitingTrust() when awaitingTrust != null:
return awaitingTrust(_that.key);case Trusting() when trusting != null:
return trusting();case GaveUp() when gaveUp != null:
return gaveUp(_that.failed);case Ended() when ended != null:
return ended(_that.last,_that.closed);case _:
  return null;

}
}

}

/// @nodoc


class Opening extends Phase {
  const Opening({this.retrying}): super._();
  

 final  Reconnecting? retrying;

/// Create a copy of Phase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpeningCopyWith<Opening> get copyWith => _$OpeningCopyWithImpl<Opening>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Opening&&const DeepCollectionEquality().equals(other.retrying, retrying));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(retrying));
}

@override
String toString() {
    return 'Phase.opening(retrying: $retrying)';
}


}

/// @nodoc
abstract mixin class $OpeningCopyWith<$Res> implements $PhaseCopyWith<$Res> {
  factory $OpeningCopyWith(Opening value, $Res Function(Opening) _then) = _$OpeningCopyWithImpl;
@useResult
$Res call({
 Reconnecting? retrying
});




}
/// @nodoc
class _$OpeningCopyWithImpl<$Res>
    implements $OpeningCopyWith<$Res> {
  _$OpeningCopyWithImpl(this._self, this._then);

  final Opening _self;
  final $Res Function(Opening) _then;

/// Create a copy of Phase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? retrying = freezed,}) {
  return _then(Opening(
retrying: freezed == retrying ? _self.retrying : retrying // ignore: cast_nullable_to_non_nullable
as Reconnecting?,
  ));
}


}

/// @nodoc


class Up extends Phase {
  const Up(this.tunnel, {this.warning = '', this.isVerifying = false}): super._();
  

 final  _Opened tunnel;
@JsonKey() final  String warning;
@JsonKey() final  bool isVerifying;

/// Create a copy of Phase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpCopyWith<Up> get copyWith => _$UpCopyWithImpl<Up>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Up&&(identical(other.tunnel, tunnel) || other.tunnel == tunnel)&&(identical(other.warning, warning) || other.warning == warning)&&(identical(other.isVerifying, isVerifying) || other.isVerifying == isVerifying));
}


@override
int get hashCode {
    return Object.hash(runtimeType,tunnel,warning,isVerifying);
}

@override
String toString() {
    return 'Phase.up(tunnel: $tunnel, warning: $warning, isVerifying: $isVerifying)';
}


}

/// @nodoc
abstract mixin class $UpCopyWith<$Res> implements $PhaseCopyWith<$Res> {
  factory $UpCopyWith(Up value, $Res Function(Up) _then) = _$UpCopyWithImpl;
@useResult
$Res call({
 _Opened tunnel, String warning, bool isVerifying
});




}
/// @nodoc
class _$UpCopyWithImpl<$Res>
    implements $UpCopyWith<$Res> {
  _$UpCopyWithImpl(this._self, this._then);

  final Up _self;
  final $Res Function(Up) _then;

/// Create a copy of Phase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tunnel = null,Object? warning = null,Object? isVerifying = null,}) {
  return _then(Up(
null == tunnel ? _self.tunnel : tunnel // ignore: cast_nullable_to_non_nullable
as _Opened,warning: null == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String,isVerifying: null == isVerifying ? _self.isVerifying : isVerifying // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class Waiting extends Phase {
  const Waiting(this.reconnecting, {this.forUnlock = false}): super._();
  

 final  Reconnecting reconnecting;
@JsonKey() final  bool forUnlock;

/// Create a copy of Phase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WaitingCopyWith<Waiting> get copyWith => _$WaitingCopyWithImpl<Waiting>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Waiting&&const DeepCollectionEquality().equals(other.reconnecting, reconnecting)&&(identical(other.forUnlock, forUnlock) || other.forUnlock == forUnlock));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(reconnecting),forUnlock);
}

@override
String toString() {
    return 'Phase.waiting(reconnecting: $reconnecting, forUnlock: $forUnlock)';
}


}

/// @nodoc
abstract mixin class $WaitingCopyWith<$Res> implements $PhaseCopyWith<$Res> {
  factory $WaitingCopyWith(Waiting value, $Res Function(Waiting) _then) = _$WaitingCopyWithImpl;
@useResult
$Res call({
 Reconnecting reconnecting, bool forUnlock
});




}
/// @nodoc
class _$WaitingCopyWithImpl<$Res>
    implements $WaitingCopyWith<$Res> {
  _$WaitingCopyWithImpl(this._self, this._then);

  final Waiting _self;
  final $Res Function(Waiting) _then;

/// Create a copy of Phase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reconnecting = freezed,Object? forUnlock = null,}) {
  return _then(Waiting(
freezed == reconnecting ? _self.reconnecting : reconnecting // ignore: cast_nullable_to_non_nullable
as Reconnecting,forUnlock: null == forUnlock ? _self.forUnlock : forUnlock // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class AwaitingTrust extends Phase {
  const AwaitingTrust(this.key): super._();
  

 final  SshHostKey key;

/// Create a copy of Phase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AwaitingTrustCopyWith<AwaitingTrust> get copyWith => _$AwaitingTrustCopyWithImpl<AwaitingTrust>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AwaitingTrust&&(identical(other.key, key) || other.key == key));
}


@override
int get hashCode {
    return Object.hash(runtimeType,key);
}

@override
String toString() {
    return 'Phase.awaitingTrust(key: $key)';
}


}

/// @nodoc
abstract mixin class $AwaitingTrustCopyWith<$Res> implements $PhaseCopyWith<$Res> {
  factory $AwaitingTrustCopyWith(AwaitingTrust value, $Res Function(AwaitingTrust) _then) = _$AwaitingTrustCopyWithImpl;
@useResult
$Res call({
 SshHostKey key
});




}
/// @nodoc
class _$AwaitingTrustCopyWithImpl<$Res>
    implements $AwaitingTrustCopyWith<$Res> {
  _$AwaitingTrustCopyWithImpl(this._self, this._then);

  final AwaitingTrust _self;
  final $Res Function(AwaitingTrust) _then;

/// Create a copy of Phase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? key = null,}) {
  return _then(AwaitingTrust(
null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as SshHostKey,
  ));
}


}

/// @nodoc


class Trusting extends Phase {
  const Trusting(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Trusting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'Phase.trusting()';
}


}




/// @nodoc


class GaveUp extends Phase {
  const GaveUp(this.failed): super._();
  

 final  Failed failed;

/// Create a copy of Phase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GaveUpCopyWith<GaveUp> get copyWith => _$GaveUpCopyWithImpl<GaveUp>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is GaveUp&&const DeepCollectionEquality().equals(other.failed, failed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(failed));
}

@override
String toString() {
    return 'Phase.gaveUp(failed: $failed)';
}


}

/// @nodoc
abstract mixin class $GaveUpCopyWith<$Res> implements $PhaseCopyWith<$Res> {
  factory $GaveUpCopyWith(GaveUp value, $Res Function(GaveUp) _then) = _$GaveUpCopyWithImpl;
@useResult
$Res call({
 Failed failed
});




}
/// @nodoc
class _$GaveUpCopyWithImpl<$Res>
    implements $GaveUpCopyWith<$Res> {
  _$GaveUpCopyWithImpl(this._self, this._then);

  final GaveUp _self;
  final $Res Function(GaveUp) _then;

/// Create a copy of Phase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failed = freezed,}) {
  return _then(GaveUp(
freezed == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as Failed,
  ));
}


}

/// @nodoc


class Ended extends Phase {
  const Ended(this.last, this.closed): super._();
  

 final  TunnelStatus last;
 final  Future<void> closed;

/// Create a copy of Phase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EndedCopyWith<Ended> get copyWith => _$EndedCopyWithImpl<Ended>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Ended&&(identical(other.last, last) || other.last == last)&&(identical(other.closed, closed) || other.closed == closed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,last,closed);
}

@override
String toString() {
    return 'Phase.ended(last: $last, closed: $closed)';
}


}

/// @nodoc
abstract mixin class $EndedCopyWith<$Res> implements $PhaseCopyWith<$Res> {
  factory $EndedCopyWith(Ended value, $Res Function(Ended) _then) = _$EndedCopyWithImpl;
@useResult
$Res call({
 TunnelStatus last, Future<void> closed
});


$TunnelStatusCopyWith<$Res> get last;

}
/// @nodoc
class _$EndedCopyWithImpl<$Res>
    implements $EndedCopyWith<$Res> {
  _$EndedCopyWithImpl(this._self, this._then);

  final Ended _self;
  final $Res Function(Ended) _then;

/// Create a copy of Phase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? last = null,Object? closed = null,}) {
  return _then(Ended(
null == last ? _self.last : last // ignore: cast_nullable_to_non_nullable
as TunnelStatus,null == closed ? _self.closed : closed // ignore: cast_nullable_to_non_nullable
as Future<void>,
  ));
}

/// Create a copy of Phase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TunnelStatusCopyWith<$Res> get last {
  
  return $TunnelStatusCopyWith<$Res>(_self.last, (value) {
    return _then(_self.copyWith(last: value));
  });
}
}

/// @nodoc
mixin _$SessionState {

 Phase get phase; int get attempts; bool get hasConnected; bool get isWatched;
/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionStateCopyWith<SessionState> get copyWith => _$SessionStateCopyWithImpl<SessionState>(this as SessionState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SessionState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionState&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.attempts, _this.attempts) || other.attempts == _this.attempts)&&(identical(other.hasConnected, _this.hasConnected) || other.hasConnected == _this.hasConnected)&&(identical(other.isWatched, _this.isWatched) || other.isWatched == _this.isWatched));
}


@override
int get hashCode {
  final _this = this as SessionState;
  return Object.hash(runtimeType,_this.phase,_this.attempts,_this.hasConnected,_this.isWatched);
}

@override
String toString() {
  final _this = this as SessionState;
  return 'SessionState(phase: ${_this.phase}, attempts: ${_this.attempts}, hasConnected: ${_this.hasConnected}, isWatched: ${_this.isWatched})';
}


}

/// @nodoc
abstract mixin class $SessionStateCopyWith<$Res>  {
  factory $SessionStateCopyWith(SessionState value, $Res Function(SessionState) _then) = _$SessionStateCopyWithImpl;
@useResult
$Res call({
 Phase phase, int attempts, bool hasConnected, bool isWatched
});


$PhaseCopyWith<$Res> get phase;

}
/// @nodoc
class _$SessionStateCopyWithImpl<$Res>
    implements $SessionStateCopyWith<$Res> {
  _$SessionStateCopyWithImpl(this._self, this._then);

  final SessionState _self;
  final $Res Function(SessionState) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? attempts = null,Object? hasConnected = null,Object? isWatched = null,}) {
  return _then(SessionState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as Phase,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,hasConnected: null == hasConnected ? _self.hasConnected : hasConnected // ignore: cast_nullable_to_non_nullable
as bool,isWatched: null == isWatched ? _self.isWatched : isWatched // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PhaseCopyWith<$Res> get phase {
  
  return $PhaseCopyWith<$Res>(_self.phase, (value) {
    return _then(_self.copyWith(phase: value));
  });
}
}


/// Adds pattern-matching-related methods to [SessionState].
extension SessionStatePatterns on SessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionState value)  $default,){
final _that = this;
switch (_that) {
case _SessionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionState value)?  $default,){
final _that = this;
switch (_that) {
case _SessionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Phase phase,  int attempts,  bool hasConnected,  bool isWatched)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionState() when $default != null:
return $default(_that.phase,_that.attempts,_that.hasConnected,_that.isWatched);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Phase phase,  int attempts,  bool hasConnected,  bool isWatched)  $default,) {final _that = this;
switch (_that) {
case _SessionState():
return $default(_that.phase,_that.attempts,_that.hasConnected,_that.isWatched);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Phase phase,  int attempts,  bool hasConnected,  bool isWatched)?  $default,) {final _that = this;
switch (_that) {
case _SessionState() when $default != null:
return $default(_that.phase,_that.attempts,_that.hasConnected,_that.isWatched);case _:
  return null;

}
}

}

/// @nodoc


class _SessionState extends SessionState {
  const _SessionState({required this.phase, this.attempts = 0, this.hasConnected = false, this.isWatched = true}): super._();
  

@override final  Phase phase;
@override@JsonKey() final  int attempts;
@override@JsonKey() final  bool hasConnected;
@override@JsonKey() final  bool isWatched;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionStateCopyWith<_SessionState> get copyWith => __$SessionStateCopyWithImpl<_SessionState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.hasConnected, hasConnected) || other.hasConnected == hasConnected)&&(identical(other.isWatched, isWatched) || other.isWatched == isWatched));
}


@override
int get hashCode {
    return Object.hash(runtimeType,phase,attempts,hasConnected,isWatched);
}

@override
String toString() {
    return 'SessionState(phase: $phase, attempts: $attempts, hasConnected: $hasConnected, isWatched: $isWatched)';
}


}

/// @nodoc
abstract mixin class _$SessionStateCopyWith<$Res> implements $SessionStateCopyWith<$Res> {
  factory _$SessionStateCopyWith(_SessionState value, $Res Function(_SessionState) _then) = __$SessionStateCopyWithImpl;
@override @useResult
$Res call({
 Phase phase, int attempts, bool hasConnected, bool isWatched
});


@override $PhaseCopyWith<$Res> get phase;

}
/// @nodoc
class __$SessionStateCopyWithImpl<$Res>
    implements _$SessionStateCopyWith<$Res> {
  __$SessionStateCopyWithImpl(this._self, this._then);

  final _SessionState _self;
  final $Res Function(_SessionState) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? attempts = null,Object? hasConnected = null,Object? isWatched = null,}) {
  return _then(_SessionState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as Phase,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,hasConnected: null == hasConnected ? _self.hasConnected : hasConnected // ignore: cast_nullable_to_non_nullable
as bool,isWatched: null == isWatched ? _self.isWatched : isWatched // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PhaseCopyWith<$Res> get phase {
  
  return $PhaseCopyWith<$Res>(_self.phase, (value) {
    return _then(_self.copyWith(phase: value));
  });
}
}

/// @nodoc
mixin _$SessionEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SessionEvent()';
}


}

/// @nodoc
class $SessionEventCopyWith<$Res>  {
$SessionEventCopyWith(SessionEvent _, $Res Function(SessionEvent) __);
}


/// Adds pattern-matching-related methods to [SessionEvent].
extension SessionEventPatterns on SessionEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Connect value)?  connect,TResult Function( Dropped value)?  dropped,TResult Function( RetryDue value)?  retryDue,TResult Function( Stable value)?  stable,TResult Function( Checked value)?  checked,TResult Function( Warned value)?  warned,TResult Function( WarningExpired value)?  warningExpired,TResult Function( Refused value)?  refused,TResult Function( Trust value)?  trust,TResult Function( Stop value)?  stop,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Connect() when connect != null:
return connect(_that);case Dropped() when dropped != null:
return dropped(_that);case RetryDue() when retryDue != null:
return retryDue(_that);case Stable() when stable != null:
return stable(_that);case Checked() when checked != null:
return checked(_that);case Warned() when warned != null:
return warned(_that);case WarningExpired() when warningExpired != null:
return warningExpired(_that);case Refused() when refused != null:
return refused(_that);case Trust() when trust != null:
return trust(_that);case Stop() when stop != null:
return stop(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Connect value)  connect,required TResult Function( Dropped value)  dropped,required TResult Function( RetryDue value)  retryDue,required TResult Function( Stable value)  stable,required TResult Function( Checked value)  checked,required TResult Function( Warned value)  warned,required TResult Function( WarningExpired value)  warningExpired,required TResult Function( Refused value)  refused,required TResult Function( Trust value)  trust,required TResult Function( Stop value)  stop,}){
final _that = this;
switch (_that) {
case Connect():
return connect(_that);case Dropped():
return dropped(_that);case RetryDue():
return retryDue(_that);case Stable():
return stable(_that);case Checked():
return checked(_that);case Warned():
return warned(_that);case WarningExpired():
return warningExpired(_that);case Refused():
return refused(_that);case Trust():
return trust(_that);case Stop():
return stop(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Connect value)?  connect,TResult? Function( Dropped value)?  dropped,TResult? Function( RetryDue value)?  retryDue,TResult? Function( Stable value)?  stable,TResult? Function( Checked value)?  checked,TResult? Function( Warned value)?  warned,TResult? Function( WarningExpired value)?  warningExpired,TResult? Function( Refused value)?  refused,TResult? Function( Trust value)?  trust,TResult? Function( Stop value)?  stop,}){
final _that = this;
switch (_that) {
case Connect() when connect != null:
return connect(_that);case Dropped() when dropped != null:
return dropped(_that);case RetryDue() when retryDue != null:
return retryDue(_that);case Stable() when stable != null:
return stable(_that);case Checked() when checked != null:
return checked(_that);case Warned() when warned != null:
return warned(_that);case WarningExpired() when warningExpired != null:
return warningExpired(_that);case Refused() when refused != null:
return refused(_that);case Trust() when trust != null:
return trust(_that);case Stop() when stop != null:
return stop(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Completer<void> settled)?  connect,TResult Function( Object? error)?  dropped,TResult Function()?  retryDue,TResult Function()?  stable,TResult Function()?  checked,TResult Function( String reason)?  warned,TResult Function()?  warningExpired,TResult Function( SshForwardFailed log)?  refused,TResult Function( Completer<bool> trusted)?  trust,TResult Function( Completer<void> closed)?  stop,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Connect() when connect != null:
return connect(_that.settled);case Dropped() when dropped != null:
return dropped(_that.error);case RetryDue() when retryDue != null:
return retryDue();case Stable() when stable != null:
return stable();case Checked() when checked != null:
return checked();case Warned() when warned != null:
return warned(_that.reason);case WarningExpired() when warningExpired != null:
return warningExpired();case Refused() when refused != null:
return refused(_that.log);case Trust() when trust != null:
return trust(_that.trusted);case Stop() when stop != null:
return stop(_that.closed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Completer<void> settled)  connect,required TResult Function( Object? error)  dropped,required TResult Function()  retryDue,required TResult Function()  stable,required TResult Function()  checked,required TResult Function( String reason)  warned,required TResult Function()  warningExpired,required TResult Function( SshForwardFailed log)  refused,required TResult Function( Completer<bool> trusted)  trust,required TResult Function( Completer<void> closed)  stop,}) {final _that = this;
switch (_that) {
case Connect():
return connect(_that.settled);case Dropped():
return dropped(_that.error);case RetryDue():
return retryDue();case Stable():
return stable();case Checked():
return checked();case Warned():
return warned(_that.reason);case WarningExpired():
return warningExpired();case Refused():
return refused(_that.log);case Trust():
return trust(_that.trusted);case Stop():
return stop(_that.closed);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Completer<void> settled)?  connect,TResult? Function( Object? error)?  dropped,TResult? Function()?  retryDue,TResult? Function()?  stable,TResult? Function()?  checked,TResult? Function( String reason)?  warned,TResult? Function()?  warningExpired,TResult? Function( SshForwardFailed log)?  refused,TResult? Function( Completer<bool> trusted)?  trust,TResult? Function( Completer<void> closed)?  stop,}) {final _that = this;
switch (_that) {
case Connect() when connect != null:
return connect(_that.settled);case Dropped() when dropped != null:
return dropped(_that.error);case RetryDue() when retryDue != null:
return retryDue();case Stable() when stable != null:
return stable();case Checked() when checked != null:
return checked();case Warned() when warned != null:
return warned(_that.reason);case WarningExpired() when warningExpired != null:
return warningExpired();case Refused() when refused != null:
return refused(_that.log);case Trust() when trust != null:
return trust(_that.trusted);case Stop() when stop != null:
return stop(_that.closed);case _:
  return null;

}
}

}

/// @nodoc


class Connect extends SessionEvent {
  const Connect(this.settled): super._();
  

 final  Completer<void> settled;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectCopyWith<Connect> get copyWith => _$ConnectCopyWithImpl<Connect>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Connect&&(identical(other.settled, settled) || other.settled == settled));
}


@override
int get hashCode {
    return Object.hash(runtimeType,settled);
}

@override
String toString() {
    return 'SessionEvent.connect(settled: $settled)';
}


}

/// @nodoc
abstract mixin class $ConnectCopyWith<$Res> implements $SessionEventCopyWith<$Res> {
  factory $ConnectCopyWith(Connect value, $Res Function(Connect) _then) = _$ConnectCopyWithImpl;
@useResult
$Res call({
 Completer<void> settled
});




}
/// @nodoc
class _$ConnectCopyWithImpl<$Res>
    implements $ConnectCopyWith<$Res> {
  _$ConnectCopyWithImpl(this._self, this._then);

  final Connect _self;
  final $Res Function(Connect) _then;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? settled = null,}) {
  return _then(Connect(
null == settled ? _self.settled : settled // ignore: cast_nullable_to_non_nullable
as Completer<void>,
  ));
}


}

/// @nodoc


class Dropped extends SessionEvent {
  const Dropped(this.error): super._();
  

 final  Object? error;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DroppedCopyWith<Dropped> get copyWith => _$DroppedCopyWithImpl<Dropped>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Dropped&&const DeepCollectionEquality().equals(other.error, error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(error));
}

@override
String toString() {
    return 'SessionEvent.dropped(error: $error)';
}


}

/// @nodoc
abstract mixin class $DroppedCopyWith<$Res> implements $SessionEventCopyWith<$Res> {
  factory $DroppedCopyWith(Dropped value, $Res Function(Dropped) _then) = _$DroppedCopyWithImpl;
@useResult
$Res call({
 Object? error
});




}
/// @nodoc
class _$DroppedCopyWithImpl<$Res>
    implements $DroppedCopyWith<$Res> {
  _$DroppedCopyWithImpl(this._self, this._then);

  final Dropped _self;
  final $Res Function(Dropped) _then;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = freezed,}) {
  return _then(Dropped(
freezed == error ? _self.error : error ,
  ));
}


}

/// @nodoc


class RetryDue extends SessionEvent {
  const RetryDue(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RetryDue);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SessionEvent.retryDue()';
}


}




/// @nodoc


class Stable extends SessionEvent {
  const Stable(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Stable);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SessionEvent.stable()';
}


}




/// @nodoc


class Checked extends SessionEvent {
  const Checked(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Checked);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SessionEvent.checked()';
}


}




/// @nodoc


class Warned extends SessionEvent {
  const Warned(this.reason): super._();
  

 final  String reason;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WarnedCopyWith<Warned> get copyWith => _$WarnedCopyWithImpl<Warned>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Warned&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'SessionEvent.warned(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $WarnedCopyWith<$Res> implements $SessionEventCopyWith<$Res> {
  factory $WarnedCopyWith(Warned value, $Res Function(Warned) _then) = _$WarnedCopyWithImpl;
@useResult
$Res call({
 String reason
});




}
/// @nodoc
class _$WarnedCopyWithImpl<$Res>
    implements $WarnedCopyWith<$Res> {
  _$WarnedCopyWithImpl(this._self, this._then);

  final Warned _self;
  final $Res Function(Warned) _then;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(Warned(
null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class WarningExpired extends SessionEvent {
  const WarningExpired(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WarningExpired);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SessionEvent.warningExpired()';
}


}




/// @nodoc


class Refused extends SessionEvent {
  const Refused(this.log): super._();
  

 final  SshForwardFailed log;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefusedCopyWith<Refused> get copyWith => _$RefusedCopyWithImpl<Refused>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Refused&&(identical(other.log, log) || other.log == log));
}


@override
int get hashCode {
    return Object.hash(runtimeType,log);
}

@override
String toString() {
    return 'SessionEvent.refused(log: $log)';
}


}

/// @nodoc
abstract mixin class $RefusedCopyWith<$Res> implements $SessionEventCopyWith<$Res> {
  factory $RefusedCopyWith(Refused value, $Res Function(Refused) _then) = _$RefusedCopyWithImpl;
@useResult
$Res call({
 SshForwardFailed log
});




}
/// @nodoc
class _$RefusedCopyWithImpl<$Res>
    implements $RefusedCopyWith<$Res> {
  _$RefusedCopyWithImpl(this._self, this._then);

  final Refused _self;
  final $Res Function(Refused) _then;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? log = null,}) {
  return _then(Refused(
null == log ? _self.log : log // ignore: cast_nullable_to_non_nullable
as SshForwardFailed,
  ));
}


}

/// @nodoc


class Trust extends SessionEvent {
  const Trust(this.trusted): super._();
  

 final  Completer<bool> trusted;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrustCopyWith<Trust> get copyWith => _$TrustCopyWithImpl<Trust>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Trust&&(identical(other.trusted, trusted) || other.trusted == trusted));
}


@override
int get hashCode {
    return Object.hash(runtimeType,trusted);
}

@override
String toString() {
    return 'SessionEvent.trust(trusted: $trusted)';
}


}

/// @nodoc
abstract mixin class $TrustCopyWith<$Res> implements $SessionEventCopyWith<$Res> {
  factory $TrustCopyWith(Trust value, $Res Function(Trust) _then) = _$TrustCopyWithImpl;
@useResult
$Res call({
 Completer<bool> trusted
});




}
/// @nodoc
class _$TrustCopyWithImpl<$Res>
    implements $TrustCopyWith<$Res> {
  _$TrustCopyWithImpl(this._self, this._then);

  final Trust _self;
  final $Res Function(Trust) _then;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? trusted = null,}) {
  return _then(Trust(
null == trusted ? _self.trusted : trusted // ignore: cast_nullable_to_non_nullable
as Completer<bool>,
  ));
}


}

/// @nodoc


class Stop extends SessionEvent {
  const Stop(this.closed): super._();
  

 final  Completer<void> closed;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StopCopyWith<Stop> get copyWith => _$StopCopyWithImpl<Stop>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Stop&&(identical(other.closed, closed) || other.closed == closed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,closed);
}

@override
String toString() {
    return 'SessionEvent.stop(closed: $closed)';
}


}

/// @nodoc
abstract mixin class $StopCopyWith<$Res> implements $SessionEventCopyWith<$Res> {
  factory $StopCopyWith(Stop value, $Res Function(Stop) _then) = _$StopCopyWithImpl;
@useResult
$Res call({
 Completer<void> closed
});




}
/// @nodoc
class _$StopCopyWithImpl<$Res>
    implements $StopCopyWith<$Res> {
  _$StopCopyWithImpl(this._self, this._then);

  final Stop _self;
  final $Res Function(Stop) _then;

/// Create a copy of SessionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? closed = null,}) {
  return _then(Stop(
null == closed ? _self.closed : closed // ignore: cast_nullable_to_non_nullable
as Completer<void>,
  ));
}


}

// dart format on
