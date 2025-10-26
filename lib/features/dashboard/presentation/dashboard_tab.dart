import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';
import 'package:money_tracker/core/utils/haptic_feedback.dart';
import 'package:money_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:money_tracker/features/dashboard/domain/entities/create_project_input.dart';
import 'package:money_tracker/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:money_tracker/features/dashboard/domain/entities/project_overview.dart';
import 'package:money_tracker/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:money_tracker/ui/widgets/gradient_button.dart';

/// Dashboard tab showing project overview
class DashboardTab extends ConsumerStatefulWidget {
  const DashboardTab({super.key});

  @override
  ConsumerState<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<DashboardTab> {
  List<ProjectOverview> _cachedProjects = const <ProjectOverview>[];
  DashboardSummary _cachedSummary = DashboardSummary.empty;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final projectsAsync = ref.watch(dashboardProjectsProvider);
    final calculator = ref.watch(calculateDashboardSummaryProvider);
    projectsAsync.whenData((projects) {
      _cachedProjects = projects;
      _cachedSummary = calculator(projects);
    });

    return projectsAsync.when(
      data: (projects) {
        if (projects.isEmpty) {
          return _EmptyDashboardView(t: t);
        }
        final summary = calculator(projects);
        return _DashboardProjectsView(
          projects: projects,
          summary: summary,
          t: t,
        );
      },
      loading: () {
        if (_cachedProjects.isNotEmpty) {
          return _DashboardProjectsView(
            projects: _cachedProjects,
            summary: _cachedSummary,
            t: t,
          );
        }
        return _EmptyDashboardView(t: t);
      },
      error: (error, _) {
        if (_cachedProjects.isNotEmpty) {
          return _DashboardProjectsView(
            projects: _cachedProjects,
            summary: _cachedSummary,
            t: t,
          );
        }
        return _DashboardErrorView(
          t: t,
          onRetry: () => ref.invalidate(dashboardProjectsProvider),
        );
      },
    );
  }
}

/// Empty state view for dashboard when no projects exist
class _EmptyDashboardView extends ConsumerStatefulWidget {
  final AppLocalizations t;

  const _EmptyDashboardView({required this.t});

  @override
  ConsumerState<_EmptyDashboardView> createState() => _EmptyDashboardViewState();
}

class _EmptyDashboardViewState extends ConsumerState<_EmptyDashboardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacing24,
          vertical: AppSizes.spacing20,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSizes.maxDashboardWidth,
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                children: [
                  const _FinoroLogo(),
                  const SizedBox(height: AppSizes.spacing20),
                  ShaderMask(
                    shaderCallback:
                        (bounds) =>
                            AppColors.primaryGradient.createShader(bounds),
                    child: Text(
                      'Welcome to Finoro',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing12),
                  Text(
                    widget.t.createProjectPrompt,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing8),
                  Text(
                    'Track expenses, manage budgets, and gain insights\nfor each area of your financial life',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing24),
                  _DashboardEmptyCard(
                    t: widget.t,
                    onCreateProject: () => _presentCreateProjectSheet(
                      context,
                      ref,
                      widget.t,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Finoro logo with glow effect
class _FinoroLogo extends StatefulWidget {
  const _FinoroLogo();

  @override
  State<_FinoroLogo> createState() => _FinoroLogoState();
}

class _FinoroLogoState extends State<_FinoroLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.vibrantPurple.withValues(
                  alpha: 0.3 + (_glowController.value * 0.3),
                ),
                blurRadius: 30 + (_glowController.value * 15),
                spreadRadius: 3 + (_glowController.value * 7),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        );
      },
    );
  }
}

/// Card displaying empty state with create project button
class _DashboardEmptyCard extends StatelessWidget {
  final AppLocalizations t;
  final Future<void> Function() onCreateProject;

  const _DashboardEmptyCard({required this.t, required this.onCreateProject});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacing24,
        AppSizes.spacing28,
        AppSizes.spacing24,
        AppSizes.spacing24,
      ),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_special_rounded,
            size: 48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSizes.spacing14),
          Text(
            t.noProjectsYet,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSizes.spacing6),
          Text(
            t.createProjectPrompt,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSizes.spacing20),
          GradientButton(
            label: t.createNewProjectButton,
            icon: Icons.add_rounded,
            onPressed: () async {
              await HapticFeedbackHelper.mediumImpact();
              await onCreateProject();
            },
          ),
          const SizedBox(height: AppSizes.spacing12),
          Text(
            '💡 Tip: Projects help separate expenses\nfor different areas of your life',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
              height: 1.3,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardErrorView extends StatelessWidget {
  final AppLocalizations t;
  final VoidCallback onRetry;

  const _DashboardErrorView({required this.t, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSizes.spacing12),
            Text(
              t.dashboardError,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.spacing12),
            TextButton(onPressed: onRetry, child: Text(t.dashboardRetry)),
          ],
        ),
      ),
    );
  }
}

Future<void> _presentCreateProjectSheet(
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

  final nameController = TextEditingController();
  final budgetController = TextEditingController();
  final currencyController = TextEditingController(text: 'USD');
  final formKey = GlobalKey<FormState>();
  final createProject = ref.read(createProjectUseCaseProvider);

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
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom +
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
                        t.createProjectTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: AppSizes.spacing16),
                      TextFormField(
                        controller: nameController,
                        enabled: !isSubmitting,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(labelText: t.projectNameLabel),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return t.fieldRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.spacing12),
                      TextFormField(
                        controller: budgetController,
                        enabled: !isSubmitting,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(labelText: t.projectBudgetLabel),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return t.fieldRequired;
                          }
                          final parsed = double.tryParse(value.replaceAll(',', '.'));
                          if (parsed == null || parsed <= 0) {
                            return t.invalidNumber;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.spacing12),
                      TextFormField(
                        controller: currencyController,
                        enabled: !isSubmitting,
                        textCapitalization: TextCapitalization.characters,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(labelText: t.projectCurrencyLabel),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return t.fieldRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.spacing24),
                      FilledButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) {
                                  await HapticFeedbackHelper.error();
                                  return;
                                }

                                FocusScope.of(sheetContext).unfocus();
                                setModalState(() => isSubmitting = true);

                                final budget =
                                    double.parse(budgetController.text.replaceAll(',', '.'));
                                final currency =
                                    currencyController.text.trim().toUpperCase();
                                final input = CreateProjectInput(
                                  name: nameController.text.trim(),
                                  budget: budget,
                                  currency: currency,
                                );

                                try {
                                  await createProject(user.uid, input);
                                  ref.invalidate(dashboardProjectsProvider);
                                  await HapticFeedbackHelper.success();
                                  if (!sheetContext.mounted) return;
                                  if (Navigator.of(sheetContext).canPop()) {
                                    Navigator.of(sheetContext).pop();
                                  }
                                  if (!context.mounted) return;
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(t.projectCreationSuccess),
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
                                      error is FirebaseException && error.message != null
                                          ? error.message!
                                          : t.projectCreationFailed;
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.spacing12,
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  t.projectCreateAction,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                        ),
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

  nameController.dispose();
  budgetController.dispose();
  currencyController.dispose();
}

class _DashboardProjectsView extends ConsumerWidget {
  final List<ProjectOverview> projects;
  final DashboardSummary summary;
  final AppLocalizations t;

  const _DashboardProjectsView({
    required this.projects,
    required this.summary,
    required this.t,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacing24,
          vertical: AppSizes.spacing20,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSizes.maxDashboardWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DashboardSummaryCard(summary: summary, t: t),
              const SizedBox(height: AppSizes.spacing24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.dashboardProjectsTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      HapticFeedbackHelper.mediumImpact();
                      await _presentCreateProjectSheet(context, ref, t);
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: Text(t.createNewProjectButton),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: projects.length,
                separatorBuilder:
                    (_, __) => const SizedBox(height: AppSizes.spacing12),
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return _ProjectOverviewCard(project: project, t: t);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardSummaryCard extends StatelessWidget {
  final DashboardSummary summary;
  final AppLocalizations t;

  const _DashboardSummaryCard({required this.summary, required this.t});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.vibrantPurple.withValues(alpha: 0.35),
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
            t.dashboardSummaryTitle,
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
              _MetricChip(
                label: t.dashboardTotalProjects,
                value: summary.totalProjects.toString(),
              ),
              _MetricChip(
                label: t.dashboardTotalBudget,
                value: _formatCurrency(summary.totalBudget),
              ),
              _MetricChip(
                label: t.dashboardTotalSpent,
                value: _formatCurrency(summary.totalSpent),
              ),
              _MetricChip(
                label: t.dashboardRemaining,
                value: _formatCurrency(summary.remaining),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }
}

class _ProjectOverviewCard extends StatelessWidget {
  final ProjectOverview project;
  final AppLocalizations t;

  const _ProjectOverviewCard({required this.project, required this.t});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = project.remaining;
    final isOverBudget = project.isOverBudget;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
        border: Border.all(color: AppColors.white(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: Center(child: _ProjectInitials(name: project.name)),
              ),
              const SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (project.createdAt != null)
                      Text(
                        'Created ${_formatDate(project.createdAt!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing16),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            child: LinearProgressIndicator(
              value: project.progress,
              backgroundColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.1,
              ),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.redAccent : AppColors.vibrantPurple,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Wrap(
            spacing: AppSizes.spacing12,
            runSpacing: AppSizes.spacing12,
            children: [
              _MetricChip(
                label: t.dashboardProjectBudget,
                value: _formatCurrency(project.currency, project.budget),
              ),
              _MetricChip(
                label: t.dashboardProjectSpent,
                value: _formatCurrency(project.currency, project.spent),
              ),
              _MetricChip(
                label: t.dashboardProjectRemaining,
                value: _formatCurrency(project.currency, remaining),
                emphasis: isOverBudget ? Colors.redAccent : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(String currency, double value) {
    final symbol = _currencySymbols[currency.toUpperCase()] ?? currency;
    final amount =
        value.abs() >= 1000
            ? value.toStringAsFixed(0)
            : value.toStringAsFixed(2);
    return '$symbol$amount';
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'UAH': '₴',
    'GBP': '£',
  };
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? emphasis;

  const _MetricChip({required this.label, required this.value, this.emphasis});

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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 11,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: emphasis ?? theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectInitials extends StatelessWidget {
  const _ProjectInitials({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial =
        trimmed.isNotEmpty
            ? String.fromCharCode(trimmed.runes.first).toUpperCase()
            : '?';
    return Text(
      initial.toUpperCase(),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
    );
  }
}
