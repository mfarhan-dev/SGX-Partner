import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../widgets/sgx_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const notifications = [
      (
        icon: Icons.add_circle_outline,
        tone: AppColors.success,
        title: 'QR reward added',
        body: 'Rs. 15 was added to your wallet.',
        time: '2 mins ago',
        unread: true,
      ),
      (
        icon: Icons.send_outlined,
        tone: AppColors.primary,
        title: 'Payment sent',
        body: 'Please confirm your JazzCash withdrawal.',
        time: 'Today',
        unread: true,
      ),
      (
        icon: Icons.campaign_outlined,
        tone: AppColors.warning,
        title: 'New campaign active',
        body: 'Double reward on Shell products is now active.',
        time: 'Yesterday',
        unread: false,
      ),
    ];

    return SgxScreen(
      title: 'Notifications',
      showBack: true,
      showNotifications: false,
      children: [
        for (final item in notifications)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: item.unread
                  ? AppColors.primary.withValues(alpha: 0.04)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: item.tone.withValues(alpha: 0.12),
                child: Icon(item.icon, color: item.tone),
              ),
              title: Text(
                item.title,
                style: TextStyle(
                  fontWeight: item.unread ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
              subtitle: Text('${item.body}\n${item.time}'),
              isThreeLine: true,
              trailing: item.unread
                  ? const Icon(Icons.circle, size: 8, color: AppColors.primary)
                  : null,
            ),
          ),
      ],
    );
  }
}
