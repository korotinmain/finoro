import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return _EmptyDashboardState(t: t);
  }
}

class ExpensesTab extends StatelessWidget {
  const ExpensesTab({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Center(child: Text(t.tabExpenses));
  }
}

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Center(child: Text(t.tabHistory));
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.tabSettings,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
              } catch (_) {}
              if (!context.mounted) return;
              GoRouter.of(context).go('/login');
            },
            icon: const Icon(Icons.logout_rounded),
            label: Text(t.signOut),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDashboardState extends StatelessWidget {
  final AppLocalizations t;
  const _EmptyDashboardState({required this.t});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withValues(alpha: .92),
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
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
                const SizedBox(height: 14),
                Text(
                  t.createProjectPrompt,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: .7),
                  ),
                ),
                const SizedBox(height: 38),
                _DashboardCard(t: t),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final AppLocalizations t;
  const _DashboardCard({required this.t});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 26),
      decoration: BoxDecoration(
        color: const Color(0xFF141519).withValues(alpha: .72),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .45),
            blurRadius: 34,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: .04),
            blurRadius: 12,
            spreadRadius: -6,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF505BFF), Color(0xFF7D48FF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .3),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.pie_chart_rounded,
                color: Colors.white,
                size: 54,
              ),
            ),
          ),
          const SizedBox(height: 28),
          _PrimaryGradientButton(
            label: t.createNewProjectButton,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _PrimaryGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _PrimaryGradientButton({required this.label, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF505BFF), Color(0xFF7D48FF)],
        ),
        borderRadius: BorderRadius.all(Radius.circular(26)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(26),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
