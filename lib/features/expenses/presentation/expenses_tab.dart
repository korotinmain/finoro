import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';
import 'package:money_tracker/core/utils/haptic_feedback.dart';
import 'package:money_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:money_tracker/features/money/domain/currency.dart';
import 'package:money_tracker/features/money/domain/entities/transaction_summary.dart';
import 'package:money_tracker/features/money/domain/transaction.dart';
import 'package:money_tracker/features/money/presentation/providers/money_providers.dart';
import 'package:money_tracker/ui/widgets/gradient_button.dart';

class ExpensesTab extends ConsumerWidget {
  const ExpensesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final transactionsAsync = ref.watch(userTransactionsProvider);
    final summary = ref.watch(transactionSummaryProvider);

    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return _ExpensesEmptyState(
            onCreateExpense: () => _showAddExpenseSheet(context, ref, t),
            t: t,
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.spacing24,
                      AppSizes.spacing24,
                      AppSizes.spacing24,
                      AppSizes.spacing12,
                    ),
                    child: _ExpensesSummaryCard(summary: summary, t: t),
                  ),
                ),
                SliverList.separated(
                  itemCount: transactions.length,
                  separatorBuilder:
                      (_, __) => const Divider(height: 1, thickness: 0.5),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return _TransactionTile(transaction: tx, t: t, ref: ref);
                  },
                ),
                const SliverPadding(
                  padding: EdgeInsets.only(bottom: AppSizes.spacing36),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddExpenseSheet(context, ref, t),
            backgroundColor: AppColors.vibrantPurple,
            label: Row(
              children: [
                const Icon(Icons.add_rounded, color: Colors.white),
                const SizedBox(width: AppSizes.spacing6),
                Text(
                  t.createExpenseButton,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spacing24),
              child: Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
    );
  }
}

class _ExpensesEmptyState extends StatelessWidget {
  const _ExpensesEmptyState({required this.onCreateExpense, required this.t});

  final Future<void> Function() onCreateExpense;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacing24,
          vertical: AppSizes.spacing36,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSizes.maxDashboardWidth,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.spacing32),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(AppSizes.radiusXXLarge),
                  border: Border.all(color: AppColors.white(0.06)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.vibrantPurple.withValues(alpha: 0.1),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        size: 40,
                        color: AppColors.vibrantPurple,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing20),
                    Text(
                      t.expensesEmptyTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing12),
                    Text(
                      t.expensesEmptyDescription,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing28),
                    GradientButton(
                      label: t.createExpenseButton,
                      icon: Icons.add_rounded,
                      onPressed: onCreateExpense,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spacing24),
              _QuickTipsCard(t: t),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpensesSummaryCard extends StatelessWidget {
  const _ExpensesSummaryCard({required this.summary, required this.t});

  final TransactionSummary summary;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.vibrantPurple.withValues(alpha: 0.3),
            AppColors.primaryBlue.withValues(alpha: 0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXXLarge),
        border: Border.all(color: AppColors.white(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.expensesSummaryTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Wrap(
            spacing: AppSizes.spacing16,
            runSpacing: AppSizes.spacing16,
            children: [
              _SummaryChip(
                label: t.totalTransactionsLabel,
                value: summary.count.toString(),
              ),
              _SummaryChip(
                label: t.totalExpenseLabel,
                value: '-${summary.totalExpense.toStringAsFixed(2)}',
              ),
              _SummaryChip(
                label: t.totalIncomeLabel,
                value: '+${summary.totalIncome.toStringAsFixed(2)}',
              ),
              _SummaryChip(
                label: t.balanceLabel,
                value: summary.balance.toStringAsFixed(2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing14,
        vertical: AppSizes.spacing10,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.white(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.t,
    required this.ref,
  });

  final MoneyTx transaction;
  final AppLocalizations t;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat.yMMMEd();
    final amountPrefix = transaction.isIncome ? '+' : '-';

    return Dismissible(
      key: ValueKey(transaction.id),
      background: Container(
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing24),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final confirm = await showDialog<bool>(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                title: Text(t.deleteExpenseTitle),
                content: Text(t.deleteExpenseConfirmation),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(t.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: Text(t.delete),
                  ),
                ],
              ),
        );
        return confirm ?? false;
      },
      onDismissed: (_) async {
        final user = ref.read(currentAuthUserProvider);
        if (user != null) {
          await ref
              .read(deleteTransactionUseCaseProvider)
              .call(user.uid, transaction.id);
        }
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacing24,
          vertical: AppSizes.spacing12,
        ),
        title: Text(
          transaction.description,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${transaction.category} • ${formatter.format(transaction.date)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Text(
          '$amountPrefix${transaction.amount.toStringAsFixed(2)} ${transaction.currency.name}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: transaction.isIncome ? Colors.greenAccent : Colors.redAccent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _QuickTipsCard extends StatelessWidget {
  const _QuickTipsCard({required this.t});

  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing24),
      decoration: BoxDecoration(
        color: AppColors.glassBackground.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSizes.radiusXXLarge),
        border: Border.all(color: AppColors.white(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.expensesTipsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.spacing12),
          Text(
            '• ${t.expensesTipCategorize}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSizes.spacing6),
          Text('• ${t.expensesTipReview}', style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSizes.spacing6),
          Text('• ${t.expensesTipReceipts}', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

Future<void> _showAddExpenseSheet(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations t,
) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final user = ref.read(currentAuthUserProvider);
  if (user == null) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(t.noSignedInUser),
        backgroundColor: Colors.red.shade900,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    return;
  }

  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final amountController = TextEditingController();
  Currency selectedCurrency = Currency.USD;
  DateTime selectedDate = DateTime.now();

  final formKey = GlobalKey<FormState>();

  bool isSubmitting = false;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom:
                  MediaQuery.of(sheetContext).viewInsets.bottom +
                  AppSizes.spacing24,
              left: AppSizes.spacing24,
              right: AppSizes.spacing24,
              top: AppSizes.spacing24,
            ),
            child: Material(
              borderRadius: BorderRadius.circular(AppSizes.radiusXXLarge),
              color: AppColors.cardBackground.withValues(alpha: 0.95),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        t.createExpenseButton,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing16),
                      TextFormField(
                        controller: descriptionController,
                        enabled: !isSubmitting,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: t.expenseDescriptionLabel,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return t.fieldRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.spacing12),
                      TextFormField(
                        controller: categoryController,
                        enabled: !isSubmitting,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: t.expenseCategoryLabel,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing12),
                      TextFormField(
                        controller: amountController,
                        enabled: !isSubmitting,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: t.expenseAmountLabel,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return t.fieldRequired;
                          }
                          final parsed = double.tryParse(
                            value.replaceAll(',', '.'),
                          );
                          if (parsed == null || parsed <= 0) {
                            return t.invalidNumber;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.spacing12),
                      DropdownButtonFormField<Currency>(
                        value: selectedCurrency,
                        items:
                            Currency.values
                                .map(
                                  (currency) => DropdownMenuItem(
                                    value: currency,
                                    child: Text(currency.name),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            isSubmitting
                                ? null
                                : (value) {
                                  if (value != null) {
                                    setModalState(
                                      () => selectedCurrency = value,
                                    );
                                  }
                                },
                        decoration: InputDecoration(
                          labelText: t.workspaceCurrencyLabel,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(t.expenseDateLabel),
                        subtitle: Text(
                          DateFormat.yMMMMd().format(selectedDate),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.calendar_today_rounded),
                          onPressed:
                              isSubmitting
                                  ? null
                                  : () async {
                                    final picked = await showDatePicker(
                                      context: sheetContext,
                                      initialDate: selectedDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now().add(
                                        const Duration(days: 365),
                                      ),
                                    );
                                    if (picked != null) {
                                      setModalState(
                                        () => selectedDate = picked,
                                      );
                                    }
                                  },
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing24),
                      GradientButton(
                        label: t.expensesSaveAction,
                        isLoading: isSubmitting,
                        onPressed: () async {
                          if (isSubmitting) return;
                          if (!formKey.currentState!.validate()) {
                            await HapticFeedbackHelper.error();
                            return;
                          }

                          FocusScope.of(sheetContext).unfocus();
                          setModalState(() => isSubmitting = true);

                          final amount = double.parse(
                            amountController.text.replaceAll(',', '.'),
                          );

                          final tx = MoneyTx(
                            id: _generateTransactionId(),
                            date: selectedDate,
                            description: descriptionController.text.trim(),
                            category:
                                categoryController.text.trim().isEmpty
                                    ? t.expenseDefaultCategory
                                    : categoryController.text.trim(),
                            amount: amount,
                            currency: selectedCurrency,
                            isIncome: false,
                          );

                          try {
                            await ref
                                .read(addTransactionUseCaseProvider)
                                .call(user.uid, tx);
                            ref.invalidate(userTransactionsProvider);
                            await HapticFeedbackHelper.success();
                            if (!sheetContext.mounted) {
                              return;
                            }
                            if (Navigator.of(sheetContext).canPop()) {
                              Navigator.of(sheetContext).pop();
                            }
                            if (!context.mounted) return;
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(t.expenseCreatedMessage),
                                backgroundColor: AppColors.vibrantPurple,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          } catch (error) {
                            await HapticFeedbackHelper.error();
                            final message =
                                error is FirebaseException &&
                                        error.message != null
                                    ? error.message!
                                    : t.expenseCreationFailed;
                            if (context.mounted) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                  backgroundColor: Colors.red.shade900,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          } finally {
                            if (sheetContext.mounted) {
                              setModalState(() => isSubmitting = false);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );

  descriptionController.dispose();
  categoryController.dispose();
  amountController.dispose();
  descriptionController.dispose();
  categoryController.dispose();
  amountController.dispose();
}

String _generateTransactionId() {
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  final randomSuffix = Random().nextInt(1 << 20);
  return '$timestamp-$randomSuffix';
}
