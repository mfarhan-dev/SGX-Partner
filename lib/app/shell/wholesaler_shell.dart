import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WholesalerShell extends StatelessWidget {
  const WholesalerShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomAppBar(
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _WholesalerNavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                route: '/wholesaler/home',
              ),
              _WholesalerNavItem(
                icon: Icons.qr_code_2_outlined,
                label: 'QR Progress',
                route: '/wholesaler/qr-progress',
              ),
              _WholesalerNavItem(
                icon: Icons.receipt_long_outlined,
                label: 'Activity',
                route: '/wholesaler/wallet',
              ),
              _WholesalerNavItem(
                icon: Icons.inventory_2_outlined,
                label: 'Products',
                route: '/products',
              ),
              _WholesalerNavItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                route: '/wholesaler/profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WholesalerNavItem extends StatelessWidget {
  const _WholesalerNavItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  bool _isSelected(String path) {
    if (path == route || path.startsWith('$route/')) return true;
    if (route == '/wholesaler/wallet') {
      return path.startsWith('/wholesaler/withdrawals');
    }
    if (route == '/products') return path.startsWith('/products');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final selected = _isSelected(path);
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
