# 🚀 Platform Improvement Roadmap for Money Tracker

## Executive Summary

This document outlines strategic improvements to transform your Money Tracker from a basic authentication app into a production-ready personal finance platform.

## Current State Assessment

### ✅ Strengths

- Clean architecture foundation established
- Riverpod already in dependencies (v3.0.3)
- Domain models defined with Freezed (MoneyTx, Profile)
- Firebase Auth + Firestore configured
- Internationalization (English + Ukrainian)
- Proper routing with go_router

### ⚠️ Gaps Identified

- **No state management implemented** (Riverpod unused)
- **No actual money tracking features** (all TODOs)
- Business logic mixed with UI widgets
- Direct Firebase calls in presentation layer
- Missing core workflows (add expense, view history, budgeting)
- No data persistence layer for transactions
- Missing analytics and insights

---

## 🎯 Phase 1: Harden Authentication & Onboarding (Priority: HIGH)

**Timeline: 1-2 weeks**

### Why This Matters

Google and Apple sign-in are now the only entry points. We need to guarantee the configuration is fool-proof, add automated coverage, and surface helpful diagnostics when providers fail or are unavailable.

### Actions Required

#### 1.1 Stabilise Auth Providers

- Keep the lightweight repository/use-case stack already in `lib/features/auth/presentation/providers/auth_providers.dart`.
- Introduce a small controller to expose button state and error handling around the social flows:

```dart
final socialAuthControllerProvider =
    StateNotifierProvider<SocialAuthController, AsyncValue<void>>((ref) {
  return SocialAuthController(
    signInWithGoogle: ref.watch(signInWithGoogleProvider),
    signInWithApple: ref.watch(signInWithAppleProvider),
  );
});
```

```dart
class SocialAuthController extends StateNotifier<AsyncValue<void>> {
  SocialAuthController({
    required this.signInWithGoogle,
    required this.signInWithApple,
  }) : super(const AsyncValue.data(null));

  final SignInWithGoogle signInWithGoogle;
  final SignInWithApple signInWithApple;

  Future<void> signIn(Future<AuthUser?> Function() action) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(action);
  }
}
```

Use this notifier from the login screen so UI reacts consistently to cancellation, network errors, or unsupported providers.

#### 1.2 Configuration Checklist

- Follow the updated README to register Google OAuth client IDs and enable the Sign in with Apple entitlement.
- Add runtime guards that surface `SignInWithAppleNotSupportedException` and clear copy for missing Google configuration.
- Verify an on-device login for each provider (simulator + physical device).

#### 1.3 Automation

- Add integration tests that stub Firebase Auth and Google/Apple plugins to exercise success, cancellation, and error paths.
- Record golden tests for the new login UI to catch regressions in loading/disabled states.
- Capture analytics (or simple logging) for auth errors to aid future diagnostics.

---

## 💰 Phase 2: Implement Core Money Tracking Features (Priority: HIGH)

**Timeline: 2-3 weeks**

### 2.1 Transaction Management

**Create Transaction Repository:**

```dart
// lib/features/money/data/transaction_repository.dart
class FirestoreTransactionRepository {
  final FirebaseFirestore _firestore;

  Stream<List<MoneyTx>> watchUserTransactions(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MoneyTx.fromJson(doc.data()))
            .toList());
  }

  Future<void> addTransaction(String userId, MoneyTx transaction) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toJson());
  }
}
```

**Create Providers:**

```dart
// lib/features/money/providers/transaction_providers.dart
final transactionRepositoryProvider = Provider((ref) =>
  FirestoreTransactionRepository()
);

final userTransactionsProvider = StreamProvider<List<MoneyTx>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  return ref
      .watch(transactionRepositoryProvider)
      .watchUserTransactions(user.uid);
});

final transactionStatsProvider = Provider<TransactionStats>((ref) {
  final transactions = ref.watch(userTransactionsProvider).value ?? [];

  return TransactionStats.calculate(transactions);
});
```

### 2.2 Build Add Transaction Screen

```dart
// lib/features/expenses/presentation/add_transaction_screen.dart
class AddTransactionScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(t.addTransaction)),
      body: Form(
        child: Column(
          children: [
            TextFormField(/* Amount */),
            TextFormField(/* Description */),
            CategoryPicker(),
            CurrencyPicker(),
            IncomeExpenseToggle(),
            DatePicker(),
            GradientButton(
              label: t.save,
              onPressed: () => ref
                  .read(transactionControllerProvider.notifier)
                  .addTransaction(/* data */),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2.3 Build Dashboard with Real Data

```dart
// lib/features/dashboard/presentation/dashboard_tab.dart
class DashboardTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(userTransactionsProvider);
    final stats = ref.watch(transactionStatsProvider);

    return transactions.when(
      data: (txList) => txList.isEmpty
          ? EmptyDashboardView()
          : DashboardContent(
              stats: stats,
              recentTransactions: txList.take(10).toList(),
            ),
      loading: () => LoadingIndicator(),
      error: (error, stack) => ErrorView(error),
    );
  }
}
```

### Benefits

- ✅ Real money tracking functionality
- ✅ Persistent data in Firestore
- ✅ Real-time updates across devices
- ✅ Foundation for budgeting features

---

## 📊 Phase 3: Add Analytics & Insights (Priority: MEDIUM)

**Timeline: 2 weeks**

### 3.1 Create Analytics Engine

```dart
// lib/features/dashboard/domain/analytics_engine.dart
class AnalyticsEngine {
  static MonthlyAnalytics calculateMonthly(List<MoneyTx> transactions) {
    final now = DateTime.now();
    final thisMonth = transactions.where((tx) =>
        tx.date.year == now.year && tx.date.month == now.month);

    return MonthlyAnalytics(
      totalIncome: _sumIncome(thisMonth),
      totalExpense: _sumExpense(thisMonth),
      topCategories: _groupByCategory(thisMonth),
      dailyAverage: _calculateDailyAverage(thisMonth),
      comparedToLastMonth: _compareMonths(transactions, now),
    );
  }

  static Map<String, CategoryInsight> analyzeSpendingPatterns(
    List<MoneyTx> transactions,
  ) {
    // Identify spending patterns, anomalies, trends
  }
}
```

### 3.2 Build Insights Widgets

**Monthly Summary Card:**

```dart
class MonthlySummaryCard extends StatelessWidget {
  final MonthlyAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Text('This Month', style: headlineStyle),
          Row(
            children: [
              _StatColumn(
                label: 'Income',
                value: analytics.totalIncome,
                color: Colors.green,
              ),
              _StatColumn(
                label: 'Expenses',
                value: analytics.totalExpense,
                color: Colors.red,
              ),
              _StatColumn(
                label: 'Net',
                value: analytics.net,
                color: analytics.net >= 0 ? Colors.green : Colors.red,
              ),
            ],
          ),
          if (analytics.comparedToLastMonth != 0)
            _ComparisonIndicator(analytics.comparedToLastMonth),
        ],
      ),
    );
  }
}
```

**Category Breakdown Chart:**

```dart
class CategoryChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Text('Spending by Category'),
          PieChart(/* Use fl_chart or charts_flutter */),
          CategoryLegend(),
        ],
      ),
    );
  }
}
```

**Spending Trends:**

```dart
class SpendingTrendsChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Text('Last 6 Months'),
          LineChart(/* Monthly spending trend */),
          _InsightCards(/* AI-like insights */),
        ],
      ),
    );
  }
}
```

### Benefits

- ✅ Users understand their spending
- ✅ Visual insights increase engagement
- ✅ Identify saving opportunities
- ✅ Competitive advantage

---

## 🎨 Phase 4: Enhanced UX & Workflows (Priority: MEDIUM)

**Timeline: 1-2 weeks**

### 4.1 Quick Add FAB (Floating Action Button)

```dart
// On every main screen
FloatingActionButton.extended(
  onPressed: () => showModalBottomSheet(
    context: context,
    builder: (_) => QuickAddTransactionSheet(),
  ),
  icon: Icon(Icons.add),
  label: Text('Add Expense'),
)
```

### 4.2 Swipe Actions for Transactions

```dart
Dismissible(
  key: Key(transaction.id),
  background: Container(color: Colors.red), // Delete
  secondaryBackground: Container(color: Colors.blue), // Edit
  onDismissed: (direction) {
    if (direction == DismissDirection.endToStart) {
      // Delete
      ref.read(transactionControllerProvider.notifier)
          .deleteTransaction(transaction.id);
    } else {
      // Edit
      Navigator.push(/* Edit screen */);
    }
  },
  child: TransactionTile(transaction),
)
```

### 4.3 Smart Search & Filters

```dart
// lib/features/history/presentation/history_tab.dart
class HistoryTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredTransactionsProvider);

    return Column(
      children: [
        SearchBar(
          onChanged: (query) => ref
              .read(searchQueryProvider.notifier)
              .state = query,
        ),
        FilterChips(
          categories: ref.watch(categoriesProvider),
          dateRange: ref.watch(dateRangeProvider),
        ),
        Expanded(
          child: TransactionList(transactions),
        ),
      ],
    );
  }
}
```

### 4.4 Recurring Transactions

```dart
// lib/features/money/domain/recurring_transaction.dart
@freezed
class RecurringTransaction with _$RecurringTransaction {
  const factory RecurringTransaction({
    required String id,
    required MoneyTx template,
    required RecurrenceRule rule, // daily, weekly, monthly, custom
    required DateTime startDate,
    DateTime? endDate,
    required bool isActive,
  }) = _RecurringTransaction;
}

// Background job to create transactions
class RecurringTransactionScheduler {
  Future<void> processRecurring() async {
    // Check for due recurring transactions
    // Create actual transactions from templates
  }
}
```

### Benefits

- ✅ Faster data entry
- ✅ Better user experience
- ✅ Power user features
- ✅ Reduced friction

---

## 🔐 Phase 5: Advanced Features (Priority: LOW)

**Timeline: 3-4 weeks**

### 5.1 Budgeting System

```dart
// lib/features/budget/domain/budget.dart
@freezed
class Budget with _$Budget {
  const factory Budget({
    required String id,
    required String category,
    required double limit,
    required BudgetPeriod period, // weekly, monthly, yearly
    DateTime? startDate,
    DateTime? endDate,
  }) = _Budget;
}

// Budget tracking provider
final budgetProgressProvider = Provider.family<BudgetProgress, String>(
  (ref, budgetId) {
    final budget = ref.watch(budgetProvider(budgetId));
    final transactions = ref.watch(categoryTransactionsProvider(budget.category));

    return BudgetProgress.calculate(budget, transactions);
  },
);
```

### 5.2 Multi-Currency Support

```dart
// lib/core/services/currency_service.dart
class CurrencyService {
  Future<Map<String, double>> fetchExchangeRates() async {
    // Call exchangerate-api.com or similar
  }

  double convert(double amount, Currency from, Currency to) {
    // Use cached rates with automatic refresh
  }
}

// Update Profile to include preferred currency
@freezed
class Profile with _$Profile {
  const factory Profile({
    @Default(Currency.usd) Currency preferredCurrency,
    @Default(5000) double goalUsd,
    @Default({}) Map<String, double> exchangeRates,
  }) = _Profile;
}
```

### 5.3 Data Export & Backup

```dart
// lib/features/settings/application/export_controller.dart
class ExportController {
  Future<File> exportToCSV(List<MoneyTx> transactions) async {
    // Generate CSV file
  }

  Future<void> backupToCloudStorage() async {
    // Backup to Google Drive or similar
  }

  Future<void> restoreFromBackup(File backupFile) async {
    // Restore user data
  }
}
```

### 5.4 Notifications & Reminders

```dart
// lib/core/services/notification_service.dart
class NotificationService {
  Future<void> scheduleRecurringReminder() async {
    // Remind to log expenses
  }

  Future<void> sendBudgetAlert(Budget budget) async {
    // Alert when approaching budget limit
  }

  Future<void> sendMonthlyReport() async {
    // Monthly spending summary
  }
}
```

---

## 🧪 Phase 6: Testing & Quality Assurance (Priority: HIGH)

**Timeline: Ongoing**

### 6.1 Unit Tests

```dart
// test/features/money/domain/analytics_engine_test.dart
void main() {
  group('AnalyticsEngine', () {
    test('calculates monthly totals correctly', () {
      final transactions = [
        MoneyTx(amount: 100, isIncome: true, /* ... */),
        MoneyTx(amount: 50, isIncome: false, /* ... */),
      ];

      final analytics = AnalyticsEngine.calculateMonthly(transactions);

      expect(analytics.totalIncome, 100);
      expect(analytics.totalExpense, 50);
      expect(analytics.net, 50);
    });
  });
}
```

### 6.2 Widget Tests

```dart
// test/ui/widgets/gradient_button_test.dart
void main() {
  testWidgets('GradientButton shows loading state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GradientButton(
          label: 'Test',
          isLoading: true,
          onPressed: () {},
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Test'), findsNothing);
  });
}
```

### 6.3 Integration Tests

```dart
// integration_test/auth_flow_test.dart
void main() {
  testWidgets('Google sign-in routes to dashboard', (tester) async {
    final fakeAuth = FakeAuthRepository();
    await tester.pumpWidget(
      IntegrationHarness(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuth),
        ],
      ),
    );

    await tester.tap(find.text('Continue with Google'));
    await tester.pump(); // start loading

    expect(fakeAuth.googleSignInCount, 1);

    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
```

---

## 📈 Success Metrics

### Key Performance Indicators (KPIs)

1. **Development Velocity**

   - Time to add new features (should decrease)
   - Bug fix time (should decrease)
   - Code review time (should decrease)

2. **Code Quality**

   - Test coverage > 80%
   - Zero critical bugs in production
   - Performance: App start < 2s
   - Memory usage < 100MB

3. **User Engagement** (future)
   - Daily active users (DAU)
   - Average transactions per user per week
   - Feature adoption rate
   - User retention rate

---

## 🛠️ Technical Debt to Address

### Immediate (Do While Building Phase 1-2)

1. **Migrate all screens to use new repository pattern**

   - Replace `AuthService` with `FirebaseAuthRepository` everywhere
   - Remove `BuildContext` from repository methods

2. **Update all widgets to use constants**

   - Replace magic numbers with `AppSizes`
   - Replace hardcoded colors with `AppColors`

3. **Use routing constants everywhere**
   - Replace string literals with `AppRoutes`

### Medium-term (Phase 3-4)

1. **Add error tracking** (Sentry/Firebase Crashlytics)
2. **Implement analytics** (Firebase Analytics/Mixpanel)
3. **Add feature flags** for A/B testing
4. **Optimize Firestore queries** (indexing, pagination)

### Long-term (Phase 5-6)

1. **Consider offline-first architecture**
2. **Add end-to-end encryption** for sensitive data
3. **Implement data synchronization conflict resolution**
4. **Add AI-powered spending insights**

---

## 💡 Quick Wins (Do These First!)

### Week 1 Priorities

1. **Wrap app with ProviderScope**

```dart
// lib/main.dart
runApp(
  ProviderScope(
    child: MoneyApp(),
  ),
);
```

2. **Create basic providers**

   - Auth state provider
   - Current user provider

3. **Refactor Login Screen**

   - Use Riverpod
   - Remove business logic from widget

4. **Add Floating Action Button to Dashboard**

   - Quick way to add transactions
   - Good UX improvement

5. **Create Transaction List Widget**
   - Display recent transactions
   - Shows app is functional

### Estimated Impact

- **Development Speed**: +30%
- **Code Quality**: +50%
- **User Experience**: +40%
- **Maintainability**: +60%

---

## 🎓 Learning Resources

### Riverpod

- Official Docs: https://riverpod.dev
- Video Tutorial: ResoCoder's Riverpod series
- Example App: https://github.com/rrousselGit/river_pod/tree/master/examples

### Firebase

- Firestore Best Practices: https://firebase.google.com/docs/firestore/best-practices
- Security Rules: https://firebase.google.com/docs/rules

### Testing

- Flutter Testing Guide: https://docs.flutter.dev/testing
- Test-Driven Development: https://resocoder.com/flutter-tdd-clean-architecture-course/

---

## 📋 Implementation Checklist

### Phase 1: Social Auth Hardening

- [ ] Add a `SocialAuthController` that wraps Google/Apple sign-in use cases
- [ ] Update `LoginScreen` to consume the controller state for loading/error UI
- [ ] Document Google/Apple configuration (client IDs, entitlements) in README
- [ ] Add integration test covering Google sign-in success/cancel flows
- [ ] Mock Apple sign-in for devices that do not support the capability
- [ ] Capture analytics/logging for sign-in errors

### Phase 2: Core Features

- [ ] Create transaction repository
- [ ] Create transaction providers
- [ ] Build add transaction screen
- [ ] Build transaction list widget
- [ ] Update dashboard with real data
- [ ] Add delete transaction functionality
- [ ] Add edit transaction functionality
- [ ] Test transaction CRUD operations

### Phase 3: Analytics

- [ ] Create analytics engine
- [ ] Add monthly summary widget
- [ ] Add category breakdown chart
- [ ] Add spending trends chart
- [ ] Create insights algorithm
- [ ] Test analytics calculations

### Phase 4: UX Enhancement

- [ ] Add FAB for quick add
- [ ] Implement swipe actions
- [ ] Add search functionality
- [ ] Add category filters
- [ ] Add date range filters
- [ ] Implement recurring transactions
- [ ] Add transaction attachments (receipts)

### Phase 5: Advanced Features

- [ ] Build budgeting system
- [ ] Add multi-currency support
- [ ] Implement data export
- [ ] Add cloud backup
- [ ] Create notification system
- [ ] Add spending predictions

### Phase 6: Testing

- [ ] Write unit tests for repositories
- [ ] Write unit tests for controllers
- [ ] Write widget tests for custom widgets
- [ ] Write integration tests for critical flows
- [ ] Set up CI/CD pipeline
- [ ] Achieve 80%+ code coverage

---

## 🚀 Getting Started

**Next immediate steps:**

1. Review this document with your team
2. Prioritize phases based on your goals
3. Start with Phase 1 (State Management) - foundation for everything else
4. Set up weekly checkpoints to track progress
5. Celebrate small wins!

Remember: **Perfect is the enemy of good.** Start with basic implementations and iterate based on user feedback.

---

## Questions to Consider

1. **Target Audience**: Who is this app for? (Personal use, family, small business?)
2. **Monetization**: Free, freemium, subscription?
3. **Platform Priority**: iOS, Android, or both equally?
4. **Timeline**: MVP in 1 month, 3 months, 6 months?
5. **Team Size**: Solo developer or team?

---

**Last Updated**: October 21, 2025  
**Status**: Ready for Implementation  
**Priority**: Start with Phase 1 immediately

Good luck! 🎉
