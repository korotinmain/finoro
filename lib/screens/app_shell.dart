import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

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
      icon: Icons.history_rounded,
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

  void _onTap(int index) {
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
      extendBody: true,
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
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF121317).withValues(alpha: .95),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: .05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .45),
              blurRadius: 24,
              offset: const Offset(0, 12),
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
              activeColor: const Color(0xFF7D48FF),
            ),
            _BottomItem(
              index: 1,
              selectedIndex: selectedIndex,
              onTap: onTap,
              icon: Icons.credit_card_rounded,
              inactiveIcon: Icons.credit_card_outlined,
              label: labels[1],
              activeColor: const Color(0xFF7D48FF),
            ),
            _BottomItem(
              index: 2,
              selectedIndex: selectedIndex,
              onTap: onTap,
              icon: Icons.history_rounded,
              inactiveIcon: Icons.history_outlined,
              label: labels[2],
              activeColor: const Color(0xFF7D48FF),
            ),
            _BottomItem(
              index: 3,
              selectedIndex: selectedIndex,
              onTap: onTap,
              icon: Icons.settings_rounded,
              inactiveIcon: Icons.settings_outlined,
              label: labels[3],
              activeColor: const Color(0xFF7D48FF),
            ),
          ],
        ),
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
        borderRadius: BorderRadius.circular(22),
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: selected ? 14 : 0,
          ),
          decoration:
              selected
                  ? BoxDecoration(
                    color: activeColor.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(22),
                  )
                  : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? icon : inactiveIcon,
                size: 24,
                color: selected ? activeColor : baseColor,
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                style: theme.textTheme.labelMedium!.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? Colors.white : baseColor,
                  letterSpacing: .2,
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
