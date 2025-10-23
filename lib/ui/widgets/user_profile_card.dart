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
      padding: const EdgeInsets.all(AppSizes.spacing20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
        border: Border.all(color: AppColors.white(0.06)),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.spacing4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.black(0.65),
                    border: Border.all(
                      color: AppColors.white(0.12),
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
                    letterSpacing: 0.2,
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
                const SizedBox(height: AppSizes.spacing8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacing6),
                    Text(
                      isVerified ? verifiedLabel : unverifiedLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
