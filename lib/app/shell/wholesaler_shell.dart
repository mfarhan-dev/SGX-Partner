import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WholesalerShell extends StatelessWidget {
  const WholesalerShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final selectedIndex = switch (path) {
      '/wholesaler/qr-progress' => 1,
      '/wholesaler/wallet' => 2,
      '/products' => 3,
      '/wholesaler/profile' => 4,
      _ => 0,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          final route = switch (index) {
            1 => '/wholesaler/qr-progress',
            2 => '/wholesaler/wallet',
            3 => '/products',
            4 => '/wholesaler/profile',
            _ => '/wholesaler/home',
          };
          context.go(route);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.qr_code_2_outlined),
            label: 'QR Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
