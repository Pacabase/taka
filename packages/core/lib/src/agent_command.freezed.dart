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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SaveTunnel value)?  save,TResult Function( RemoveTunnel value)?  remove,TResult Function( ToggleTunnel value)?  toggle,TResult Function( MoveTunnel value)?  move,TResult Function( TrustHostKey value)?  trustHostKey,TResult Function( ImportTunnels value)?  importTunnels,TResult Function( ExportTunnels value)?  exportTunnels,TResult Function( QuitAgent value)?  quit,TResult Function( SetLaunchAtLogin value)?  setLaunchAtLogin,TResult Function( SetDebugLogging value)?  setDebugLogging,TResult Function( ShowLogs value)?  showLogs,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SaveTunnel() when save != null:
return save(_that);case RemoveTunnel() when remove != null:
return remove(_that);case ToggleTunnel() when toggle != null:
return toggle(_that);case MoveTunnel() when move != null:
return move(_that);case TrustHostKey() when trustHostKey != null:
return trustHostKey(_that);case ImportTunnels() when importTunnels != null:
return importTunnels(_that);case ExportTunnels() when exportTunnels != null:
return exportTunnels(_that);case QuitAgent() when quit != null:
return quit(_that);case SetLaunchAtLogin() when setLaunchAtLogin != null:
return setLaunchAtLogin(_that);case SetDebugLogging() when setDebugLogging != null:
return setDebugLogging(_that);case ShowLogs() when showLogs != null:
return showLogs(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SaveTunnel value)  save,required TResult Function( RemoveTunnel value)  remove,required TResult Function( ToggleTunnel value)  toggle,required TResult Function( MoveTunnel value)  move,required TResult Function( TrustHostKey value)  trustHostKey,required TResult Function( ImportTunnels value)  importTunnels,required TResult Function( ExportTunnels value)  exportTunnels,required TResult Function( QuitAgent value)  quit,required TResult Function( SetLaunchAtLogin value)  setLaunchAtLogin,required TResult Function( SetDebugLogging value)  setDebugLogging,required TResult Function( ShowLogs value)  showLogs,}){
final _that = this;
switch (_that) {
case SaveTunnel():
return save(_that);case RemoveTunnel():
return remove(_that);case ToggleTunnel():
return toggle(_that);case MoveTunnel():
return move(_that);case TrustHostKey():
return trustHostKey(_that);case ImportTunnels():
return importTunnels(_that);case ExportTunnels():
return exportTunnels(_that);case QuitAgent():
return quit(_that);case SetLaunchAtLogin():
return setLaunchAtLogin(_that);case SetDebugLogging():
return setDebugLogging(_that);case ShowLogs():
return showLogs(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SaveTunnel value)?  save,TResult? Function( RemoveTunnel value)?  remove,TResult? Function( ToggleTunnel value)?  toggle,TResult? Function( MoveTunnel value)?  move,TResult? Function( TrustHostKey value)?  trustHostKey,TResult? Function( ImportTunnels value)?  importTunnels,TResult? Function( ExportTunnels value)?  exportTunnels,TResult? Function( QuitAgent value)?  quit,TResult? Function( SetLaunchAtLogin value)?  setLaunchAtLogin,TResult? Function( SetDebugLogging value)?  setDebugLogging,TResult? Function( ShowLogs value)?  showLogs,}){
final _that = this;
switch (_that) {
case SaveTunnel() when save != null:
return save(_that);case RemoveTunnel() when remove != null:
return remove(_that);case ToggleTunnel() when toggle != null:
return toggle(_that);case MoveTunnel() when move != null:
return move(_that);case TrustHostKey() when trustHostKey != null:
return trustHostKey(_that);case ImportTunnels() when importTunnels != null:
return importTunnels(_that);case ExportTunnels() when exportTunnels != null:
return exportTunnels(_that);case QuitAgent() when quit != null:
return quit(_that);case SetLaunchAtLogin() when setLaunchAtLogin != null:
return setLaunchAtLogin(_that);case SetDebugLogging() when setDebugLogging != null:
return setDebugLogging(_that);case ShowLogs() when showLogs != null:
return showLogs(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Tunnel tunnel)?  save,TResult Function( String id)?  remove,TResult Function( String id)?  toggle,TResult Function( String id,  int index)?  move,TResult Function( String id,  String fingerprint)?  trustHostKey,TResult Function( List<Tunnel> tunnels)?  importTunnels,TResult Function( String path)?  exportTunnels,TResult Function()?  quit,TResult Function( bool on)?  setLaunchAtLogin,TResult Function( bool on)?  setDebugLogging,TResult Function()?  showLogs,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SaveTunnel() when save != null:
return save(_that.tunnel);case RemoveTunnel() when remove != null:
return remove(_that.id);case ToggleTunnel() when toggle != null:
return toggle(_that.id);case MoveTunnel() when move != null:
return move(_that.id,_that.index);case TrustHostKey() when trustHostKey != null:
return trustHostKey(_that.id,_that.fingerprint);case ImportTunnels() when importTunnels != null:
return importTunnels(_that.tunnels);case ExportTunnels() when exportTunnels != null:
return exportTunnels(_that.path);case QuitAgent() when quit != null:
return quit();case SetLaunchAtLogin() when setLaunchAtLogin != null:
return setLaunchAtLogin(_that.on);case SetDebugLogging() when setDebugLogging != null:
return setDebugLogging(_that.on);case ShowLogs() when showLogs != null:
return showLogs();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Tunnel tunnel)  save,required TResult Function( String id)  remove,required TResult Function( String id)  toggle,required TResult Function( String id,  int index)  move,required TResult Function( String id,  String fingerprint)  trustHostKey,required TResult Function( List<Tunnel> tunnels)  importTunnels,required TResult Function( String path)  exportTunnels,required TResult Function()  quit,required TResult Function( bool on)  setLaunchAtLogin,required TResult Function( bool on)  setDebugLogging,required TResult Function()  showLogs,}) {final _that = this;
switch (_that) {
case SaveTunnel():
return save(_that.tunnel);case RemoveTunnel():
return remove(_that.id);case ToggleTunnel():
return toggle(_that.id);case MoveTunnel():
return move(_that.id,_that.index);case TrustHostKey():
return trustHostKey(_that.id,_that.fingerprint);case ImportTunnels():
return importTunnels(_that.tunnels);case ExportTunnels():
return exportTunnels(_that.path);case QuitAgent():
return quit();case SetLaunchAtLogin():
return setLaunchAtLogin(_that.on);case SetDebugLogging():
return setDebugLogging(_that.on);case ShowLogs():
return showLogs();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Tunnel tunnel)?  save,TResult? Function( String id)?  remove,TResult? Function( String id)?  toggle,TResult? Function( String id,  int index)?  move,TResult? Function( String id,  String fingerprint)?  trustHostKey,TResult? Function( List<Tunnel> tunnels)?  importTunnels,TResult? Function( String path)?  exportTunnels,TResult? Function()?  quit,TResult? Function( bool on)?  setLaunchAtLogin,TResult? Function( bool on)?  setDebugLogging,TResult? Function()?  showLogs,}) {final _that = this;
switch (_that) {
case SaveTunnel() when save != null:
return save(_that.tunnel);case RemoveTunnel() when remove != null:
return remove(_that.id);case ToggleTunnel() when toggle != null:
return toggle(_that.id);case MoveTunnel() when move != null:
return move(_that.id,_that.index);case TrustHostKey() when trustHostKey != null:
return trustHostKey(_that.id,_that.fingerprint);case ImportTunnels() when importTunnels != null:
return importTunnels(_that.tunnels);case ExportTunnels() when exportTunnels != null:
return exportTunnels(_that.path);case QuitAgent() when quit != null:
return quit();case SetLaunchAtLogin() when setLaunchAtLogin != null:
return setLaunchAtLogin(_that.on);case SetDebugLogging() when setDebugLogging != null:
return setDebugLogging(_that.on);case ShowLogs() when showLogs != null:
return showLogs();case _:
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


class TrustHostKey extends AgentCommand {
  const TrustHostKey(this.id, this.fingerprint): super._();
  

 final  String id;
 final  String fingerprint;

/// Create a copy of AgentCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrustHostKeyCopyWith<TrustHostKey> get copyWith => _$TrustHostKeyCopyWithImpl<TrustHostKey>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TrustHostKey&&(identical(other.id, id) || other.id == id)&&(identical(other.fingerprint, fingerprint) || other.fingerprint == fingerprint));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,fingerprint);
}

@override
String toString() {
    return 'AgentCommand.trustHostKey(id: $id, fingerprint: $fingerprint)';
}


}

/// @nodoc
abstract mixin class $TrustHostKeyCopyWith<$Res> implements $AgentCommandCopyWith<$Res> {
  factory $TrustHostKeyCopyWith(TrustHostKey value, $Res Function(TrustHostKey) _then) = _$TrustHostKeyCopyWithImpl;
@useResult
$Res call({
 String id, String fingerprint
});




}
/// @nodoc
class _$TrustHostKeyCopyWithImpl<$Res>
    implements $TrustHostKeyCopyWith<$Res> {
  _$TrustHostKeyCopyWithImpl(this._self, this._then);

  final TrustHostKey _self;
  final $Res Function(TrustHostKey) _then;

/// Create a copy of AgentCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fingerprint = null,}) {
  return _then(TrustHostKey(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,null == fingerprint ? _self.fingerprint : fingerprint // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ImportTunnels extends AgentCommand {
  const ImportTunnels( List<Tunnel> tunnels): _tunnels = tunnels,super._();
  

 final  List<Tunnel> _tunnels;
 List<Tunnel> get tunnels {
  if (_tunnels is EqualUnmodifiableListView) return _tunnels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tunnels);
}


/// Create a copy of AgentCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportTunnelsCopyWith<ImportTunnels> get copyWith => _$ImportTunnelsCopyWithImpl<ImportTunnels>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportTunnels&&const DeepCollectionEquality().equals(other.tunnels, _tunnels));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_tunnels));
}

@override
String toString() {
    return 'AgentCommand.importTunnels(tunnels: $tunnels)';
}


}

/// @nodoc
abstract mixin class $ImportTunnelsCopyWith<$Res> implements $AgentCommandCopyWith<$Res> {
  factory $ImportTunnelsCopyWith(ImportTunnels value, $Res Function(ImportTunnels) _then) = _$ImportTunnelsCopyWithImpl;
@useResult
$Res call({
 List<Tunnel> tunnels
});




}
/// @nodoc
class _$ImportTunnelsCopyWithImpl<$Res>
    implements $ImportTunnelsCopyWith<$Res> {
  _$ImportTunnelsCopyWithImpl(this._self, this._then);

  final ImportTunnels _self;
  final $Res Function(ImportTunnels) _then;

/// Create a copy of AgentCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tunnels = null,}) {
  return _then(ImportTunnels(
null == tunnels ? _self._tunnels : tunnels // ignore: cast_nullable_to_non_nullable
as List<Tunnel>,
  ));
}


}

/// @nodoc


class ExportTunnels extends AgentCommand {
  const ExportTunnels(this.path): super._();
  

 final  String path;

/// Create a copy of AgentCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportTunnelsCopyWith<ExportTunnels> get copyWith => _$ExportTunnelsCopyWithImpl<ExportTunnels>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportTunnels&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode {
    return Object.hash(runtimeType,path);
}

@override
String toString() {
    return 'AgentCommand.exportTunnels(path: $path)';
}


}

/// @nodoc
abstract mixin class $ExportTunnelsCopyWith<$Res> implements $AgentCommandCopyWith<$Res> {
  factory $ExportTunnelsCopyWith(ExportTunnels value, $Res Function(ExportTunnels) _then) = _$ExportTunnelsCopyWithImpl;
@useResult
$Res call({
 String path
});




}
/// @nodoc
class _$ExportTunnelsCopyWithImpl<$Res>
    implements $ExportTunnelsCopyWith<$Res> {
  _$ExportTunnelsCopyWithImpl(this._self, this._then);

  final ExportTunnels _self;
  final $Res Function(ExportTunnels) _then;

/// Create a copy of AgentCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(ExportTunnels(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
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




/// @nodoc


class SetLaunchAtLogin extends AgentCommand {
  const SetLaunchAtLogin({required this.on}): super._();
  

 final  bool on;

/// Create a copy of AgentCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetLaunchAtLoginCopyWith<SetLaunchAtLogin> get copyWith => _$SetLaunchAtLoginCopyWithImpl<SetLaunchAtLogin>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SetLaunchAtLogin&&(identical(other.on, on) || other.on == on));
}


@override
int get hashCode {
    return Object.hash(runtimeType,on);
}

@override
String toString() {
    return 'AgentCommand.setLaunchAtLogin(on: $on)';
}


}

/// @nodoc
abstract mixin class $SetLaunchAtLoginCopyWith<$Res> implements $AgentCommandCopyWith<$Res> {
  factory $SetLaunchAtLoginCopyWith(SetLaunchAtLogin value, $Res Function(SetLaunchAtLogin) _then) = _$SetLaunchAtLoginCopyWithImpl;
@useResult
$Res call({
 bool on
});




}
/// @nodoc
class _$SetLaunchAtLoginCopyWithImpl<$Res>
    implements $SetLaunchAtLoginCopyWith<$Res> {
  _$SetLaunchAtLoginCopyWithImpl(this._self, this._then);

  final SetLaunchAtLogin _self;
  final $Res Function(SetLaunchAtLogin) _then;

/// Create a copy of AgentCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? on = null,}) {
  return _then(SetLaunchAtLogin(
on: null == on ? _self.on : on // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class SetDebugLogging extends AgentCommand {
  const SetDebugLogging({required this.on}): super._();
  

 final  bool on;

/// Create a copy of AgentCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetDebugLoggingCopyWith<SetDebugLogging> get copyWith => _$SetDebugLoggingCopyWithImpl<SetDebugLogging>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SetDebugLogging&&(identical(other.on, on) || other.on == on));
}


@override
int get hashCode {
    return Object.hash(runtimeType,on);
}

@override
String toString() {
    return 'AgentCommand.setDebugLogging(on: $on)';
}


}

/// @nodoc
abstract mixin class $SetDebugLoggingCopyWith<$Res> implements $AgentCommandCopyWith<$Res> {
  factory $SetDebugLoggingCopyWith(SetDebugLogging value, $Res Function(SetDebugLogging) _then) = _$SetDebugLoggingCopyWithImpl;
@useResult
$Res call({
 bool on
});




}
/// @nodoc
class _$SetDebugLoggingCopyWithImpl<$Res>
    implements $SetDebugLoggingCopyWith<$Res> {
  _$SetDebugLoggingCopyWithImpl(this._self, this._then);

  final SetDebugLogging _self;
  final $Res Function(SetDebugLogging) _then;

/// Create a copy of AgentCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? on = null,}) {
  return _then(SetDebugLogging(
on: null == on ? _self.on : on // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ShowLogs extends AgentCommand {
  const ShowLogs(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ShowLogs);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AgentCommand.showLogs()';
}


}




// dart format on
