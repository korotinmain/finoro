import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

  Future<String> _getVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return '${info.version}+${info.buildNumber}';
    } catch (_) {
      return '1.0.0';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'anonymous';
    final displayName =
        (user?.displayName?.trim().isNotEmpty ?? false)
            ? user!.displayName!.trim()
            : email.split('@').first;
    final verified = user?.emailVerified ?? false;

    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D0E12), Color(0xFF181A23)],
            ),
          ),
        ),
        // Decorative blur blobs
        const Positioned(
          top: -120,
          left: -80,
          child: _BlurBlob(
            diameter: 260,
            colors: [Color(0xFF6C4DFF), Color(0xFF5B7CFF)],
            opacity: .35,
          ),
        ),
        const Positioned(
          bottom: -140,
          right: -110,
          child: _BlurBlob(
            diameter: 300,
            colors: [Color(0xFF5B7CFF), Color(0xFF6C4DFF)],
            opacity: .25,
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.tabSettings,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 16),
                _SettingsUserCard(
                  displayName: displayName,
                  email: email,
                  verified: verified,
                ),
                const SizedBox(height: 20),
                _GlassSettingsItem(
                  icon: Icons.manage_accounts_rounded,
                  label: t.accountSettings,
                  onTap: () => GoRouter.of(context).push('/settings/account'),
                ),
                _GlassSettingsItem(
                  icon: Icons.palette_rounded,
                  label: t.appearanceSettings,
                  onTap: () {},
                ),
                _GlassSettingsItem(
                  icon: Icons.notifications_rounded,
                  label: t.notifications,
                  onTap: () {},
                ),
                _GlassSettingsItem(
                  icon: Icons.lock_outline_rounded,
                  label: t.securityPrivacy,
                  onTap: () {},
                ),
                _GlassSettingsItem(
                  icon: Icons.feedback_rounded,
                  label: t.feedback,
                  onTap: () {},
                ),
                _GlassSettingsItem(
                  icon: Icons.info_outline_rounded,
                  label: t.about,
                  onTap: () {},
                ),
                const SizedBox(height: 24),
                Center(
                  child: _SignOutButton(
                    label: t.signOut,
                    confirmTitle: t.confirmSignOutTitle,
                    confirmMessage: t.confirmSignOutMessage,
                    confirm: t.confirm,
                  ),
                ),
                const SizedBox(height: 14),
                Opacity(
                  opacity: .55,
                  child: FutureBuilder<String>(
                    future: _getVersion(),
                    builder:
                        (ctx, snap) => Text(
                          snap.hasData ? t.versionLabel(snap.data!) : ' ',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            letterSpacing: .3,
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsUserCard extends StatelessWidget {
  final String displayName;
  final String email;
  final bool verified;
  const _SettingsUserCard({
    required this.displayName,
    required this.email,
    required this.verified,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final statusColor = verified ? Colors.greenAccent : Colors.orangeAccent;
    final badgeIcon = verified ? Icons.verified_rounded : Icons.error_outline;
    final badgeColor = verified ? Colors.lightGreenAccent : Colors.amberAccent;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF141519).withValues(alpha: .72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF505BFF), Color(0xFF7D48FF)],
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: .65),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .12),
                      width: 1,
                    ),
                  ),
                  child: Icon(badgeIcon, size: 18, color: badgeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: .3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: .6),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                verified ? t.statusVerified : t.statusUnverified,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: .75),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  final String label;
  final String confirmTitle;
  final String confirmMessage;
  final String confirm;
  const _SignOutButton({
    required this.label,
    required this.confirmTitle,
    required this.confirmMessage,
    required this.confirm,
  });
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C4DFF), Color(0xFF5B7CFF)],
        ),
        borderRadius: BorderRadius.all(Radius.circular(26)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: () async {
            final should = await showDialog<bool>(
              context: context,
              builder:
                  (ctx) => AlertDialog(
                    title: Text(confirmTitle),
                    content: Text(confirmMessage),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(t.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(confirm),
                      ),
                    ],
                  ),
            );
            if (should != true) return;
            try {
              await FirebaseAuth.instance.signOut();
            } catch (_) {}
            if (!context.mounted) return;
            GoRouter.of(context).go('/login');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.logout_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

class _GlassSettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _GlassSettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF1F2126).withValues(alpha: .72),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: .06)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6C4DFF), Color(0xFF5B7CFF)],
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: .2,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: .7),
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  final double diameter;
  final List<Color> colors;
  final double opacity;
  const _BlurBlob({
    required this.diameter,
    required this.colors,
    this.opacity = .3,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: colors
                .map((c) => c.withValues(alpha: opacity))
                .toList(growable: false),
          ),
        ),
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
    return Center(
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
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF505BFF), Color(0xFF7D48FF)],
              ),
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
