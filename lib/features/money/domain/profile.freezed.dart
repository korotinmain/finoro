// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Profile {

 double get goalUsd; double get uahPerUsd; double get uahPerEur;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.goalUsd, goalUsd) || other.goalUsd == goalUsd)&&(identical(other.uahPerUsd, uahPerUsd) || other.uahPerUsd == uahPerUsd)&&(identical(other.uahPerEur, uahPerEur) || other.uahPerEur == uahPerEur));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,goalUsd,uahPerUsd,uahPerEur);

@override
String toString() {
  return 'Profile(goalUsd: $goalUsd, uahPerUsd: $uahPerUsd, uahPerEur: $uahPerEur)';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 double goalUsd, double uahPerUsd, double uahPerEur
});




}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? goalUsd = null,Object? uahPerUsd = null,Object? uahPerEur = null,}) {
  return _then(_self.copyWith(
goalUsd: null == goalUsd ? _self.goalUsd : goalUsd // ignore: cast_nullable_to_non_nullable
as double,uahPerUsd: null == uahPerUsd ? _self.uahPerUsd : uahPerUsd // ignore: cast_nullable_to_non_nullable
as double,uahPerEur: null == uahPerEur ? _self.uahPerEur : uahPerEur // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double goalUsd,  double uahPerUsd,  double uahPerEur)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.goalUsd,_that.uahPerUsd,_that.uahPerEur);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double goalUsd,  double uahPerUsd,  double uahPerEur)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.goalUsd,_that.uahPerUsd,_that.uahPerEur);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double goalUsd,  double uahPerUsd,  double uahPerEur)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.goalUsd,_that.uahPerUsd,_that.uahPerEur);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile implements Profile {
  const _Profile({this.goalUsd = 5000, this.uahPerUsd = 41.5, this.uahPerEur = 45.5});
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override@JsonKey() final  double goalUsd;
@override@JsonKey() final  double uahPerUsd;
@override@JsonKey() final  double uahPerEur;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.goalUsd, goalUsd) || other.goalUsd == goalUsd)&&(identical(other.uahPerUsd, uahPerUsd) || other.uahPerUsd == uahPerUsd)&&(identical(other.uahPerEur, uahPerEur) || other.uahPerEur == uahPerEur));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,goalUsd,uahPerUsd,uahPerEur);

@override
String toString() {
  return 'Profile(goalUsd: $goalUsd, uahPerUsd: $uahPerUsd, uahPerEur: $uahPerEur)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 double goalUsd, double uahPerUsd, double uahPerEur
});




}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? goalUsd = null,Object? uahPerUsd = null,Object? uahPerEur = null,}) {
  return _then(_Profile(
goalUsd: null == goalUsd ? _self.goalUsd : goalUsd // ignore: cast_nullable_to_non_nullable
as double,uahPerUsd: null == uahPerUsd ? _self.uahPerUsd : uahPerUsd // ignore: cast_nullable_to_non_nullable
as double,uahPerEur: null == uahPerEur ? _self.uahPerEur : uahPerEur // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
