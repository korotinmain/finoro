import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';
import 'package:money_tracker/ui/widgets/gradient_button.dart';
import 'package:money_tracker/core/utils/haptic_feedback.dart';

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
class _EmptyDashboardView extends StatefulWidget {
  final AppLocalizations t;

  const _EmptyDashboardView({required this.t});

  @override
  State<_EmptyDashboardView> createState() => _EmptyDashboardViewState();
}

class _EmptyDashboardViewState extends State<_EmptyDashboardView>
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const _FinarioLogo(),
                  const SizedBox(height: AppSizes.spacing20),
                  ShaderMask(
                    shaderCallback:
                        (bounds) =>
                            AppColors.primaryGradient.createShader(bounds),
                    child: Text(
                      'Welcome to Finario',
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
                    'Organize your finances through Projects',
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
                  _DashboardEmptyCard(t: widget.t),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Finario logo with glow effect
class _FinarioLogo extends StatefulWidget {
  const _FinarioLogo();

  @override
  State<_FinarioLogo> createState() => _FinarioLogoState();
}

class _FinarioLogoState extends State<_FinarioLogo>
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

  const _DashboardEmptyCard({required this.t});

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
            'Your Projects',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSizes.spacing6),
          Text(
            'Create your first project to start\ntracking expenses and budgets',
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
              // TODO: Navigate to create project screen
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Project creation coming soon! 🚀'),
                    backgroundColor: AppColors.vibrantPurple,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
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
