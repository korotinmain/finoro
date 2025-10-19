// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MoneyTx _$MoneyTxFromJson(Map<String, dynamic> json) => _MoneyTx(
  id: json['id'] as String,
  date: DateTime.parse(json['date'] as String),
  description: json['description'] as String,
  category: json['category'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: const CurrencyConverter().fromJson(json['currency'] as String),
  isIncome: json['isIncome'] as bool,
);

Map<String, dynamic> _$MoneyTxToJson(_MoneyTx instance) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date.toIso8601String(),
  'description': instance.description,
  'category': instance.category,
  'amount': instance.amount,
  'currency': const CurrencyConverter().toJson(instance.currency),
  'isIncome': instance.isIncome,
};
