import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/sgx_screen.dart';

class WholesalerProfileScreen extends StatelessWidget {
  const WholesalerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SgxScreen(
      title: 'Profile',
      showNotifications: true,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF172554)],
            ),
          ),
          child: const Row(
            children: [
              CircleAvatar(radius: 32, child: Text('FM')),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farhan Motor Parts',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Muhammad Farhan · Lahore',
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 6),
                    Chip(label: Text('ACTIVE WHOLESALER')),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.smartphone),
                title: Text('Registered Phone'),
                subtitle: Text('0300-1234567'),
                trailing: Icon(Icons.lock_outline),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.storefront),
                title: Text('Shop Name'),
                subtitle: Text('Farhan Motor Parts'),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text('Area / City'),
                subtitle: Text('Lahore'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language & Theme'),
                subtitle: const Text('English · Light'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/profile/preferences'),
              ),
              const ListTile(
                leading: Icon(Icons.support_agent),
                title: Text('Contact SGX'),
                subtitle: Text('WhatsApp: 0300-8880000'),
                trailing: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
          onPressed: () => context.go('/auth/phone'),
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
        const SizedBox(height: AppSpacing.md),
        const Center(child: Text('SGX Partners · v1.0.0')),
      ],
    );
  }
}
