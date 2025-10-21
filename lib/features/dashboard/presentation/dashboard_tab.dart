import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';
import 'package:money_tracker/ui/widgets/gradient_button.dart';

/// Dashboard tab showing project overview
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return _EmptyDashboardView(t: t);
  }
}

/// Empty state view for dashboard when no projects exist
class _EmptyDashboardView extends StatelessWidget {
  final AppLocalizations t;

  const _EmptyDashboardView({required this.t});

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                t.noProjectsYet,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSizes.spacing14),
              Text(
                t.createProjectPrompt,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppSizes.spacing38),
              _DashboardEmptyCard(t: t),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card displaying empty state with create project button
class _DashboardEmptyCard extends StatelessWidget {
  final AppLocalizations t;

  const _DashboardEmptyCard({required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacing32,
        AppSizes.spacing40,
        AppSizes.spacing32,
        AppSizes.spacing26,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppSizes.radiusXXLarge),
        border: Border.all(color: AppColors.white(0.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSizes.avatarLarge,
            height: AppSizes.avatarLarge,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: const Center(
              child: Icon(
                Icons.pie_chart_rounded,
                color: Colors.white,
                size: AppSizes.iconXLarge,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacing28),
          GradientButton(
            label: t.createNewProjectButton,
            icon: Icons.add_rounded,
            onPressed: () {
              // TODO: Navigate to create project screen
            },
          ),
        ],
      ),
    );
  }
}
