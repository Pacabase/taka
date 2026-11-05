// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agent_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AgentCommand {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentCommand);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AgentCommand()';
}


}

/// @nodoc
class $AgentCommandCopyWith<$Res>  {
$AgentCommandCopyWith(AgentCommand _, $Res Function(AgentCommand) __);
}


/// Adds pattern-matching-related methods to [AgentCommand].
extension AgentCommandPatterns on AgentCommand {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SaveTunnel value)?  save,TResult Function( RemoveTunnel value)?  remove,TResult Function( ToggleTunnel value)?  toggle,TResult Function( MoveTunnel value)?  move,TResult Function( QuitAgent value)?  quit,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SaveTunnel() when save != null:
return save(_that);case RemoveTunnel() when remove != null:
return remove(_that);case ToggleTunnel() when toggle != null:
return toggle(_that);case MoveTunnel() when move != null:
return move(_that);case QuitAgent() when quit != null:
return quit(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SaveTunnel value)  save,required TResult Function( RemoveTunnel value)  remove,required TResult Function( ToggleTunnel value)  toggle,required TResult Function( MoveTunnel value)  move,required TResult Function( QuitAgent value)  quit,}){
final _that = this;
switch (_that) {
case SaveTunnel():
return save(_that);case RemoveTunnel():
return remove(_that);case ToggleTunnel():
return toggle(_that);case MoveTunnel():
return move(_that);case QuitAgent():
return quit(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SaveTunnel value)?  save,TResult? Function( RemoveTunnel value)?  remove,TResult? Function( ToggleTunnel value)?  toggle,TResult? Function( MoveTunnel value)?  move,TResult? Function( QuitAgent value)?  quit,}){
final _that = this;
switch (_that) {
case SaveTunnel() when save != null:
return save(_that);case RemoveTunnel() when remove != null:
return remove(_that);case ToggleTunnel() when toggle != null:
return toggle(_that);case MoveTunnel() when move != null:
return move(_that);case QuitAgent() when quit != null:
return quit(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Tunnel tunnel)?  save,TResult Function( String id)?  remove,TResult Function( String id)?  toggle,TResult Function( String id,  int index)?  move,TResult Function()?  quit,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SaveTunnel() when save != null:
return save(_that.tunnel);case RemoveTunnel() when remove != null:
return remove(_that.id);case ToggleTunnel() when toggle != null:
return toggle(_that.id);case MoveTunnel() when move != null:
return move(_that.id,_that.index);case QuitAgent() when quit != null:
return quit();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Tunnel tunnel)  save,required TResult Function( String id)  remove,required TResult Function( String id)  toggle,required TResult Function( String id,  int index)  move,required TResult Function()  quit,}) {final _that = this;
switch (_that) {
case SaveTunnel():
return save(_that.tunnel);case RemoveTunnel():
return remove(_that.id);case ToggleTunnel():
return toggle(_that.id);case MoveTunnel():
return move(_that.id,_that.index);case QuitAgent():
return quit();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Tunnel tunnel)?  save,TResult? Function( String id)?  remove,TResult? Function( String id)?  toggle,TResult? Function( String id,  int index)?  move,TResult? Function()?  quit,}) {final _that = this;
switch (_that) {
case SaveTunnel() when save != null:
return save(_that.tunnel);case RemoveTunnel() when remove != null:
return remove(_that.id);case ToggleTunnel() when toggle != null:
return toggle(_that.id);case MoveTunnel() when move != null:
return move(_that.id,_that.index);case QuitAgent() when quit != null:
return quit();case _:
  return null;

}
}

}

/// @nodoc


class SaveTunnel extends AgentCommand {
  const SaveTunnel(this.tunnel): super._();
  

 final  Tunnel tunnel;

/// Create a copy of AgentCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaveTunnelCopyWith<SaveTunnel> get copyWith => _$SaveTunnelCopyWithImpl<SaveTunnel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SaveTunnel&&(identical(other.tunnel, tunnel) || other.tunnel == tunnel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,tunnel);
}

@override
String toString() {
    return 'AgentCommand.save(tunnel: $tunnel)';
}


}

/// @nodoc
abstract mixin class $SaveTunnelCopyWith<$Res> implements $AgentCommandCopyWith<$Res> {
  factory $SaveTunnelCopyWith(SaveTunnel value, $Res Function(SaveTunnel) _then) = _$SaveTunnelCopyWithImpl;
@useResult
$Res call({
 Tunnel tunnel
});


$TunnelCopyWith<$Res> get tunnel;

}
/// @nodoc
class _$SaveTunnelCopyWithImpl<$Res>
    implements $SaveTunnelCopyWith<$Res> {
  _$SaveTunnelCopyWithImpl(this._self, this._then);

  final SaveTunnel _self;
  final $Res Function(SaveTunnel) _then;

/// Create a copy of AgentCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tunnel = null,}) {
  return _then(SaveTunnel(
null == tunnel ? _self.tunnel : tunnel // ignore: cast_nullable_to_non_nullable
as Tunnel,
  ));
}

/// Create a copy of AgentCommand
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


class RemoveTunnel extends AgentCommand {
  const RemoveTunnel(this.id): super._();
  

 final  String id;

/// Create a copy of AgentCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoveTunnelCopyWith<RemoveTunnel> get copyWith => _$RemoveTunnelCopyWithImpl<RemoveTunnel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoveTunnel&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id);
}

@override
String toString() {
    return 'AgentCommand.remove(id: $id)';
}


}

/// @nodoc
abstract mixin class $RemoveTunnelCopyWith<$Res> implements $AgentCommandCopyWith<$Res> {
  factory $RemoveTunnelCopyWith(RemoveTunnel value, $Res Function(RemoveTunnel) _then) = _$RemoveTunnelCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$RemoveTunnelCopyWithImpl<$Res>
    implements $RemoveTunnelCopyWith<$Res> {
  _$RemoveTunnelCopyWithImpl(this._self, this._then);

  final RemoveTunnel _self;
  final $Res Function(RemoveTunnel) _then;

/// Create a copy of AgentCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(RemoveTunnel(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ToggleTunnel extends AgentCommand {
  const ToggleTunnel(this.id): super._();
  

 final  String id;

/// Create a copy of AgentCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToggleTunnelCopyWith<ToggleTunnel> get copyWith => _$ToggleTunnelCopyWithImpl<ToggleTunnel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ToggleTunnel&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id);
}

@override
String toString() {
    return 'AgentCommand.toggle(id: $id)';
}


}

/// @nodoc
abstract mixin class $ToggleTunnelCopyWith<$Res> implements $AgentCommandCopyWith<$Res> {
  factory $ToggleTunnelCopyWith(ToggleTunnel value, $Res Function(ToggleTunnel) _then) = _$ToggleTunnelCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$ToggleTunnelCopyWithImpl<$Res>
    implements $ToggleTunnelCopyWith<$Res> {
  _$ToggleTunnelCopyWithImpl(this._self, this._then);

  final ToggleTunnel _self;
  final $Res Function(ToggleTunnel) _then;

/// Create a copy of AgentCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(ToggleTunnel(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class MoveTunnel extends AgentCommand {
  const MoveTunnel(this.id, this.index): super._();
  

 final  String id;
 final  int index;

/// Create a copy of AgentCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveTunnelCopyWith<MoveTunnel> get copyWith => _$MoveTunnelCopyWithImpl<MoveTunnel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveTunnel&&(identical(other.id, id) || other.id == id)&&(identical(other.index, index) || other.index == index));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,index);
}

@override
String toString() {
    return 'AgentCommand.move(id: $id, index: $index)';
}


}

/// @nodoc
abstract mixin class $MoveTunnelCopyWith<$Res> implements $AgentCommandCopyWith<$Res> {
  factory $MoveTunnelCopyWith(MoveTunnel value, $Res Function(MoveTunnel) _then) = _$MoveTunnelCopyWithImpl;
@useResult
$Res call({
 String id, int index
});




}
/// @nodoc
class _$MoveTunnelCopyWithImpl<$Res>
    implements $MoveTunnelCopyWith<$Res> {
  _$MoveTunnelCopyWithImpl(this._self, this._then);

  final MoveTunnel _self;
  final $Res Function(MoveTunnel) _then;

/// Create a copy of AgentCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,Object? index = null,}) {
  return _then(MoveTunnel(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class QuitAgent extends AgentCommand {
  const QuitAgent(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is QuitAgent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AgentCommand.quit()';
}


}




// dart format on
