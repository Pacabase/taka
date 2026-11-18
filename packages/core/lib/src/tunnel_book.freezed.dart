// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tunnel_book.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TunnelBook {

 List<Tunnel> get tunnels; Map<String, TunnelColour> get groupColours;
/// Create a copy of TunnelBook
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TunnelBookCopyWith<TunnelBook> get copyWith => _$TunnelBookCopyWithImpl<TunnelBook>(this as TunnelBook, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TunnelBook;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TunnelBook&&const DeepCollectionEquality().equals(other.tunnels, _this.tunnels)&&const DeepCollectionEquality().equals(other.groupColours, _this.groupColours));
}


@override
int get hashCode {
  final _this = this as TunnelBook;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.tunnels),const DeepCollectionEquality().hash(_this.groupColours));
}

@override
String toString() {
  final _this = this as TunnelBook;
  return 'TunnelBook(tunnels: ${_this.tunnels}, groupColours: ${_this.groupColours})';
}


}

/// @nodoc
abstract mixin class $TunnelBookCopyWith<$Res>  {
  factory $TunnelBookCopyWith(TunnelBook value, $Res Function(TunnelBook) _then) = _$TunnelBookCopyWithImpl;
@useResult
$Res call({
 List<Tunnel> tunnels, Map<String, TunnelColour> groupColours
});




}
/// @nodoc
class _$TunnelBookCopyWithImpl<$Res>
    implements $TunnelBookCopyWith<$Res> {
  _$TunnelBookCopyWithImpl(this._self, this._then);

  final TunnelBook _self;
  final $Res Function(TunnelBook) _then;

/// Create a copy of TunnelBook
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tunnels = null,Object? groupColours = null,}) {
  return _then(TunnelBook(
tunnels: null == tunnels ? _self.tunnels : tunnels // ignore: cast_nullable_to_non_nullable
as List<Tunnel>,groupColours: null == groupColours ? _self.groupColours : groupColours // ignore: cast_nullable_to_non_nullable
as Map<String, TunnelColour>,
  ));
}

}


/// Adds pattern-matching-related methods to [TunnelBook].
extension TunnelBookPatterns on TunnelBook {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TunnelBook value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TunnelBook() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TunnelBook value)  $default,){
final _that = this;
switch (_that) {
case _TunnelBook():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TunnelBook value)?  $default,){
final _that = this;
switch (_that) {
case _TunnelBook() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Tunnel> tunnels,  Map<String, TunnelColour> groupColours)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TunnelBook() when $default != null:
return $default(_that.tunnels,_that.groupColours);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Tunnel> tunnels,  Map<String, TunnelColour> groupColours)  $default,) {final _that = this;
switch (_that) {
case _TunnelBook():
return $default(_that.tunnels,_that.groupColours);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Tunnel> tunnels,  Map<String, TunnelColour> groupColours)?  $default,) {final _that = this;
switch (_that) {
case _TunnelBook() when $default != null:
return $default(_that.tunnels,_that.groupColours);case _:
  return null;

}
}

}

/// @nodoc


class _TunnelBook extends TunnelBook {
  const _TunnelBook({ List<Tunnel> tunnels = const [],  Map<String, TunnelColour> groupColours = const {}}): _tunnels = tunnels,_groupColours = groupColours,super._();
  

 final  List<Tunnel> _tunnels;
@override@JsonKey() List<Tunnel> get tunnels {
  if (_tunnels is EqualUnmodifiableListView) return _tunnels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tunnels);
}

 final  Map<String, TunnelColour> _groupColours;
@override@JsonKey() Map<String, TunnelColour> get groupColours {
  if (_groupColours is EqualUnmodifiableMapView) return _groupColours;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_groupColours);
}


/// Create a copy of TunnelBook
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TunnelBookCopyWith<_TunnelBook> get copyWith => __$TunnelBookCopyWithImpl<_TunnelBook>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TunnelBook&&const DeepCollectionEquality().equals(other.tunnels, _tunnels)&&const DeepCollectionEquality().equals(other.groupColours, _groupColours));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_tunnels),const DeepCollectionEquality().hash(_groupColours));
}

@override
String toString() {
    return 'TunnelBook(tunnels: $tunnels, groupColours: $groupColours)';
}


}

/// @nodoc
abstract mixin class _$TunnelBookCopyWith<$Res> implements $TunnelBookCopyWith<$Res> {
  factory _$TunnelBookCopyWith(_TunnelBook value, $Res Function(_TunnelBook) _then) = __$TunnelBookCopyWithImpl;
@override @useResult
$Res call({
 List<Tunnel> tunnels, Map<String, TunnelColour> groupColours
});




}
/// @nodoc
class __$TunnelBookCopyWithImpl<$Res>
    implements _$TunnelBookCopyWith<$Res> {
  __$TunnelBookCopyWithImpl(this._self, this._then);

  final _TunnelBook _self;
  final $Res Function(_TunnelBook) _then;

/// Create a copy of TunnelBook
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tunnels = null,Object? groupColours = null,}) {
  return _then(_TunnelBook(
tunnels: null == tunnels ? _self._tunnels : tunnels // ignore: cast_nullable_to_non_nullable
as List<Tunnel>,groupColours: null == groupColours ? _self._groupColours : groupColours // ignore: cast_nullable_to_non_nullable
as Map<String, TunnelColour>,
  ));
}


}

// dart format on
