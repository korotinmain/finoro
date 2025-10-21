import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';
import 'package:money_tracker/core/utils/haptic_feedback.dart';
import 'package:money_tracker/ui/widgets/glow_blob.dart';

/// Settings tab for app configuration and user preferences
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

  void _showComingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.vibrantPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
        Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
        ),
        Positioned(
          left: -80,
          top: 60,
          child: GlowBlob.purpleBlue(size: AppSizes.blobMedium),
        ),
        Positioned(
          right: -110,
          bottom: -140,
          child: GlowBlob.purpleCyan(size: AppSizes.blobLarge),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              top: false,
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.spacing24,
                  AppSizes.spacing12,
                  AppSizes.spacing24,
                  0,
                ),
                child: Text(
                  t.tabSettings,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacing16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.spacing24,
                  0,
                  AppSizes.spacing24,
                  AppSizes.spacing24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileCard(
                      displayName: displayName,
                      email: email,
                      isVerified: verified,
                      verifiedLabel: t.statusVerified,
                    ),
                    const SizedBox(height: AppSizes.spacing24),
                    _SettingsGroup(
                      title: 'GENERAL',
                      items: [
                        _SettingsItemData(
                          icon: Icons.person_outline_rounded,
                          label: t.accountSettings,
                          onTap: () {
                            HapticFeedbackHelper.lightImpact();
                            context.push('/settings/account');
                          },
                        ),
                        _SettingsItemData(
                          icon: Icons.palette_outlined,
                          label: t.appearanceSettings,
                          onTap: () {
                            HapticFeedbackHelper.lightImpact();
                            _showComingSoon(
                              context,
                              'Appearance settings coming soon! 🎨',
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacing20),
                    _SettingsGroup(
                      title: 'PREFERENCES',
                      items: [
                        _SettingsItemData(
                          icon: Icons.notifications_outlined,
                          label: t.notifications,
                          onTap: () {
                            HapticFeedbackHelper.lightImpact();
                            _showComingSoon(
                              context,
                              'Notification settings coming soon! 🔔',
                            );
                          },
                        ),
                        _SettingsItemData(
                          icon: Icons.lock_outline_rounded,
                          label: t.securityPrivacy,
                          onTap: () {
                            HapticFeedbackHelper.lightImpact();
                            _showComingSoon(
                              context,
                              'Security settings coming soon! 🔐',
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacing20),
                    _SettingsGroup(
                      title: 'SUPPORT',
                      items: [
                        _SettingsItemData(
                          icon: Icons.feedback_outlined,
                          label: t.feedback,
                          onTap: () {
                            HapticFeedbackHelper.lightImpact();
                            _showComingSoon(
                              context,
                              'Feedback form coming soon! 💬',
                            );
                          },
                        ),
                        _SettingsItemData(
                          icon: Icons.info_outline_rounded,
                          label: t.about,
                          onTap: () {
                            HapticFeedbackHelper.lightImpact();
                            _showComingSoon(
                              context,
                              'About screen coming soon! ℹ️',
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacing24),
                    _SignOutButton(
                      label: t.signOut,
                      confirmTitle: t.confirmSignOutTitle,
                      confirmMessage: t.confirmSignOutMessage,
                      confirm: t.confirm,
                    ),
                    const SizedBox(height: AppSizes.spacing16),
                    Center(
                      child: Opacity(
                        opacity: 0.35,
                        child: FutureBuilder<String>(
                          future: _getVersion(),
                          builder:
                              (ctx, snap) => Text(
                                snap.hasData ? t.versionLabel(snap.data!) : ' ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String displayName;
  final String email;
  final bool isVerified;
  final String verifiedLabel;

  const _ProfileCard({
    required this.displayName,
    required this.email,
    required this.isVerified,
    required this.verifiedLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.vibrantPurple.withValues(alpha: 0.1),
            AppColors.primaryBlue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.white(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSizes.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isVerified) ...[
                  const SizedBox(height: AppSizes.spacing8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: Colors.greenAccent,
                      ),
                      const SizedBox(width: AppSizes.spacing4),
                      Text(
                        verifiedLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<_SettingsItemData> items;

  const _SettingsGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSizes.spacing4,
            bottom: AppSizes.spacing12,
          ),
          child: Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
        ...items.map((item) => _SettingsItem(data: item)),
      ],
    );
  }
}

class _SettingsItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsItemData({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _SettingsItem extends StatelessWidget {
  final _SettingsItemData data;

  const _SettingsItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          onTap: data.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacing16,
              vertical: AppSizes.spacing14,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardBackground.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(color: AppColors.white(0.05)),
            ),
            child: Row(
              children: [
                Icon(
                  data.icon,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 22,
                ),
                const SizedBox(width: AppSizes.spacing16),
                Expanded(
                  child: Text(
                    data.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
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

  Future<void> _handleSignOut(BuildContext context) async {
    await HapticFeedbackHelper.mediumImpact();

    final t = AppLocalizations.of(context)!;
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(confirmTitle),
            content: Text(confirmMessage),
            actions: [
              TextButton(
                onPressed: () async {
                  await HapticFeedbackHelper.lightImpact();
                  if (ctx.mounted) Navigator.pop(ctx, false);
                },
                child: Text(t.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  await HapticFeedbackHelper.mediumImpact();
                  if (ctx.mounted) Navigator.pop(ctx, true);
                },
                child: Text(confirm),
              ),
            ],
          ),
    );

    if (shouldSignOut != true || !context.mounted) return;

    await HapticFeedbackHelper.success();

    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Successfully signed out'),
            backgroundColor: Colors.green.shade900,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        await HapticFeedbackHelper.error();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to sign out. Please try again.'),
            backgroundColor: Colors.red.shade900,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        onTap: () => _handleSignOut(context),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacing16,
            vertical: AppSizes.spacing16,
          ),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: AppSizes.spacing12),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
