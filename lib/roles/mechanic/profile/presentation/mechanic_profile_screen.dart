import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/sgx_screen.dart';

class MechanicProfileScreen extends StatelessWidget {
  const MechanicProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SgxScreen(
      title: 'Settings',
      showNotifications: false,
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
              CircleAvatar(radius: 32, child: Text('MF')),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Muhammad Farhan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Farhan Workshop · Lahore',
                      style: TextStyle(color: Colors.white70),
                    ),
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
                title: Text('Verified Phone'),
                subtitle: Text('0300-1234567'),
                trailing: Icon(Icons.lock_outline),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.storefront),
                title: Text('Workshop'),
                subtitle: Text('Farhan Workshop'),
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
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/mechanic/profile/edit'),
              ),
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
