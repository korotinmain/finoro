# 🚀 Finoro Implementation Guide

**Transforming Money Tracker into Finoro: A Project-Based Personal Finance App**

---

## 📋 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Data Models](#data-models)
3. [Phase 1: Project Foundation](#phase-1-project-foundation)
4. [Phase 2: Budget & Transactions](#phase-2-budget--transactions)
5. [Phase 3: Insights & Analytics](#phase-3-insights--analytics)
6. [Phase 4: Polish & Advanced Features](#phase-4-polish--advanced-features)
7. [UI Components](#ui-components)
8. [Implementation Checklist](#implementation-checklist)

---

## 🏗️ Architecture Overview

### Core Concept: Projects as Financial Containers

```
User
 └─> Projects (multiple)
      ├─> Budgets (per category/total)
      ├─> Expenses (categorized, timestamped)
      ├─> Incomes (sources, timestamped)
      └─> Insights (calculated from above)
```

### Key Changes from Current Architecture

**Current**: Flat transaction list per user

```
User → Transactions (all mixed together)
```

**Finoro**: Project-based organization

```
User → Projects → Transactions (grouped by project)
            ├─> Budget settings
            └─> Progress tracking
```

---

## 📦 Data Models

### 1. Project Model

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'project.freezed.dart';
part 'project.g.dart';

@freezed
class Project with _$Project {
  const factory Project({
    required String id,
    required String userId,
    required String name,
    required String? description,
    required ProjectType type,
    required String icon,  // emoji or icon name
    required String color, // hex color for visual identity
    required double totalBudget,
    required DateTime createdAt,
    required DateTime? targetDate, // optional goal date
    @Default(false) bool isArchived,
    @Default(true) bool isActive,

    // Calculated fields (not stored, computed)
    @Default(0.0) double totalExpenses,
    @Default(0.0) double totalIncome,
    @Default(0.0) double remainingBudget,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

  // Firestore conversion
  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Project.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json.remove('totalExpenses');
    json.remove('totalIncome');
    json.remove('remainingBudget');
    return json;
  }
}

enum ProjectType {
  @JsonValue('vacation')
  vacation,

  @JsonValue('monthly_budget')
  monthlyBudget,

  @JsonValue('savings')
  savings,

  @JsonValue('side_hustle')
  sideHustle,

  @JsonValue('renovation')
  renovation,

  @JsonValue('custom')
  custom,
}
```

### 2. Budget Model

```dart
@freezed
class Budget with _$Budget {
  const factory Budget({
    required String id,
    required String projectId,
    required String category,
    required double amount,
    required BudgetPeriod period,
    required DateTime startDate,
    DateTime? endDate,
    @Default(0.0) double spent, // calculated
  }) = _Budget;

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);
}

enum BudgetPeriod {
  @JsonValue('one_time')
  oneTime,

  @JsonValue('weekly')
  weekly,

  @JsonValue('monthly')
  monthly,

  @JsonValue('yearly')
  yearly,
}
```

### 3. Updated Transaction Model

```dart
// Extend existing MoneyTx model
@freezed
class MoneyTx with _$MoneyTx {
  const factory MoneyTx({
    required String id,
    required String projectId, // NEW: link to project
    required DateTime date,
    required String description,
    required String category,
    required double amount,
    required Currency currency,
    required bool isIncome,

    // Additional metadata
    String? notes,
    String? receiptUrl,
    @Default([]) List<String> tags,
  }) = _MoneyTx;

  factory MoneyTx.fromJson(Map<String, dynamic> json) => _$MoneyTxFromJson(json);
}
```

### 4. Project Statistics Model

```dart
@freezed
class ProjectStats with _$ProjectStats {
  const factory ProjectStats({
    required String projectId,
    required double totalIncome,
    required double totalExpenses,
    required double balance,
    required double budgetUsedPercentage,
    required Map<String, double> categoryBreakdown,
    required Map<String, double> monthlyTrends,
    required DateTime calculatedAt,
  }) = _ProjectStats;

  factory ProjectStats.fromJson(Map<String, dynamic> json) => _$ProjectStatsFromJson(json);
}
```

---

## 🎯 Phase 1: Project Foundation

### Timeline: Week 1-2 (10-15 hours)

### Step 1.1: Create Project Domain Layer (2 hours)

**File: `lib/features/projects/domain/project.dart`**

- Implement Project model with Freezed
- Add toFirestore/fromFirestore methods
- Generate code: `flutter pub run build_runner build --delete-conflicting-outputs`

**File: `lib/features/projects/domain/project_type.dart`**

- Define project type enum with icons and colors
- Helper methods for getting icon/color by type

```dart
extension ProjectTypeExtension on ProjectType {
  String get displayName {
    switch (this) {
      case ProjectType.vacation:
        return '🏖️ Vacation';
      case ProjectType.monthlyBudget:
        return '📅 Monthly Budget';
      case ProjectType.savings:
        return '💰 Savings';
      case ProjectType.sideHustle:
        return '💼 Side Hustle';
      case ProjectType.renovation:
        return '🏠 Renovation';
      case ProjectType.custom:
        return '✨ Custom';
    }
  }

  String get emoji {
    switch (this) {
      case ProjectType.vacation:
        return '🏖️';
      case ProjectType.monthlyBudget:
        return '📅';
      case ProjectType.savings:
        return '💰';
      case ProjectType.sideHustle:
        return '💼';
      case ProjectType.renovation:
        return '🏠';
      case ProjectType.custom:
        return '✨';
    }
  }

  String get defaultColor {
    switch (this) {
      case ProjectType.vacation:
        return '#4ECDC4'; // Turquoise
      case ProjectType.monthlyBudget:
        return '#9D50F0'; // Purple
      case ProjectType.savings:
        return '#50C878'; // Emerald
      case ProjectType.sideHustle:
        return '#FFB84D'; // Orange
      case ProjectType.renovation:
        return '#E74C3C'; // Red
      case ProjectType.custom:
        return '#95A5A6'; // Gray
    }
  }
}
```

### Step 1.2: Create Project Repository (3 hours)

**File: `lib/features/projects/data/project_repository.dart`**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_tracker/features/projects/domain/project.dart';

abstract class IProjectRepository {
  Stream<List<Project>> watchUserProjects(String userId);
  Future<Project?> getProject(String projectId);
  Future<void> createProject(Project project);
  Future<void> updateProject(Project project);
  Future<void> deleteProject(String projectId);
  Future<void> archiveProject(String projectId);
}

class FirestoreProjectRepository implements IProjectRepository {
  final FirebaseFirestore _firestore;

  FirestoreProjectRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Project>> watchUserProjects(String userId) {
    return _firestore
        .collection('projects')
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Project.fromFirestore(doc))
            .toList());
  }

  @override
  Future<Project?> getProject(String projectId) async {
    final doc = await _firestore.collection('projects').doc(projectId).get();
    return doc.exists ? Project.fromFirestore(doc) : null;
  }

  @override
  Future<void> createProject(Project project) async {
    await _firestore
        .collection('projects')
        .doc(project.id)
        .set(project.toFirestore());
  }

  @override
  Future<void> updateProject(Project project) async {
    await _firestore
        .collection('projects')
        .doc(project.id)
        .update(project.toFirestore());
  }

  @override
  Future<void> deleteProject(String projectId) async {
    // Soft delete - archive instead
    await _firestore
        .collection('projects')
        .doc(projectId)
        .update({'isArchived': true});
  }

  @override
  Future<void> archiveProject(String projectId) async {
    await _firestore
        .collection('projects')
        .doc(projectId)
        .update({'isArchived': true});
  }
}
```

### Step 1.3: Create Riverpod Providers (1 hour)

**File: `lib/features/projects/providers/project_providers.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker/features/projects/data/project_repository.dart';
import 'package:money_tracker/features/projects/domain/project.dart';
import 'package:money_tracker/core/providers/auth_providers.dart';

// Repository provider
final projectRepositoryProvider = Provider<IProjectRepository>((ref) {
  return FirestoreProjectRepository();
});

// Watch user's projects
final userProjectsProvider = StreamProvider<List<Project>>((ref) {
  final userId = ref.watch(currentUserProvider)?.uid;
  if (userId == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchUserProjects(userId);
});

// Get single project
final projectProvider = StreamProvider.family<Project?, String>((ref, projectId) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProject(projectId).asStream();
});

// Active projects count
final activeProjectsCountProvider = Provider<int>((ref) {
  final projectsAsync = ref.watch(userProjectsProvider);
  return projectsAsync.when(
    data: (projects) => projects.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
```

### Step 1.4: Build Projects Dashboard Screen (4-5 hours)

**File: `lib/features/projects/presentation/projects_dashboard_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker/features/projects/providers/project_providers.dart';
import 'package:money_tracker/ui/widgets/project_card.dart';
import 'package:money_tracker/ui/widgets/empty_state.dart';
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';
import 'package:money_tracker/core/utils/haptic_feedback.dart';

class ProjectsDashboardScreen extends ConsumerWidget {
  const ProjectsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(userProjectsProvider);

    return Scaffold(
      body: SafeArea(
        child: projectsAsync.when(
          data: (projects) {
            if (projects.isEmpty) {
              return _EmptyState(
                onCreateProject: () => _navigateToCreateProject(context),
              );
            }
            return _ProjectsList(projects: projects);
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
      floatingActionButton: projectsAsync.maybeWhen(
        data: (projects) => projects.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () async {
                  await HapticFeedbackHelper.mediumImpact();
                  _navigateToCreateProject(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('New Project'),
                backgroundColor: AppColors.primaryPurple,
              )
            : null,
        orElse: () => null,
      ),
    );
  }

  void _navigateToCreateProject(BuildContext context) {
    context.push('/projects/create');
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateProject;

  const _EmptyState({required this.onCreateProject});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated illustration
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacing32),

            // Title
            Text(
              'Welcome to Finoro',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacing12),

            // Description
            Text(
              'Organize your finances into Projects.\nTrack budgets, expenses, and incomes\nall in one place.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacing40),

            // CTA Button
            ElevatedButton.icon(
              onPressed: () async {
                await HapticFeedbackHelper.mediumImpact();
                onCreateProject();
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.spacing16,
                  vertical: AppSizes.spacing12,
                ),
                child: Text(
                  'Create Your First Project',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
                ),
                elevation: 8,
                shadowColor: AppColors.primaryPurple.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectsList extends StatelessWidget {
  final List<Project> projects;

  const _ProjectsList({required this.projects});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Projects',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing8),
                Text(
                  '${projects.length} active ${projects.length == 1 ? 'project' : 'projects'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Projects Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final project = projects[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.spacing16),
                  child: ProjectCard(project: project),
                );
              },
              childCount: projects.length,
            ),
          ),
        ),

        // Bottom padding for FAB
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }
}
```

### Step 1.5: Create Project Card Widget (2 hours)

**File: `lib/ui/widgets/project_card.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker/features/projects/domain/project.dart';
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';
import 'package:money_tracker/core/utils/haptic_feedback.dart';
import 'package:money_tracker/ui/widgets/glass_card.dart';

class ProjectCard extends StatelessWidget {
  final Project project;

  const ProjectCard({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressPercentage = project.totalBudget > 0
        ? (project.totalExpenses / project.totalBudget).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: () async {
        await HapticFeedbackHelper.lightImpact();
        context.push('/projects/${project.id}');
      },
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          _parseColor(project.color),
                          _parseColor(project.color).withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        project.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing12),

                  // Title & Type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (project.description != null)
                          Text(
                            project.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // More icon
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () async {
                      await HapticFeedbackHelper.lightImpact();
                      _showProjectMenu(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing20),

              // Budget Progress
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Budget Progress',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        '${(progressPercentage * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacing8),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    child: LinearProgressIndicator(
                      value: progressPercentage,
                      minHeight: 8,
                      backgroundColor: AppColors.white(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _parseColor(project.color),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing16),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      label: 'Spent',
                      amount: project.totalExpenses,
                      color: Colors.redAccent,
                    ),
                  ),
                  Expanded(
                    child: _StatItem(
                      label: 'Remaining',
                      amount: project.remainingBudget,
                      color: Colors.greenAccent,
                    ),
                  ),
                  Expanded(
                    child: _StatItem(
                      label: 'Income',
                      amount: project.totalIncome,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
  }

  void _showProjectMenu(BuildContext context) {
    // TODO: Implement context menu
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.spacing20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Project'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archive Project'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Archive project
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _StatItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: AppSizes.spacing4),
        Text(
          '\$${amount.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
```

---

## 🎯 Phase 2: Budget & Transactions

_(Continue in next section due to length...)_

### Key Implementation Steps

1. Update MoneyTx model to include projectId
2. Create Budget model and repository
3. Link transaction creation to projects
4. Add budget tracking and warnings
5. Category management per project

---

## 📊 Phase 3: Insights & Analytics

### Features to Implement

1. Project-based transaction history
2. Monthly breakdown charts (using fl_chart)
3. Category spending pie charts
4. Cross-project comparisons
5. Export functionality

---

## ✨ Phase 4: Polish & Advanced Features

### iOS-Specific Features

1. **Haptic Feedback**

   - Button taps: medium impact
   - Successful actions: success haptic
   - Errors: error haptic
   - Swipe actions: light impact

2. **Face ID / Touch ID**

   ```dart
   import 'package:local_auth/local_auth.dart';

   final LocalAuthentication auth = LocalAuthentication();

   Future<bool> authenticateWithBiometrics() async {
     try {
       return await auth.authenticate(
         localizedReason: 'Authenticate to access your finances',
         options: const AuthenticationOptions(
           biometricOnly: true,
           stickyAuth: true,
         ),
       );
     } catch (e) {
       return false;
     }
   }
   ```

3. **Swipe Actions** (using flutter_slidable)
4. **Cupertino Context Menus**
5. **iOS Share Sheet**

---

## 🎨 UI Components

### Glassmorphic Design System

All cards should use the GlassCard widget with:

- Semi-transparent background
- Backdrop blur
- Subtle border
- Gradient accents

### Key Components to Create/Update

1. **ProjectCard** ✅ (created in Phase 1)
2. **CreateProjectSheet** - Modal bottom sheet
3. **BudgetProgressIndicator** - Circular/linear progress
4. **TransactionListItem** - With swipe actions
5. **CategoryPicker** - Grid of category icons
6. **ChartWidgets** - Using fl_chart package
7. **EmptyState** - Consistent empty states

---

## ✅ Implementation Checklist

### Week 1-2: Foundation

- [ ] Create Project domain model
- [ ] Implement Project repository
- [ ] Setup Riverpod providers
- [ ] Build Projects Dashboard screen
- [ ] Create Project Card widget
- [ ] Add Create Project flow
- [ ] Implement empty state

### Week 3-4: Budget & Transactions

- [ ] Update MoneyTx model with projectId
- [ ] Create Budget model
- [ ] Implement Budget repository
- [ ] Link transactions to projects
- [ ] Add budget tracking
- [ ] Create category management
- [ ] Update transaction forms

### Month 2: Insights

- [ ] Build Insights screen
- [ ] Add monthly breakdown charts
- [ ] Category spending analysis
- [ ] Cross-project comparisons
- [ ] Export functionality

### Month 3+: Polish

- [ ] Add haptic feedback throughout
- [ ] Implement Face ID/Touch ID
- [ ] Add swipe actions
- [ ] Cupertino dialogs and pickers
- [ ] iOS share sheet
- [ ] Project templates
- [ ] Recurring transactions

---

## 🚀 Getting Started

1. **Start with Phase 1** - Foundation is critical
2. **Test incrementally** - Don't build everything at once
3. **Follow iOS guidelines** - Keep the native feel
4. **Use haptic feedback** - Make it feel premium
5. **Focus on UX** - Smooth, fast, beautiful

**Let's build Finoro! 🎯**
