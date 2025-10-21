import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Expenses tab for managing expense transactions
class ExpensesTab extends StatelessWidget {
  const ExpensesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Center(
      child: Text(
        t.tabExpenses,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
