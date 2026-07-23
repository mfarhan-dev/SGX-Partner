import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MechanicShell extends StatelessWidget {
  const MechanicShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox.square(
        dimension: 64,
        child: FloatingActionButton(
          heroTag: null,
          tooltip: 'Scan QR',
          onPressed: () => context.go('/mechanic/scan'),
          child: const Icon(Icons.qr_code_scanner),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 8,
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MechanicNavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                route: '/mechanic/home',
              ),
              _MechanicNavItem(
                icon: Icons.inventory_2_outlined,
                label: 'Products',
                route: '/products',
              ),
              const SizedBox(width: 64),
              _MechanicNavItem(
                icon: Icons.receipt_long_outlined,
                label: 'Activity',
                route: '/mechanic/wallet',
              ),
              _MechanicNavItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                route: '/mechanic/profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MechanicNavItem extends StatelessWidget {
  const _MechanicNavItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    final selected = GoRouterState.of(context).uri.path == route;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.go(route),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            height: 44,
            width: double.infinity,
            decoration: BoxDecoration(
              color: selected
                  ? colorScheme.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 1),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    height: 1,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
