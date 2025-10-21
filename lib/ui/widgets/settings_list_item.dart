import 'package:flutter/material.dart';
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';

/// Settings list item with glass-morphism styling
class SettingsListItem extends StatelessWidget {
  const SettingsListItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing10),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.glassBackground.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(color: AppColors.white(0.06)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacing16,
              vertical: AppSizes.spacing14,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient.scale(0.7),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: AppSizes.spacing14),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
