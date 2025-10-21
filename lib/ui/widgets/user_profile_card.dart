import 'package:flutter/material.dart';
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';

/// User profile card widget with avatar and verification badge
class UserProfileCard extends StatelessWidget {
  const UserProfileCard({
    super.key,
    required this.displayName,
    required this.email,
    required this.isVerified,
    required this.verifiedLabel,
    required this.unverifiedLabel,
  });

  final String displayName;
  final String email;
  final bool isVerified;
  final String verifiedLabel;
  final String unverifiedLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor =
        isVerified ? AppColors.statusVerified : AppColors.statusUnverified;
    final badgeIcon = isVerified ? Icons.verified_rounded : Icons.error_outline;
    final badgeColor =
        isVerified ? AppColors.badgeVerified : AppColors.badgeUnverified;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacing20,
        AppSizes.cardPaddingV,
        AppSizes.spacing20,
        AppSizes.spacing20,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
        border: Border.all(color: AppColors.white(0.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: AppSizes.avatarMedium,
                height: AppSizes.avatarMedium,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: AppSizes.iconLarge,
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.spacing4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.black(0.65),
                    border: Border.all(
                      color: AppColors.white(0.12),
                      width: AppSizes.borderThin,
                    ),
                  ),
                  child: Icon(
                    badgeIcon,
                    size: AppSizes.iconSmall,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing14),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: AppSizes.spacing6),
          Text(
            email,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSizes.spacing12),
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
              const SizedBox(width: AppSizes.spacing8),
              Text(
                isVerified ? verifiedLabel : unverifiedLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
