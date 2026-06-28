import 'package:flutter/material.dart';

import '../core/localization/app_localizations.dart';
import '../core/routing/app_routes.dart';
import '../core/theme/app_tokens.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.currentIndex, required this.child});

  final int currentIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      _ShellItem(l10n.home, Icons.home_outlined, Icons.home, AppRoutes.home),
      _ShellItem(
        l10n.files,
        Icons.folder_outlined,
        Icons.folder,
        AppRoutes.files,
      ),
      _ShellItem(
        l10n.tools,
        Icons.grid_view_rounded,
        Icons.grid_view,
        AppRoutes.tools,
      ),
      _ShellItem(
        l10n.account,
        Icons.person_outline_rounded,
        Icons.person_rounded,
        AppRoutes.account,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Padding(padding: const EdgeInsets.only(bottom: 96), child: child),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.large,
                  boxShadow: AppShadows.card,
                ),
                child: Row(
                  children: [
                    _NavButton(item: items[0], selected: currentIndex == 0),
                    _NavButton(item: items[1], selected: currentIndex == 1),
                    const SizedBox(width: 64),
                    _NavButton(item: items[2], selected: currentIndex == 2),
                    _NavButton(item: items[3], selected: currentIndex == 3),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.only(bottom: 38),
              child: FloatingActionButton(
                heroTag: 'scan-action',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.scanner),
                backgroundColor: AppColors.interactive,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(Icons.add_rounded, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected});

  final _ShellItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.interactive : AppColors.muted;
    return Expanded(
      child: InkWell(
        borderRadius: AppRadii.medium,
        onTap: () => Navigator.of(context).pushReplacementNamed(item.route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? item.selectedIcon : item.icon, color: color),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellItem {
  const _ShellItem(this.label, this.icon, this.selectedIcon, this.route);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
}
