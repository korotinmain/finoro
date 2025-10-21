import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';
import 'package:money_tracker/core/utils/haptic_feedback.dart';
import 'package:money_tracker/ui/widgets/glow_blob.dart';
import 'package:money_tracker/ui/widgets/gradient_button.dart';
import 'package:money_tracker/ui/widgets/settings_list_item.dart';
import 'package:money_tracker/ui/widgets/user_profile_card.dart';

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
            gradient: AppColors.backgroundGradient,
          ),
        ),
        // Decorative blur blobs
        GlowBlob.purpleBlue(size: AppSizes.blobMedium, left: -80, top: -120),
        GlowBlob.purpleCyan(
          size: AppSizes.blobLarge,
          right: -110,
          bottom: -140,
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spacing20,
              AppSizes.spacing8,
              AppSizes.spacing20,
              AppSizes.spacing28,
            ),
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
                const SizedBox(height: AppSizes.spacing16),
                UserProfileCard(
                  displayName: displayName,
                  email: email,
                  isVerified: verified,
                  verifiedLabel: t.statusVerified,
                  unverifiedLabel: t.statusUnverified,
                ),
                const SizedBox(height: AppSizes.spacing20),
                SettingsListItem(
                  icon: Icons.manage_accounts_rounded,
                  label: t.accountSettings,
                  onTap: () async {
                    await HapticFeedbackHelper.lightImpact();
                    if (context.mounted) context.push('/settings/account');
                  },
                ),
                SettingsListItem(
                  icon: Icons.palette_rounded,
                  label: t.appearanceSettings,
                  onTap: () async {
                    await HapticFeedbackHelper.lightImpact();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Appearance settings coming soon! 🎨',
                          ),
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
                SettingsListItem(
                  icon: Icons.notifications_rounded,
                  label: t.notifications,
                  onTap: () async {
                    await HapticFeedbackHelper.lightImpact();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Notification settings coming soon! 🔔',
                          ),
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
                SettingsListItem(
                  icon: Icons.lock_outline_rounded,
                  label: t.securityPrivacy,
                  onTap: () async {
                    await HapticFeedbackHelper.lightImpact();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Security settings coming soon! 🔐',
                          ),
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
                SettingsListItem(
                  icon: Icons.feedback_rounded,
                  label: t.feedback,
                  onTap: () async {
                    await HapticFeedbackHelper.lightImpact();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Feedback form coming soon! 💬'),
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
                SettingsListItem(
                  icon: Icons.info_outline_rounded,
                  label: t.about,
                  onTap: () async {
                    await HapticFeedbackHelper.lightImpact();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('About screen coming soon! ℹ️'),
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
                const SizedBox(height: AppSizes.spacing24),
                Center(
                  child: _SignOutButton(
                    label: t.signOut,
                    confirmTitle: t.confirmSignOutTitle,
                    confirmMessage: t.confirmSignOutMessage,
                    confirm: t.confirm,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing14),
                Opacity(
                  opacity: 0.55,
                  child: FutureBuilder<String>(
                    future: _getVersion(),
                    builder:
                        (ctx, snap) => Text(
                          snap.hasData ? t.versionLabel(snap.data!) : ' ',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
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

/// Sign out button with confirmation dialog
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
    return GradientButton(
      label: label,
      icon: Icons.logout_rounded,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primaryPurple, AppColors.primaryBlue],
      ),
      onPressed: () => _handleSignOut(context),
    );
  }
}
