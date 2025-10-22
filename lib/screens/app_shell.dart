import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker/core/utils/haptic_feedback.dart';
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';

/// Shell that hosts the main authenticated tabs.
class AppShell extends StatefulWidget {
  final Widget child; // The active tab content (from GoRouter's ShellRoute).
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // Keep ordered list of tab routes.
  static const _tabs = [
    _TabInfo(
      path: '/dashboard',
      icon: Icons.home_rounded,
      labelKey: 'tabDashboard',
    ),
    _TabInfo(
      path: '/expenses',
      icon: Icons.credit_card_rounded,
      labelKey: 'tabExpenses',
    ),
    _TabInfo(
      path: '/history',
      icon: Icons.insights_rounded,
      labelKey: 'tabHistory',
    ),
    _TabInfo(
      path: '/settings',
      icon: Icons.settings_rounded,
      labelKey: 'tabSettings',
    ),
  ];

  int _indexFromLocation(String location) {
    final matchIndex = _tabs.indexWhere((t) => location.startsWith(t.path));
    return matchIndex == -1 ? 0 : matchIndex;
  }

  void _onTap(int index) async {
    await HapticFeedbackHelper.lightImpact();
    final tab = _tabs[index];
    if (GoRouter.of(context).canPop()) {
      // Popping to root of current branch ensures expected back behavior.
      GoRouter.of(context).pop();
    }
    GoRouter.of(context).go(tab.path);
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final selectedIndex = _indexFromLocation(loc);
    final t = AppLocalizations.of(context)!;

    final media = MediaQuery.of(context);
    final topSafe = media.padding.top; // dynamic island / status bar padding

    return Scaffold(
      extendBody: false,
      body: Padding(
        padding: EdgeInsets.only(top: topSafe + 4),
        child: widget.child,
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: selectedIndex,
        onTap: _onTap,
        labels: [t.tabDashboard, t.tabExpenses, t.tabHistory, t.tabSettings],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;
  final List<String> labels;
  const _BottomNavBar({
    required this.selectedIndex,
    required this.onTap,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: AppSizes.spacing12,
        right: AppSizes.spacing12,
        top: AppSizes.spacing8,
        bottom: (bottomPadding > 0 ? bottomPadding : AppSizes.spacing8),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.darkSecondary.withValues(alpha: 0.95),
            AppColors.navBarBackground.withValues(alpha: 0.98),
          ],
        ),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: .04), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BottomItem(
            index: 0,
            selectedIndex: selectedIndex,
            onTap: onTap,
            icon: Icons.home_rounded,
            inactiveIcon: Icons.home_outlined,
            label: labels[0],
            activeColor: AppColors.deepPurple,
          ),
          _BottomItem(
            index: 1,
            selectedIndex: selectedIndex,
            onTap: onTap,
            icon: Icons.credit_card_rounded,
            inactiveIcon: Icons.credit_card_outlined,
            label: labels[1],
            activeColor: AppColors.deepPurple,
          ),
          _BottomItem(
            index: 2,
            selectedIndex: selectedIndex,
            onTap: onTap,
            icon: Icons.insights_rounded,
            inactiveIcon: Icons.insights_outlined,
            label: labels[2],
            activeColor: AppColors.deepPurple,
          ),
          _BottomItem(
            index: 3,
            selectedIndex: selectedIndex,
            onTap: onTap,
            icon: Icons.settings_rounded,
            inactiveIcon: Icons.settings_outlined,
            label: labels[3],
            activeColor: AppColors.deepPurple,
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final void Function(int) onTap;
  final IconData icon;
  final IconData inactiveIcon;
  final String label;
  final Color activeColor;
  const _BottomItem({
    required this.index,
    required this.selectedIndex,
    required this.onTap,
    required this.icon,
    required this.inactiveIcon,
    required this.label,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final selected = index == selectedIndex;
    final theme = Theme.of(context); // used for base colors in items
    final baseColor = theme.colorScheme.onSurface.withValues(alpha: .75);
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            vertical: AppSizes.spacing6,
            horizontal: selected ? AppSizes.spacing12 : AppSizes.spacing4,
          ),
          decoration:
              selected
                  ? BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        activeColor.withValues(alpha: .25),
                        activeColor.withValues(alpha: .15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    border: Border.all(
                      color: activeColor.withValues(alpha: .3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: .2),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  )
                  : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? icon : inactiveIcon,
                size: AppSizes.iconMedium,
                color:
                    selected ? Colors.white : baseColor.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                style: theme.textTheme.labelSmall!.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? Colors.white : baseColor,
                  letterSpacing: .1,
                ),
                child: Text(label, maxLines: 1, overflow: TextOverflow.fade),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabInfo {
  final String path;
  final IconData icon;
  final String labelKey; // Kept for potential dynamic mapping.
  const _TabInfo({
    required this.path,
    required this.icon,
    required this.labelKey,
  });
}
