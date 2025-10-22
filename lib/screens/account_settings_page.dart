import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.accountSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.spacing20,
          AppSizes.spacing12,
          AppSizes.spacing20,
          AppSizes.spacing40,
        ),
        children: [
          _SectionHeader(label: t.accountSectionTitle, icon: Icons.person),
          _SettingsTile(
            label: t.changePassword,
            onTap: () {
              // TODO: implement change password flow
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${t.changePassword} – TODO')),
              );
            },
          ),
          _SettingsTile(
            label: t.manageSignIn,
            onTap: () {
              // TODO: implement manage sign in methods
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${t.manageSignIn} – TODO')),
              );
            },
          ),
          _SettingsTile(
            label: t.deleteAccount,
            danger: true,
            onTap: () {
              // TODO: implement delete account
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${t.deleteAccount} – TODO')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacing4,
        AppSizes.spacing16,
        AppSizes.spacing4,
        AppSizes.spacing8,
      ),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconSmall, color: AppColors.vibrantPurple),
          const SizedBox(width: AppSizes.spacing8),
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: .2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _SettingsTile({
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = danger ? Colors.redAccent : AppColors.vibrantPurple;
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.spacing14,
          horizontal: AppSizes.spacing8,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: color,
              size: AppSizes.iconMedium,
            ),
          ],
        ),
      ),
    );
  }
}
