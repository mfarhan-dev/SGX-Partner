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
                icon: Icons.account_balance_wallet_outlined,
                label: 'Wallet',
                route: '/mechanic/wallet',
              ),
              _MechanicNavItem(
                icon: Icons.person_outline,
                label: 'Profile',
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
    return Expanded(
      child: InkWell(
        onTap: () => context.go(route),
        child: SizedBox(
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? Theme.of(context).colorScheme.primary : null,
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
