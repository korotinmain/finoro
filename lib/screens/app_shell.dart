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

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: _onTap,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: t.tabDashboard,
            ),
            NavigationDestination(
              icon: const Icon(Icons.credit_card_outlined),
              selectedIcon: const Icon(Icons.credit_card_rounded),
              label: t.tabExpenses,
            ),
            NavigationDestination(
              icon: const Icon(Icons.history_outlined),
              selectedIcon: const Icon(Icons.history_rounded),
              label: t.tabHistory,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings_rounded),
              label: t.tabSettings,
            ),
          ],
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
