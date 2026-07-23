import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/sgx_screen.dart';

class EditMechanicProfileScreen extends StatelessWidget {
  const EditMechanicProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SgxScreen(
      title: 'Edit Profile',
      showBack: true,
      showNotifications: false,
      children: [
        const Center(child: CircleAvatar(radius: 48, child: Text('MF'))),
        const SizedBox(height: AppSpacing.lg),
        const TextField(
          enabled: false,
          decoration: InputDecoration(
            labelText: 'Verified Phone',
            prefixIcon: Icon(Icons.check_circle_outline),
            suffixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const TextField(decoration: InputDecoration(labelText: 'Full Name *')),
        const SizedBox(height: AppSpacing.sm),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Workshop / Shop Name (optional)',
            helperText: 'Optional — helps customers recognize your shop.',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const TextField(
          decoration: InputDecoration(labelText: 'Area / City *'),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => context.go('/mechanic/profile'),
                icon: const Icon(Icons.check),
                label: const Text('Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
