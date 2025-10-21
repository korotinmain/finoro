import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// History tab for viewing transaction history
class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Center(
      child: Text(
        t.tabHistory,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
