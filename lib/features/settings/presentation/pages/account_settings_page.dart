import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';
import 'package:money_tracker/core/utils/haptic_feedback.dart';
import 'package:money_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:money_tracker/ui/widgets/glow_blob.dart';

class AccountSettingsPage extends ConsumerWidget {
  const AccountSettingsPage({super.key});

  void _showToast(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.vibrantPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AppLocalizations t) async {
    await HapticFeedbackHelper.mediumImpact();
    if (!context.mounted) return;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteAccount),
        content: Text(t.confirmDeleteAccountMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: Text(t.delete),
          ),
        ],
      ),
    );

    if (!context.mounted) return;

    if (shouldDelete == true) {
      await HapticFeedbackHelper.error();
      if (!context.mounted) return;
      _showToast(context, t.comingSoonDeleteAccount);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final user = ref.watch(currentAuthUserProvider);
    final email = user?.email ?? 'anonymous@finoro.app';
    final displayName =
        (user?.displayName?.trim().isNotEmpty ?? false)
            ? user!.displayName!.trim()
            : email.split('@').first;
    final isVerified = user?.isEmailVerified ?? false;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D0E12), Color(0xFF181A23)],
              ),
            ),
          ),
          GlowBlob.purpleBlue(size: 280, left: -100, top: -140),
          GlowBlob.purpleCyan(size: 320, right: -120, bottom: -160),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.spacing24,
                AppSizes.spacing16,
                AppSizes.spacing24,
                AppSizes.spacing32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          HapticFeedbackHelper.lightImpact();
                          context.pop();
                        },
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: AppSizes.spacing12),
                      Text(
                        t.accountSettings,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacing20),
                  _AccountOverviewCard(
                    displayName: displayName,
                    email: email,
                    isVerified: isVerified,
                    verifiedLabel: t.statusVerified,
                  ),
                  const SizedBox(height: AppSizes.spacing28),
                  _SettingsSection(
                    title: t.accountSectionTitle.toUpperCase(),
                    items: [
                      _ActionTileData(
                        icon: Icons.lock_reset_rounded,
                        label: t.changePassword,
                        onTap: () {
                          HapticFeedbackHelper.lightImpact();
                          _showToast(context, t.comingSoonChangePassword);
                        },
                      ),
                      _ActionTileData(
                        icon: Icons.devices_other_rounded,
                        label: t.manageSignIn,
                        onTap: () {
                          HapticFeedbackHelper.lightImpact();
                          _showToast(context, t.comingSoonManageSignIn);
                        },
                      ),
                      _ActionTileData(
                        icon: Icons.delete_forever_rounded,
                        label: t.deleteAccount,
                        isDanger: true,
                        onTap: () => _confirmDelete(context, t),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountOverviewCard extends StatelessWidget {
  final String displayName;
  final String email;
  final bool isVerified;
  final String verifiedLabel;

  const _AccountOverviewCard({
    required this.displayName,
    required this.email,
    required this.isVerified,
    required this.verifiedLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = isVerified ? Colors.greenAccent : Colors.orangeAccent;
    final statusIcon = isVerified ? Icons.verified_rounded : Icons.error_outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.spacing24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(AppSizes.radiusXXLarge),
        border: Border.all(color: AppColors.white(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.vibrantPurple.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: AppSizes.spacing20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing6),
                    Text(
                      email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing20),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSizes.spacing10,
              horizontal: AppSizes.spacing14,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: AppSizes.spacing8),
                Text(
                  verifiedLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
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

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_ActionTileData> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: AppSizes.spacing16),
        ...items.map((item) => _SettingsActionTile(data: item)),
      ],
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  final _ActionTileData data;

  const _SettingsActionTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = data.isDanger
        ? const Color(0xFF2B1719)
        : AppColors.cardBackground.withValues(alpha: 0.72);
    final borderColor = data.isDanger
        ? Colors.redAccent.withValues(alpha: 0.3)
        : AppColors.white(0.06);
    final iconColor = data.isDanger ? Colors.redAccent : AppColors.vibrantPurple;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing14),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusXXLarge),
        onTap: data.onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppSizes.radiusXXLarge),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spacing20,
              AppSizes.spacing18,
              AppSizes.spacing18,
              AppSizes.spacing18,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: data.isDanger
                        ? const LinearGradient(
                          colors: [Color(0xFF7B1E28), Color(0xFFB9383E)],
                        )
                        : AppColors.primaryGradient,
                  ),
                  child: Icon(data.icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: AppSizes.spacing16),
                Expanded(
                  child: Text(
                    data.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: iconColor.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionTileData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  const _ActionTileData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });
}
