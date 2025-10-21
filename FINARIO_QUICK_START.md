# 🚀 Finario Quick Start: Implement Your First Project

**Goal**: Create a working Projects Dashboard in 4-6 hours

---

## 📋 Overview

This guide will walk you through implementing the **core Project feature** - the heart of Finario. By the end, you'll have:

✅ Projects data model with Firestore  
✅ Projects Dashboard with empty state  
✅ Beautiful project cards with progress indicators  
✅ "Create Project" flow  
✅ Haptic feedback and iOS polish

---

## ⚡ Step-by-Step Implementation

### Step 1: Create Project Domain Model (30 min)

**File**: `lib/features/projects/domain/project.dart`

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
    String? description,
    required String type, // 'vacation', 'monthly_budget', 'savings', etc.
    required String icon,  // emoji
    required String color, // hex color
    required double totalBudget,
    required DateTime createdAt,
    DateTime? targetDate,
    @Default(false) bool isArchived,
    @Default(0.0) double totalExpenses,
    @Default(0.0) double totalIncome,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

  // Convenience getters
  const Project._();

  double get remainingBudget => totalBudget - totalExpenses;
  double get balance => totalIncome - totalExpenses;
  double get progressPercentage => totalBudget > 0
      ? (totalExpenses / totalBudget).clamp(0.0, 1.0)
      : 0.0;
}
```

**Run code generation**:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### Step 2: Create Project Repository (45 min)

**File**: `lib/features/projects/data/projects_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_tracker/features/projects/domain/project.dart';

abstract class IProjectsRepository {
  Stream<List<Project>> watchUserProjects(String userId);
  Future<Project?> getProject(String projectId);
  Future<void> createProject(Project project);
  Future<void> updateProject(Project project);
  Future<void> archiveProject(String projectId);
}

class ProjectsRepository implements IProjectsRepository {
  final FirebaseFirestore _firestore;

  ProjectsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Project>> watchUserProjects(String userId) {
    return _firestore
        .collection('projects')
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Project.fromJson({...data, 'id': doc.id});
          }).toList();
        });
  }

  @override
  Future<Project?> getProject(String projectId) async {
    final doc = await _firestore.collection('projects').doc(projectId).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return Project.fromJson({...data, 'id': doc.id});
  }

  @override
  Future<void> createProject(Project project) async {
    final data = project.toJson();
    data.remove('id'); // Firestore auto-generates

    await _firestore.collection('projects').doc(project.id).set(data);
  }

  @override
  Future<void> updateProject(Project project) async {
    final data = project.toJson();
    data.remove('id');

    await _firestore.collection('projects').doc(project.id).update(data);
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

---

### Step 3: Setup Riverpod Providers (20 min)

**File**: `lib/features/projects/providers/projects_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker/features/projects/data/projects_repository.dart';
import 'package:money_tracker/features/projects/domain/project.dart';
import 'package:money_tracker/core/providers/auth_providers.dart';

// Repository provider
final projectsRepositoryProvider = Provider<IProjectsRepository>((ref) {
  return ProjectsRepository();
});

// Watch user's projects
final userProjectsProvider = StreamProvider<List<Project>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  final repository = ref.watch(projectsRepositoryProvider);
  return repository.watchUserProjects(user.uid);
});

// Single project provider
final projectProvider = FutureProvider.family<Project?, String>((ref, projectId) async {
  final repository = ref.read(projectsRepositoryProvider);
  return repository.getProject(projectId);
});
```

---

### Step 4: Build Projects Dashboard Screen (90 min)

**File**: `lib/features/projects/presentation/projects_dashboard_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker/features/projects/providers/projects_providers.dart';
import 'package:money_tracker/features/projects/domain/project.dart';
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';
import 'package:money_tracker/core/utils/haptic_feedback.dart';
import 'package:money_tracker/ui/widgets/glass_card.dart';

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
              return _buildEmptyState(context);
            }
            return _buildProjectsList(context, projects);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
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
                  // TODO: Navigate to create project
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Create Project - Coming soon!')),
                  );
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

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacing32),

            Text(
              'Welcome to Finario',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacing12),

            Text(
              'Organize your finances into Projects.\nTrack budgets, expenses, and incomes\nall in one place.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacing40),

            ElevatedButton.icon(
              onPressed: () async {
                await HapticFeedbackHelper.mediumImpact();
                // TODO: Navigate to create project
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Create Project - Coming soon!')),
                );
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

  Widget _buildProjectsList(BuildContext context, List<Project> projects) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Projects',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing8),
                Text(
                  '${projects.length} active ${projects.length == 1 ? 'project' : 'projects'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.spacing16),
                  child: _ProjectCard(project: projects[index]),
                );
              },
              childCount: projects.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () async {
        await HapticFeedbackHelper.lightImpact();
        // TODO: Navigate to project details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Open ${project.name}')),
        );
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
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _parseColor(project.color).withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child: Text(project.icon, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (project.description != null)
                          Text(
                            project.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing20),

              // Progress
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
                    '${(project.progressPercentage * 100).toInt()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing8),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                child: LinearProgressIndicator(
                  value: project.progressPercentage,
                  minHeight: 8,
                  backgroundColor: AppColors.white(0.1),
                  valueColor: AlwaysStoppedAnimation(_parseColor(project.color)),
                ),
              ),
              const SizedBox(height: AppSizes.spacing16),

              // Stats
              Row(
                children: [
                  _buildStat('Spent', project.totalExpenses, Colors.redAccent),
                  _buildStat('Remaining', project.remainingBudget, Colors.greenAccent),
                  _buildStat('Income', project.totalIncome, Colors.blueAccent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, double amount, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }
}
```

---

### Step 5: Update Navigation (15 min)

**File**: `lib/core/routing/app_router.dart`

Add projects route:

```dart
GoRoute(
  path: '/projects',
  builder: (context, state) => const ProjectsDashboardScreen(),
),
```

---

### Step 6: Test with Sample Data (30 min)

Create a test button to add sample projects in Firebase Console or via code:

```dart
// Temporary helper to create sample project
Future<void> _createSampleProject(WidgetRef ref) async {
  final user = ref.read(currentUserProvider);
  if (user == null) return;

  final project = Project(
    id: const Uuid().v4(),
    userId: user.uid,
    name: 'Summer Vacation 2025',
    description: 'Trip to Hawaii',
    type: 'vacation',
    icon: '🏖️',
    color: '#4ECDC4',
    totalBudget: 5000.0,
    createdAt: DateTime.now(),
    totalExpenses: 1200.0,
    totalIncome: 0.0,
  );

  final repository = ref.read(projectsRepositoryProvider);
  await repository.createProject(project);
}
```

---

## ✅ Testing Checklist

- [ ] Empty state displays correctly
- [ ] Can navigate to projects dashboard
- [ ] Sample project card renders properly
- [ ] Progress bar shows correct percentage
- [ ] Stats display correct amounts
- [ ] Haptic feedback works on taps
- [ ] Loading state shows while fetching
- [ ] Error handling works

---

## 🎯 Next Steps

Once the dashboard is working:

1. **Create Project Flow** (2-3 hours)

   - Modal bottom sheet
   - Form with name, type, icon, budget
   - Save to Firestore

2. **Link Transactions to Projects** (2-3 hours)

   - Update MoneyTx model
   - Add projectId field
   - Filter transactions by project

3. **Project Details Screen** (3-4 hours)
   - Full project view
   - Transaction list
   - Budget breakdown
   - Edit/archive options

---

## 🚀 You're Ready!

Start with Step 1 and work through each section. Test as you go. By the end, you'll have a working Projects Dashboard - the core of Finario!

**Happy coding! 💪**
