import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.accountSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
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
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
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
    final color = danger ? Colors.redAccent : theme.colorScheme.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
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
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      ),
    );
  }
}
