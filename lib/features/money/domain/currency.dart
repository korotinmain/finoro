// ignore_for_file: constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';

enum Currency { UAH, USD, EUR }

class CurrencyConverter implements JsonConverter<Currency, String> {
  const CurrencyConverter();

  @override
  Currency fromJson(String json) =>
      Currency.values.firstWhere((e) => e.name == json);

  @override
  String toJson(Currency object) => object.name;
}
