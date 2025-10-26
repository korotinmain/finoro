import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';
import 'package:money_tracker/features/money/domain/entities/transaction_summary.dart';
import 'package:money_tracker/features/money/domain/transaction.dart';
import 'package:money_tracker/features/money/presentation/providers/money_providers.dart';

class HistoryTab extends ConsumerWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final transactionsAsync = ref.watch(userTransactionsProvider);
    final summary = ref.watch(transactionSummaryProvider);

    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return _InsightsEmptyState(t: t);
        }
        return _InsightsDashboard(
          t: t,
          summary: summary,
          transactions: transactions,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing24),
          child: Text(error.toString()),
        ),
      ),
    );
  }
}

class _InsightsEmptyState extends StatelessWidget {
  const _InsightsEmptyState({required this.t});

  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacing24,
          vertical: AppSizes.spacing36,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.historyEmptyTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSizes.spacing12),
            Text(
              t.historyEmptyDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightsDashboard extends StatelessWidget {
  const _InsightsDashboard({
    required this.t,
    required this.summary,
    required this.transactions,
  });

  final AppLocalizations t;
  final TransactionSummary summary;
  final List<MoneyTx> transactions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final latestTransactions = transactions.take(5).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spacing24,
              AppSizes.spacing24,
              AppSizes.spacing24,
              AppSizes.spacing12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.historyTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing8),
                Text(
                  t.historySubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing24),
                _InsightsSummaryCards(summary: summary, t: t),
                const SizedBox(height: AppSizes.spacing24),
                _CategoryBreakdown(transactions: transactions, t: t),
                const SizedBox(height: AppSizes.spacing24),
                Text(
                  t.recentTransactionsTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final tx = latestTransactions[index];
              return _TransactionRow(transaction: tx);
            },
            childCount: latestTransactions.length,
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: AppSizes.spacing36)),
      ],
    );
  }
}

class _InsightsSummaryCards extends StatelessWidget {
  const _InsightsSummaryCards({required this.summary, required this.t});

  final TransactionSummary summary;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.spacing16,
      runSpacing: AppSizes.spacing16,
      children: [
        _SummaryCard(
          title: t.totalExpenseLabel,
          value: '-${summary.totalExpense.toStringAsFixed(2)}',
          gradient: AppColors.primaryGradient,
        ),
        _SummaryCard(
          title: t.totalIncomeLabel,
          value: '+${summary.totalIncome.toStringAsFixed(2)}',
          gradient: LinearGradient(
            colors: [Colors.greenAccent.withValues(alpha: 0.2), Colors.greenAccent],
          ),
        ),
        _SummaryCard(
          title: t.balanceLabel,
          value: summary.balance.toStringAsFixed(2),
          gradient: LinearGradient(
            colors: [AppColors.lightBlue.withValues(alpha: 0.2), AppColors.lightBlue],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.gradient,
  });

  final String title;
  final String value;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 200,
      padding: const EdgeInsets.all(AppSizes.spacing20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXXLarge),
        border: Border.all(color: AppColors.white(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.transactions, required this.t});

  final List<MoneyTx> transactions;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenses = transactions.where((tx) => !tx.isIncome);
    final total = expenses.fold<double>(0, (sum, tx) => sum + tx.amount);
    final Map<String, double> categoryTotals = {};
    for (final tx in expenses) {
      categoryTotals.update(tx.category, (value) => value + tx.amount,
          ifAbsent: () => tx.amount);
    }
    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) {
      return Container();
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppSizes.radiusXXLarge),
        border: Border.all(color: AppColors.white(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.categoryBreakdownTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.spacing16),
          ...entries.take(5).map((entry) {
            final percentage = total == 0 ? 0 : entry.value / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spacing12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: theme.textTheme.bodyMedium),
                      Text('${(percentage * 100).toStringAsFixed(0)}%'),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacing6),
                  LinearProgressIndicator(
                    value: percentage.clamp(0.0, 1.0).toDouble(),
                    backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(
                      AppColors.vibrantPurple.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});

  final MoneyTx transaction;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat.MMMd();
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing24,
        vertical: AppSizes.spacing8,
      ),
      title: Text(transaction.description),
      subtitle: Text('${transaction.category} • ${formatter.format(transaction.date)}'),
      trailing: Text(
        '${transaction.isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} ${transaction.currency.name}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: transaction.isIncome ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
