import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';
import 'package:money_tracker/core/routing/app_routes.dart';
import 'package:money_tracker/core/utils/haptic_feedback.dart';
import 'package:money_tracker/features/settings/domain/entities/user_profile.dart';
import 'package:money_tracker/features/settings/presentation/providers/locale_controller.dart';
import 'package:money_tracker/features/settings/presentation/providers/settings_providers.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

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

  void _showLanguageDialog(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    showDialog<void>(context: context, builder: (ctx) => _LanguageDialog(t: t));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final displayName = _resolveDisplayName(profile);
    final email = profile?.email ?? 'anonymous';
    final verified = profile?.isEmailVerified ?? false;
    final appInfoAsync = ref.watch(appInfoProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
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
                                context.push(AppRoutes.accountSettings);
                              },
                            ),
                            _SettingsItemData(
                              icon: Icons.language_rounded,
                              label: t.language,
                              onTap: () {
                                HapticFeedbackHelper.lightImpact();
                                _showLanguageDialog(context);
                              },
                            ),
                            _SettingsItemData(
                              icon: Icons.palette_outlined,
                              label: t.appearanceSettings,
                              onTap: () {
                                HapticFeedbackHelper.lightImpact();
                                _showComingSoon(
                                  context,
                                  t.comingSoonAppearance,
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
                                  t.comingSoonNotifications,
                                );
                              },
                            ),
                            _SettingsItemData(
                              icon: Icons.lock_outline_rounded,
                              label: t.securityPrivacy,
                              onTap: () {
                                HapticFeedbackHelper.lightImpact();
                                _showComingSoon(context, t.comingSoonSecurity);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.spacing20),
                        _SettingsGroup(
                          title: 'SUPPORT',
                          items: [
                            _SettingsItemData(
                              icon: Icons.help_outline_rounded,
                              label: t.help,
                              onTap: () {
                                HapticFeedbackHelper.lightImpact();
                                context.push(AppRoutes.help);
                              },
                            ),
                            _SettingsItemData(
                              icon: Icons.feedback_outlined,
                              label: t.feedback,
                              onTap: () {
                                HapticFeedbackHelper.lightImpact();
                                _showComingSoon(context, t.comingSoonFeedback);
                              },
                            ),
                            _SettingsItemData(
                              icon: Icons.info_outline_rounded,
                              label: t.about,
                              onTap: () {
                                HapticFeedbackHelper.lightImpact();
                                _showComingSoon(context, t.comingSoonAbout);
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
                            child: appInfoAsync.when(
                              data:
                                  (info) => Text(
                                    t.versionLabel(info.version),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                              loading:
                                  () => Text(
                                    ' ',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                              error:
                                  (_, __) => Text(
                                    ' ',
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
          ),
        ],
      ),
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

String _resolveDisplayName(UserProfile? profile) {
  if (profile == null) {
    return 'anonymous';
  }
  final trimmed = profile.displayName.trim();
  if (trimmed.isNotEmpty) {
    return trimmed;
  }
  if (profile.email.isNotEmpty) {
    return profile.email.split('@').first;
  }
  return 'anonymous';
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

class _SignOutButton extends ConsumerWidget {
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

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    await HapticFeedbackHelper.mediumImpact();
    if (!context.mounted) return;

    final t = AppLocalizations.of(context)!;
    final shouldSignOut = await showDialog<bool?>(
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
    if (!context.mounted) return;

    try {
      await ref.read(signOutUserUseCaseProvider).call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.signOutSuccess),
            backgroundColor: Colors.green.shade900,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      await HapticFeedbackHelper.error();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.signOutFailed),
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
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        onTap: () => _handleSignOut(context, ref),
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

/// Language selection dialog
class _LanguageDialog extends ConsumerWidget {
  final AppLocalizations t;

  const _LanguageDialog({required this.t});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedLocale = ref.watch(localeControllerProvider);
    final activeLocaleCode =
        selectedLocale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final controller = ref.read(localeControllerProvider.notifier);

    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        side: BorderSide(color: AppColors.white(0.1)),
      ),
      title: Text(
        t.selectLanguage,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageOption(
            languageName: t.languageEnglish,
            languageCode: 'en',
            isSelected: activeLocaleCode == 'en',
            onTap: () async {
              await HapticFeedbackHelper.lightImpact();
              await controller.setLocale(const Locale('en'));
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t.languageChanged(t.languageEnglish)),
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
          const SizedBox(height: AppSizes.spacing8),
          _LanguageOption(
            languageName: t.languageUkrainian,
            languageCode: 'uk',
            isSelected: activeLocaleCode == 'uk',
            onTap: () async {
              await HapticFeedbackHelper.lightImpact();
              await controller.setLocale(const Locale('uk'));
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t.languageChanged(t.languageUkrainian)),
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
        ],
      ),
    );
  }
}

/// Individual language option in the dialog
class _LanguageOption extends StatelessWidget {
  final String languageName;
  final String languageCode;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.languageName,
    required this.languageCode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacing16,
            vertical: AppSizes.spacing12,
          ),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppColors.vibrantPurple.withValues(alpha: 0.2)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(
              color:
                  isSelected ? AppColors.vibrantPurple : AppColors.white(0.1),
            ),
          ),
          child: Row(
            children: [
              Text(
                languageName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected
                          ? AppColors.vibrantPurple
                          : theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.vibrantPurple,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
