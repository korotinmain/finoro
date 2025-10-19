// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MoneyTx {

 String get id; DateTime get date; String get description; String get category; double get amount; Currency get currency; bool get isIncome;
/// Create a copy of MoneyTx
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoneyTxCopyWith<MoneyTx> get copyWith => _$MoneyTxCopyWithImpl<MoneyTx>(this as MoneyTx, _$identity);

  /// Serializes this MoneyTx to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoneyTx&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.isIncome, isIncome) || other.isIncome == isIncome));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,description,category,amount,currency,isIncome);

@override
String toString() {
  return 'MoneyTx(id: $id, date: $date, description: $description, category: $category, amount: $amount, currency: $currency, isIncome: $isIncome)';
}


}

/// @nodoc
abstract mixin class $MoneyTxCopyWith<$Res>  {
  factory $MoneyTxCopyWith(MoneyTx value, $Res Function(MoneyTx) _then) = _$MoneyTxCopyWithImpl;
@useResult
$Res call({
 String id, DateTime date, String description, String category, double amount, Currency currency, bool isIncome
});




}
/// @nodoc
class _$MoneyTxCopyWithImpl<$Res>
    implements $MoneyTxCopyWith<$Res> {
  _$MoneyTxCopyWithImpl(this._self, this._then);

  final MoneyTx _self;
  final $Res Function(MoneyTx) _then;

/// Create a copy of MoneyTx
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? description = null,Object? category = null,Object? amount = null,Object? currency = null,Object? isIncome = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,isIncome: null == isIncome ? _self.isIncome : isIncome // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MoneyTx].
extension MoneyTxPatterns on MoneyTx {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MoneyTx value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MoneyTx() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MoneyTx value)  $default,){
final _that = this;
switch (_that) {
case _MoneyTx():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MoneyTx value)?  $default,){
final _that = this;
switch (_that) {
case _MoneyTx() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime date,  String description,  String category,  double amount,  Currency currency,  bool isIncome)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MoneyTx() when $default != null:
return $default(_that.id,_that.date,_that.description,_that.category,_that.amount,_that.currency,_that.isIncome);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime date,  String description,  String category,  double amount,  Currency currency,  bool isIncome)  $default,) {final _that = this;
switch (_that) {
case _MoneyTx():
return $default(_that.id,_that.date,_that.description,_that.category,_that.amount,_that.currency,_that.isIncome);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime date,  String description,  String category,  double amount,  Currency currency,  bool isIncome)?  $default,) {final _that = this;
switch (_that) {
case _MoneyTx() when $default != null:
return $default(_that.id,_that.date,_that.description,_that.category,_that.amount,_that.currency,_that.isIncome);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MoneyTx implements MoneyTx {
  const _MoneyTx({required this.id, required this.date, required this.description, required this.category, required this.amount, required this.currency, required this.isIncome});
  factory _MoneyTx.fromJson(Map<String, dynamic> json) => _$MoneyTxFromJson(json);

@override final  String id;
@override final  DateTime date;
@override final  String description;
@override final  String category;
@override final  double amount;
@override final  Currency currency;
@override final  bool isIncome;

/// Create a copy of MoneyTx
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoneyTxCopyWith<_MoneyTx> get copyWith => __$MoneyTxCopyWithImpl<_MoneyTx>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoneyTxToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoneyTx&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.isIncome, isIncome) || other.isIncome == isIncome));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,description,category,amount,currency,isIncome);

@override
String toString() {
  return 'MoneyTx(id: $id, date: $date, description: $description, category: $category, amount: $amount, currency: $currency, isIncome: $isIncome)';
}


}

/// @nodoc
abstract mixin class _$MoneyTxCopyWith<$Res> implements $MoneyTxCopyWith<$Res> {
  factory _$MoneyTxCopyWith(_MoneyTx value, $Res Function(_MoneyTx) _then) = __$MoneyTxCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime date, String description, String category, double amount, Currency currency, bool isIncome
});




}
/// @nodoc
class __$MoneyTxCopyWithImpl<$Res>
    implements _$MoneyTxCopyWith<$Res> {
  __$MoneyTxCopyWithImpl(this._self, this._then);

  final _MoneyTx _self;
  final $Res Function(_MoneyTx) _then;

/// Create a copy of MoneyTx
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? description = null,Object? category = null,Object? amount = null,Object? currency = null,Object? isIncome = null,}) {
  return _then(_MoneyTx(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,isIncome: null == isIncome ? _self.isIncome : isIncome // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
