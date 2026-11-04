// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tunnels_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TunnelsEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TunnelsEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'TunnelsEvent()';
}


}

/// @nodoc
class $TunnelsEventCopyWith<$Res>  {
$TunnelsEventCopyWith(TunnelsEvent _, $Res Function(TunnelsEvent) __);
}


/// Adds pattern-matching-related methods to [TunnelsEvent].
extension TunnelsEventPatterns on TunnelsEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Started value)?  started,TResult Function( Save value)?  save,TResult Function( Remove value)?  remove,TResult Function( Toggle value)?  toggle,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Started() when started != null:
return started(_that);case Save() when save != null:
return save(_that);case Remove() when remove != null:
return remove(_that);case Toggle() when toggle != null:
return toggle(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Started value)  started,required TResult Function( Save value)  save,required TResult Function( Remove value)  remove,required TResult Function( Toggle value)  toggle,}){
final _that = this;
switch (_that) {
case Started():
return started(_that);case Save():
return save(_that);case Remove():
return remove(_that);case Toggle():
return toggle(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Started value)?  started,TResult? Function( Save value)?  save,TResult? Function( Remove value)?  remove,TResult? Function( Toggle value)?  toggle,}){
final _that = this;
switch (_that) {
case Started() when started != null:
return started(_that);case Save() when save != null:
return save(_that);case Remove() when remove != null:
return remove(_that);case Toggle() when toggle != null:
return toggle(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function( Tunnel tunnel)?  save,TResult Function( String id)?  remove,TResult Function( String id)?  toggle,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Started() when started != null:
return started();case Save() when save != null:
return save(_that.tunnel);case Remove() when remove != null:
return remove(_that.id);case Toggle() when toggle != null:
return toggle(_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function( Tunnel tunnel)  save,required TResult Function( String id)  remove,required TResult Function( String id)  toggle,}) {final _that = this;
switch (_that) {
case Started():
return started();case Save():
return save(_that.tunnel);case Remove():
return remove(_that.id);case Toggle():
return toggle(_that.id);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function( Tunnel tunnel)?  save,TResult? Function( String id)?  remove,TResult? Function( String id)?  toggle,}) {final _that = this;
switch (_that) {
case Started() when started != null:
return started();case Save() when save != null:
return save(_that.tunnel);case Remove() when remove != null:
return remove(_that.id);case Toggle() when toggle != null:
return toggle(_that.id);case _:
  return null;

}
}

}

/// @nodoc


class Started implements TunnelsEvent {
  const Started();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Started);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'TunnelsEvent.started()';
}


}




/// @nodoc


class Save implements TunnelsEvent {
  const Save(this.tunnel);
  

 final  Tunnel tunnel;

/// Create a copy of TunnelsEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaveCopyWith<Save> get copyWith => _$SaveCopyWithImpl<Save>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Save&&(identical(other.tunnel, tunnel) || other.tunnel == tunnel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,tunnel);
}

@override
String toString() {
    return 'TunnelsEvent.save(tunnel: $tunnel)';
}


}

/// @nodoc
abstract mixin class $SaveCopyWith<$Res> implements $TunnelsEventCopyWith<$Res> {
  factory $SaveCopyWith(Save value, $Res Function(Save) _then) = _$SaveCopyWithImpl;
@useResult
$Res call({
 Tunnel tunnel
});


$TunnelCopyWith<$Res> get tunnel;

}
/// @nodoc
class _$SaveCopyWithImpl<$Res>
    implements $SaveCopyWith<$Res> {
  _$SaveCopyWithImpl(this._self, this._then);

  final Save _self;
  final $Res Function(Save) _then;

/// Create a copy of TunnelsEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tunnel = null,}) {
  return _then(Save(
null == tunnel ? _self.tunnel : tunnel // ignore: cast_nullable_to_non_nullable
as Tunnel,
  ));
}

/// Create a copy of TunnelsEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TunnelCopyWith<$Res> get tunnel {
  
  return $TunnelCopyWith<$Res>(_self.tunnel, (value) {
    return _then(_self.copyWith(tunnel: value));
  });
}
}

/// @nodoc


class Remove implements TunnelsEvent {
  const Remove(this.id);
  

 final  String id;

/// Create a copy of TunnelsEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoveCopyWith<Remove> get copyWith => _$RemoveCopyWithImpl<Remove>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Remove&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id);
}

@override
String toString() {
    return 'TunnelsEvent.remove(id: $id)';
}


}

/// @nodoc
abstract mixin class $RemoveCopyWith<$Res> implements $TunnelsEventCopyWith<$Res> {
  factory $RemoveCopyWith(Remove value, $Res Function(Remove) _then) = _$RemoveCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$RemoveCopyWithImpl<$Res>
    implements $RemoveCopyWith<$Res> {
  _$RemoveCopyWithImpl(this._self, this._then);

  final Remove _self;
  final $Res Function(Remove) _then;

/// Create a copy of TunnelsEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(Remove(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class Toggle implements TunnelsEvent {
  const Toggle(this.id);
  

 final  String id;

/// Create a copy of TunnelsEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToggleCopyWith<Toggle> get copyWith => _$ToggleCopyWithImpl<Toggle>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Toggle&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id);
}

@override
String toString() {
    return 'TunnelsEvent.toggle(id: $id)';
}


}

/// @nodoc
abstract mixin class $ToggleCopyWith<$Res> implements $TunnelsEventCopyWith<$Res> {
  factory $ToggleCopyWith(Toggle value, $Res Function(Toggle) _then) = _$ToggleCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$ToggleCopyWithImpl<$Res>
    implements $ToggleCopyWith<$Res> {
  _$ToggleCopyWithImpl(this._self, this._then);

  final Toggle _self;
  final $Res Function(Toggle) _then;

/// Create a copy of TunnelsEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(Toggle(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$TunnelsState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TunnelsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'TunnelsState()';
}


}

/// @nodoc
class $TunnelsStateCopyWith<$Res>  {
$TunnelsStateCopyWith(TunnelsState _, $Res Function(TunnelsState) __);
}


/// Adds pattern-matching-related methods to [TunnelsState].
extension TunnelsStatePatterns on TunnelsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Loading value)?  loading,TResult Function( Ready value)?  ready,TResult Function( Closed value)?  closed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Loading() when loading != null:
return loading(_that);case Ready() when ready != null:
return ready(_that);case Closed() when closed != null:
return closed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Loading value)  loading,required TResult Function( Ready value)  ready,required TResult Function( Closed value)  closed,}){
final _that = this;
switch (_that) {
case Loading():
return loading(_that);case Ready():
return ready(_that);case Closed():
return closed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Loading value)?  loading,TResult? Function( Ready value)?  ready,TResult? Function( Closed value)?  closed,}){
final _that = this;
switch (_that) {
case Loading() when loading != null:
return loading(_that);case Ready() when ready != null:
return ready(_that);case Closed() when closed != null:
return closed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( TunnelsSnapshot snapshot)?  ready,TResult Function()?  closed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Loading() when loading != null:
return loading();case Ready() when ready != null:
return ready(_that.snapshot);case Closed() when closed != null:
return closed();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( TunnelsSnapshot snapshot)  ready,required TResult Function()  closed,}) {final _that = this;
switch (_that) {
case Loading():
return loading();case Ready():
return ready(_that.snapshot);case Closed():
return closed();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( TunnelsSnapshot snapshot)?  ready,TResult? Function()?  closed,}) {final _that = this;
switch (_that) {
case Loading() when loading != null:
return loading();case Ready() when ready != null:
return ready(_that.snapshot);case Closed() when closed != null:
return closed();case _:
  return null;

}
}

}

/// @nodoc


class Loading implements TunnelsState {
  const Loading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'TunnelsState.loading()';
}


}




/// @nodoc


class Ready implements TunnelsState {
  const Ready(this.snapshot);
  

 final  TunnelsSnapshot snapshot;

/// Create a copy of TunnelsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadyCopyWith<Ready> get copyWith => _$ReadyCopyWithImpl<Ready>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Ready&&(identical(other.snapshot, snapshot) || other.snapshot == snapshot));
}


@override
int get hashCode {
    return Object.hash(runtimeType,snapshot);
}

@override
String toString() {
    return 'TunnelsState.ready(snapshot: $snapshot)';
}


}

/// @nodoc
abstract mixin class $ReadyCopyWith<$Res> implements $TunnelsStateCopyWith<$Res> {
  factory $ReadyCopyWith(Ready value, $Res Function(Ready) _then) = _$ReadyCopyWithImpl;
@useResult
$Res call({
 TunnelsSnapshot snapshot
});


$TunnelsSnapshotCopyWith<$Res> get snapshot;

}
/// @nodoc
class _$ReadyCopyWithImpl<$Res>
    implements $ReadyCopyWith<$Res> {
  _$ReadyCopyWithImpl(this._self, this._then);

  final Ready _self;
  final $Res Function(Ready) _then;

/// Create a copy of TunnelsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? snapshot = null,}) {
  return _then(Ready(
null == snapshot ? _self.snapshot : snapshot // ignore: cast_nullable_to_non_nullable
as TunnelsSnapshot,
  ));
}

/// Create a copy of TunnelsState
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


class Closed implements TunnelsState {
  const Closed();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Closed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'TunnelsState.closed()';
}


}




// dart format on
