import 'package:freezed_annotation/freezed_annotation.dart';
import 'currency.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
abstract class MoneyTx with _$MoneyTx {
  const factory MoneyTx({
    required String id,
    required DateTime date,
    required String description,
    required String category,
    required double amount, // positive; direction via isIncome
    @CurrencyConverter() required Currency currency,
    required bool isIncome,
  }) = _MoneyTx;

  factory MoneyTx.fromJson(Map<String, dynamic> json) =>
      _$MoneyTxFromJson(json);
}
