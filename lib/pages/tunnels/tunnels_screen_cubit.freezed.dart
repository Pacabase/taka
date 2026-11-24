// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tunnels_screen_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TunnelsScreen {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TunnelsScreen);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'TunnelsScreen()';
}


}

/// @nodoc
class $TunnelsScreenCopyWith<$Res>  {
$TunnelsScreenCopyWith(TunnelsScreen _, $Res Function(TunnelsScreen) __);
}


/// Adds pattern-matching-related methods to [TunnelsScreen].
extension TunnelsScreenPatterns on TunnelsScreen {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ListScreen value)?  list,TResult Function( NewTunnelScreen value)?  newTunnel,TResult Function( EditTunnelScreen value)?  editTunnel,TResult Function( EditGroupScreen value)?  editGroup,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ListScreen() when list != null:
return list(_that);case NewTunnelScreen() when newTunnel != null:
return newTunnel(_that);case EditTunnelScreen() when editTunnel != null:
return editTunnel(_that);case EditGroupScreen() when editGroup != null:
return editGroup(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ListScreen value)  list,required TResult Function( NewTunnelScreen value)  newTunnel,required TResult Function( EditTunnelScreen value)  editTunnel,required TResult Function( EditGroupScreen value)  editGroup,}){
final _that = this;
switch (_that) {
case ListScreen():
return list(_that);case NewTunnelScreen():
return newTunnel(_that);case EditTunnelScreen():
return editTunnel(_that);case EditGroupScreen():
return editGroup(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ListScreen value)?  list,TResult? Function( NewTunnelScreen value)?  newTunnel,TResult? Function( EditTunnelScreen value)?  editTunnel,TResult? Function( EditGroupScreen value)?  editGroup,}){
final _that = this;
switch (_that) {
case ListScreen() when list != null:
return list(_that);case NewTunnelScreen() when newTunnel != null:
return newTunnel(_that);case EditTunnelScreen() when editTunnel != null:
return editTunnel(_that);case EditGroupScreen() when editGroup != null:
return editGroup(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  list,TResult Function( TunnelKind kind)?  newTunnel,TResult Function( Tunnel tunnel)?  editTunnel,TResult Function( String group,  TunnelColour? colour)?  editGroup,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ListScreen() when list != null:
return list();case NewTunnelScreen() when newTunnel != null:
return newTunnel(_that.kind);case EditTunnelScreen() when editTunnel != null:
return editTunnel(_that.tunnel);case EditGroupScreen() when editGroup != null:
return editGroup(_that.group,_that.colour);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  list,required TResult Function( TunnelKind kind)  newTunnel,required TResult Function( Tunnel tunnel)  editTunnel,required TResult Function( String group,  TunnelColour? colour)  editGroup,}) {final _that = this;
switch (_that) {
case ListScreen():
return list();case NewTunnelScreen():
return newTunnel(_that.kind);case EditTunnelScreen():
return editTunnel(_that.tunnel);case EditGroupScreen():
return editGroup(_that.group,_that.colour);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  list,TResult? Function( TunnelKind kind)?  newTunnel,TResult? Function( Tunnel tunnel)?  editTunnel,TResult? Function( String group,  TunnelColour? colour)?  editGroup,}) {final _that = this;
switch (_that) {
case ListScreen() when list != null:
return list();case NewTunnelScreen() when newTunnel != null:
return newTunnel(_that.kind);case EditTunnelScreen() when editTunnel != null:
return editTunnel(_that.tunnel);case EditGroupScreen() when editGroup != null:
return editGroup(_that.group,_that.colour);case _:
  return null;

}
}

}

/// @nodoc


class ListScreen implements TunnelsScreen {
  const ListScreen();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ListScreen);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'TunnelsScreen.list()';
}


}




/// @nodoc


class NewTunnelScreen implements TunnelsScreen {
  const NewTunnelScreen(this.kind);
  

 final  TunnelKind kind;

/// Create a copy of TunnelsScreen
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewTunnelScreenCopyWith<NewTunnelScreen> get copyWith => _$NewTunnelScreenCopyWithImpl<NewTunnelScreen>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NewTunnelScreen&&(identical(other.kind, kind) || other.kind == kind));
}


@override
int get hashCode {
    return Object.hash(runtimeType,kind);
}

@override
String toString() {
    return 'TunnelsScreen.newTunnel(kind: $kind)';
}


}

/// @nodoc
abstract mixin class $NewTunnelScreenCopyWith<$Res> implements $TunnelsScreenCopyWith<$Res> {
  factory $NewTunnelScreenCopyWith(NewTunnelScreen value, $Res Function(NewTunnelScreen) _then) = _$NewTunnelScreenCopyWithImpl;
@useResult
$Res call({
 TunnelKind kind
});




}
/// @nodoc
class _$NewTunnelScreenCopyWithImpl<$Res>
    implements $NewTunnelScreenCopyWith<$Res> {
  _$NewTunnelScreenCopyWithImpl(this._self, this._then);

  final NewTunnelScreen _self;
  final $Res Function(NewTunnelScreen) _then;

/// Create a copy of TunnelsScreen
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? kind = null,}) {
  return _then(NewTunnelScreen(
null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TunnelKind,
  ));
}


}

/// @nodoc


class EditTunnelScreen implements TunnelsScreen {
  const EditTunnelScreen(this.tunnel);
  

 final  Tunnel tunnel;

/// Create a copy of TunnelsScreen
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditTunnelScreenCopyWith<EditTunnelScreen> get copyWith => _$EditTunnelScreenCopyWithImpl<EditTunnelScreen>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EditTunnelScreen&&(identical(other.tunnel, tunnel) || other.tunnel == tunnel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,tunnel);
}

@override
String toString() {
    return 'TunnelsScreen.editTunnel(tunnel: $tunnel)';
}


}

/// @nodoc
abstract mixin class $EditTunnelScreenCopyWith<$Res> implements $TunnelsScreenCopyWith<$Res> {
  factory $EditTunnelScreenCopyWith(EditTunnelScreen value, $Res Function(EditTunnelScreen) _then) = _$EditTunnelScreenCopyWithImpl;
@useResult
$Res call({
 Tunnel tunnel
});


$TunnelCopyWith<$Res> get tunnel;

}
/// @nodoc
class _$EditTunnelScreenCopyWithImpl<$Res>
    implements $EditTunnelScreenCopyWith<$Res> {
  _$EditTunnelScreenCopyWithImpl(this._self, this._then);

  final EditTunnelScreen _self;
  final $Res Function(EditTunnelScreen) _then;

/// Create a copy of TunnelsScreen
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tunnel = null,}) {
  return _then(EditTunnelScreen(
null == tunnel ? _self.tunnel : tunnel // ignore: cast_nullable_to_non_nullable
as Tunnel,
  ));
}

/// Create a copy of TunnelsScreen
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


class EditGroupScreen implements TunnelsScreen {
  const EditGroupScreen(this.group, this.colour);
  

 final  String group;
 final  TunnelColour? colour;

/// Create a copy of TunnelsScreen
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditGroupScreenCopyWith<EditGroupScreen> get copyWith => _$EditGroupScreenCopyWithImpl<EditGroupScreen>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EditGroupScreen&&(identical(other.group, group) || other.group == group)&&(identical(other.colour, colour) || other.colour == colour));
}


@override
int get hashCode {
    return Object.hash(runtimeType,group,colour);
}

@override
String toString() {
    return 'TunnelsScreen.editGroup(group: $group, colour: $colour)';
}


}

/// @nodoc
abstract mixin class $EditGroupScreenCopyWith<$Res> implements $TunnelsScreenCopyWith<$Res> {
  factory $EditGroupScreenCopyWith(EditGroupScreen value, $Res Function(EditGroupScreen) _then) = _$EditGroupScreenCopyWithImpl;
@useResult
$Res call({
 String group, TunnelColour? colour
});




}
/// @nodoc
class _$EditGroupScreenCopyWithImpl<$Res>
    implements $EditGroupScreenCopyWith<$Res> {
  _$EditGroupScreenCopyWithImpl(this._self, this._then);

  final EditGroupScreen _self;
  final $Res Function(EditGroupScreen) _then;

/// Create a copy of TunnelsScreen
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? group = null,Object? colour = freezed,}) {
  return _then(EditGroupScreen(
null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,freezed == colour ? _self.colour : colour // ignore: cast_nullable_to_non_nullable
as TunnelColour?,
  ));
}


}

/// @nodoc
mixin _$TunnelsScreenState {

 TunnelsScreen get screen; List<String> get hosts; int get requests;
/// Create a copy of TunnelsScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TunnelsScreenStateCopyWith<TunnelsScreenState> get copyWith => _$TunnelsScreenStateCopyWithImpl<TunnelsScreenState>(this as TunnelsScreenState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TunnelsScreenState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TunnelsScreenState&&(identical(other.screen, _this.screen) || other.screen == _this.screen)&&const DeepCollectionEquality().equals(other.hosts, _this.hosts)&&(identical(other.requests, _this.requests) || other.requests == _this.requests));
}


@override
int get hashCode {
  final _this = this as TunnelsScreenState;
  return Object.hash(runtimeType,_this.screen,const DeepCollectionEquality().hash(_this.hosts),_this.requests);
}

@override
String toString() {
  final _this = this as TunnelsScreenState;
  return 'TunnelsScreenState(screen: ${_this.screen}, hosts: ${_this.hosts}, requests: ${_this.requests})';
}


}

/// @nodoc
abstract mixin class $TunnelsScreenStateCopyWith<$Res>  {
  factory $TunnelsScreenStateCopyWith(TunnelsScreenState value, $Res Function(TunnelsScreenState) _then) = _$TunnelsScreenStateCopyWithImpl;
@useResult
$Res call({
 TunnelsScreen screen, List<String> hosts, int requests
});


$TunnelsScreenCopyWith<$Res> get screen;

}
/// @nodoc
class _$TunnelsScreenStateCopyWithImpl<$Res>
    implements $TunnelsScreenStateCopyWith<$Res> {
  _$TunnelsScreenStateCopyWithImpl(this._self, this._then);

  final TunnelsScreenState _self;
  final $Res Function(TunnelsScreenState) _then;

/// Create a copy of TunnelsScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? screen = null,Object? hosts = null,Object? requests = null,}) {
  return _then(TunnelsScreenState(
screen: null == screen ? _self.screen : screen // ignore: cast_nullable_to_non_nullable
as TunnelsScreen,hosts: null == hosts ? _self.hosts : hosts // ignore: cast_nullable_to_non_nullable
as List<String>,requests: null == requests ? _self.requests : requests // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of TunnelsScreenState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TunnelsScreenCopyWith<$Res> get screen {
  
  return $TunnelsScreenCopyWith<$Res>(_self.screen, (value) {
    return _then(_self.copyWith(screen: value));
  });
}
}


/// Adds pattern-matching-related methods to [TunnelsScreenState].
extension TunnelsScreenStatePatterns on TunnelsScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TunnelsScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TunnelsScreenState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TunnelsScreenState value)  $default,){
final _that = this;
switch (_that) {
case _TunnelsScreenState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TunnelsScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _TunnelsScreenState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TunnelsScreen screen,  List<String> hosts,  int requests)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TunnelsScreenState() when $default != null:
return $default(_that.screen,_that.hosts,_that.requests);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TunnelsScreen screen,  List<String> hosts,  int requests)  $default,) {final _that = this;
switch (_that) {
case _TunnelsScreenState():
return $default(_that.screen,_that.hosts,_that.requests);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TunnelsScreen screen,  List<String> hosts,  int requests)?  $default,) {final _that = this;
switch (_that) {
case _TunnelsScreenState() when $default != null:
return $default(_that.screen,_that.hosts,_that.requests);case _:
  return null;

}
}

}

/// @nodoc


class _TunnelsScreenState implements TunnelsScreenState {
  const _TunnelsScreenState({this.screen = const ListScreen(),  List<String> hosts = const <String>[], this.requests = 0}): _hosts = hosts;
  

@override@JsonKey() final  TunnelsScreen screen;
 final  List<String> _hosts;
@override@JsonKey() List<String> get hosts {
  if (_hosts is EqualUnmodifiableListView) return _hosts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hosts);
}

@override@JsonKey() final  int requests;

/// Create a copy of TunnelsScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TunnelsScreenStateCopyWith<_TunnelsScreenState> get copyWith => __$TunnelsScreenStateCopyWithImpl<_TunnelsScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TunnelsScreenState&&(identical(other.screen, screen) || other.screen == screen)&&const DeepCollectionEquality().equals(other.hosts, _hosts)&&(identical(other.requests, requests) || other.requests == requests));
}


@override
int get hashCode {
    return Object.hash(runtimeType,screen,const DeepCollectionEquality().hash(_hosts),requests);
}

@override
String toString() {
    return 'TunnelsScreenState(screen: $screen, hosts: $hosts, requests: $requests)';
}


}

/// @nodoc
abstract mixin class _$TunnelsScreenStateCopyWith<$Res> implements $TunnelsScreenStateCopyWith<$Res> {
  factory _$TunnelsScreenStateCopyWith(_TunnelsScreenState value, $Res Function(_TunnelsScreenState) _then) = __$TunnelsScreenStateCopyWithImpl;
@override @useResult
$Res call({
 TunnelsScreen screen, List<String> hosts, int requests
});


@override $TunnelsScreenCopyWith<$Res> get screen;

}
/// @nodoc
class __$TunnelsScreenStateCopyWithImpl<$Res>
    implements _$TunnelsScreenStateCopyWith<$Res> {
  __$TunnelsScreenStateCopyWithImpl(this._self, this._then);

  final _TunnelsScreenState _self;
  final $Res Function(_TunnelsScreenState) _then;

/// Create a copy of TunnelsScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? screen = null,Object? hosts = null,Object? requests = null,}) {
  return _then(_TunnelsScreenState(
screen: null == screen ? _self.screen : screen // ignore: cast_nullable_to_non_nullable
as TunnelsScreen,hosts: null == hosts ? _self._hosts : hosts // ignore: cast_nullable_to_non_nullable
as List<String>,requests: null == requests ? _self.requests : requests // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of TunnelsScreenState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TunnelsScreenCopyWith<$Res> get screen {
  
  return $TunnelsScreenCopyWith<$Res>(_self.screen, (value) {
    return _then(_self.copyWith(screen: value));
  });
}
}

// dart format on
