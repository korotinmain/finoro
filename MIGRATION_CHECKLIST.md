# ✅ Migration Checklist

## Immediate Actions (To Make Code Work)

### 1. Update Existing Screens to Use New Components

#### Login Screen (`lib/screens/login_screen.dart`)

- [ ] Replace validation methods with `FormValidators`
- [ ] Replace `AuthService` with `FirebaseAuthRepository`
- [ ] Use `AppRoutes` constants instead of hardcoded strings
- [ ] Replace button with `GradientButton`

#### Register Screen (`lib/screens/register_screen.dart`)

- [ ] Replace validation methods with `FormValidators`
- [ ] Use `PasswordStrength.calculate()` instead of inline logic
- [ ] Replace `AuthService` with `FirebaseAuthRepository`
- [ ] Use `AppRoutes` constants
- [ ] Replace button with `GradientButton`

#### Forgot Password Screen

- [ ] Replace validation with `FormValidators`
- [ ] Replace `AuthService` with `FirebaseAuthRepository`
- [ ] Use `AppRoutes` constants

#### Email Confirmation Screen

- [ ] Replace `AuthService` with `FirebaseAuthRepository`
- [ ] Use `AppRoutes` constants

### 2. Update Router (`lib/router.dart`)

**Option A: Keep Both (Recommended for now)**

- [ ] Keep old `router.dart` as `router_old.dart`
- [ ] Use new `createAppRouter()` from `core/routing/app_router.dart`
- [ ] Update main.dart (already done ✅)

**Option B: Delete Old Router**

- [ ] Delete `lib/router.dart`
- [ ] Verify all screens work with new router

### 3. Update App Shell (`lib/screens/app_shell.dart`)

- [ ] Import `AppRoutes` instead of hardcoded strings
- [ ] Use new route constants

### 4. Clean Up Old Files (Optional)

- [ ] Remove `lib/services/auth_service.dart` (replaced by repository)
- [ ] Remove `lib/services/app_launch_service.dart` (moved to core)
- [ ] Archive old `tabs.dart` as `tabs_old.dart`

## Testing Checklist

### Authentication Flow

- [ ] Can launch app
- [ ] Can view login screen
- [ ] Can log in successfully
- [ ] Can register new account
- [ ] Can request password reset
- [ ] Email verification works
- [ ] Can log out

### Navigation

- [ ] Dashboard tab loads
- [ ] Expenses tab loads
- [ ] History tab loads
- [ ] Settings tab loads
- [ ] Account settings page works
- [ ] Tab switching works smoothly

### UI Components

- [ ] All buttons render correctly
- [ ] Colors are consistent
- [ ] Spacing looks correct
- [ ] Glass cards render properly
- [ ] Glow blobs appear as expected

## Long-term Improvements (Optional)

### Phase 1: Complete Migration

- [ ] Migrate all auth screens to use new architecture
- [ ] Remove all hardcoded colors (replace with `AppColors`)
- [ ] Remove all magic numbers (replace with `AppSizes`)
- [ ] Update all buttons to use `GradientButton`

### Phase 2: Add Testing

- [ ] Unit tests for `FormValidators`
- [ ] Unit tests for `PasswordStrength`
- [ ] Unit tests for `FirebaseAuthRepository` (with mocks)
- [ ] Widget tests for reusable components
- [ ] Integration tests for auth flows

### Phase 3: State Management

- [ ] Add Riverpod/Bloc/Provider
- [ ] Create view models/controllers
- [ ] Move business logic out of widgets

### Phase 4: Complete Clean Architecture

- [ ] Add domain layer to features
- [ ] Create use cases
- [ ] Add data sources
- [ ] Implement repository pattern for all features

### Phase 5: Dependency Injection

- [ ] Set up get_it or Riverpod DI
- [ ] Remove direct service instantiation
- [ ] Make all dependencies injectable

## Quick Wins (Easy, High Impact)

### 1. Replace Magic Numbers (30 minutes)

Find all instances of hardcoded numbers and replace with constants:

```bash
# Search for common patterns
grep -r "const SizedBox(height: [0-9]" lib/screens/
grep -r "BorderRadius.circular([0-9]" lib/screens/
```

### 2. Use New Buttons (15 minutes)

Replace all custom gradient button implementations with `GradientButton`

### 3. Consolidate Colors (20 minutes)

Replace all `Color(0xFF...)` with `AppColors.*` constants

### 4. Use Route Constants (10 minutes)

Replace all `'/dashboard'` with `AppRoutes.dashboard`

## Potential Issues & Solutions

### Issue: Import Errors

**Solution:** Update imports in files that use the new components

```dart
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';
import 'package:money_tracker/core/routing/app_routes.dart';
import 'package:money_tracker/ui/widgets/gradient_button.dart';
```

### Issue: Type Mismatch

**Solution:** Ensure you're using the right repository interface

```dart
// Old
final _authService = AuthService();

// New
final _authRepo = FirebaseAuthRepository();
```

### Issue: Route Not Found

**Solution:** Ensure all routes are defined in `createAppRouter()`

### Issue: Validation Not Working

**Solution:** Pass `AppLocalizations` to validators

```dart
validator: (v) => FormValidators.validateEmail(v,
  AppLocalizations.of(context)!,
),
```

## Documentation

### Code Examples

- [x] Created `REFACTORING.md` with detailed examples
- [x] Created `REFACTORING_SUMMARY.md` with overview
- [x] Created `VISUAL_GUIDE.md` with before/after comparisons

### Comments

- [ ] Add inline comments to complex logic
- [ ] Document public APIs
- [ ] Add dartdoc comments to public classes/methods

## Metrics to Track

### Before/After Comparison

- [ ] Measure build time
- [ ] Count lines of code
- [ ] Count duplicate code blocks
- [ ] Track number of lint warnings

### Code Quality

- [ ] Run `flutter analyze` (should have fewer issues)
- [ ] Check cyclomatic complexity
- [ ] Review code duplication percentage

## Team Onboarding

If working with a team:

- [ ] Share refactoring documentation
- [ ] Walk through new architecture
- [ ] Establish coding guidelines
- [ ] Set up code review process

## Rollback Plan

If something breaks:

1. Revert `main.dart` to use old `router.dart`
2. Keep using old screen implementations
3. New files can coexist with old ones safely
4. Nothing is destructive until you delete old files

## Success Criteria

✅ **Refactoring is successful when:**

- App builds without errors
- All authentication flows work
- All navigation works correctly
- UI looks identical to before
- Code is more maintainable
- Team can find code faster

## Notes

- The old and new code can coexist
- Migrate screens one at a time
- Test each change before moving to the next
- Don't delete old code until new code is verified

## Questions?

Review the documentation:

1. `REFACTORING.md` - Detailed technical documentation
2. `REFACTORING_SUMMARY.md` - High-level overview
3. `VISUAL_GUIDE.md` - Visual before/after comparisons
4. This checklist - Step-by-step migration guide

## Timeline Estimate

- **Minimal viable migration:** 2-4 hours
  - Update router ✅ (done)
  - Update one or two screens
  - Test authentication
- **Complete migration:** 1-2 days
  - All screens updated
  - All constants replaced
  - All components refactored
  - Full testing
- **Full clean architecture:** 1-2 weeks
  - State management added
  - Complete testing suite
  - Full feature isolation
  - Documentation complete
