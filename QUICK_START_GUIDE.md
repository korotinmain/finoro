# 🎯 Quick Start: Top 3 Improvements to Implement Today

## Overview

This guide highlights the **three highest-impact improvements** you can tackle right away. Each item keeps momentum on the new feature-first architecture and strengthens the social sign-in experience we just landed.

> **📱 iOS Focus:** Finoro targets iOS first. See [IOS_DEVELOPMENT.md](IOS_DEVELOPMENT.md) for platform nuances (entitlements, testing on real devices, etc.).

---

## 1️⃣ Lock Down Social Sign-In (≈2 hours)

### Why This First?

Google and Apple sign-in are now the only ways in. Ensuring the configuration, controller layer, and tests are air-tight prevents regressions and makes onboarding smooth for every build.

### Step-by-Step Implementation

#### Step 1: Finalise Provider Configuration (20 minutes)

- Follow the updated instructions in `README.md` to register Google OAuth client IDs and enable the Sign in with Apple capability.
- Add the reversed client ID to `ios/Runner/Info.plist` and enable the entitlement in Xcode.
- Confirm both providers are enabled in Firebase Auth before cutting a release build.

#### Step 2: Add a Social Auth Controller (40 minutes)

**File: `lib/features/auth/presentation/providers/auth_providers.dart`**

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

  Future<void> signInWith(Future<AuthUser?> Function() flow) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(flow);
  }
}
```

Consume the controller from `LoginScreen` so the buttons expose loading/error states in a single place and become trivial to test.

#### Step 3: Integration Smoke Test (30 minutes)

- Create an `integration_test/auth_flow_test.dart` that overrides `authRepositoryProvider` with a `FakeAuthRepository`.
- Simulate tapping “Continue with Google”, assert the fake repository was called, and verify navigation to the dashboard after `pumpAndSettle`.
- Repeat for the Apple button, covering the unsupported-device case by throwing `SignInWithAppleNotSupportedException`.

### Wins

✅ Reliable onboarding experience  
✅ Centralised error handling for Google/Apple flows  
✅ Test coverage for the most critical funnel  
✅ Clear diagnostics when configuration is wrong

---

## 2️⃣ Connect Dashboard to Live Data (≈2.5 hours)

### Why This Second?

The new feature-first modules already expose Riverpod providers; wiring them to Firestore completes the loop so projects, expenses, and history react instantly to changes.

### Step-by-Step Implementation

#### Step 1: Ensure Repository Streams (45 minutes)

- Verify `DashboardRepository.watchProjects` (or equivalent) streams project summaries for the signed-in user.
- Mirror similar streams for expenses/history if they aren’t already in place.

#### Step 2: Display Async UI States (45 minutes)

**File: `lib/features/dashboard/presentation/dashboard_tab.dart`**

```dart
final dashboardAsync = ref.watch(dashboardOverviewProvider);
return dashboardAsync.when(
  data: (overview) => DashboardBody(overview: overview),
  loading: () => const _DashboardLoading(),
  error: (err, stack) => _DashboardError(message: err.toString()),
);
```

- Apply the same pattern to expenses/history tabs so loading and error cards stay consistent across the app.

#### Step 3: Polish Empty States (30 minutes)

- Review strings like `noProjectsYet`, `expensesEmptyTitle`, etc. to make sure they set expectations immediately after social sign-in.
- Add CTA buttons that deep-link to the project creation flow and expense creation dialog.

### Wins

✅ Real-time dashboard across all tabs  
✅ Shared async handling pattern (data/loading/error)  
✅ Better first-run experience after signing in  
✅ Stronger foundation for analytics and budgeting

---

## 3️⃣ Expand Coverage for Money Flows (≈2 hours)

### Why This Third?

With auth and live data secured, add targeted tests around project creation, expenses, and history to keep the new architecture safe during future refactors.

### Step-by-Step Implementation

#### Step 1: Project Creation Tests (45 minutes)

- Unit-test `CreateProjectInput` validation (budget > 0, currency present, name trimmed).
- Mock `DashboardRepository` to verify the `CreateProject` use case bubbles up both success and failure cases.

#### Step 2: Expense CRUD Smoke (45 minutes)

- Add widget tests for `ExpensesTab` covering empty, loading, and populated list states using fake providers.
- Exercise add/delete expense use cases with an in-memory repository to guarantee data integrity.

#### Step 3: History Snapshot (20 minutes)

- Seed sample data for history charts and capture a golden/snapshot test so visual regressions are caught early.

### Wins

✅ Confidence in the core money flows  
✅ Safety net for future UI/state refactors  
✅ Faster debugging when Firestore data changes  
✅ Concrete examples for new contributors

---

## Next Moves

- Ship the integration tests to CI (GitHub Actions or Codemagic).
- Pair with design to refresh empty-state illustrations for the new onboarding.
- Start planning webhook/notification support once auth telemetry is stable.

