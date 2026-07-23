import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/mock/sgx_mock_data.dart';
import '../../../../shared/widgets/sgx_screen.dart';

class QrProgressScreen extends StatelessWidget {
  const QrProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final total = mockQrProgress.fold<int>(0, (sum, item) => sum + item.total);
    final scanned = mockQrProgress.fold<int>(
      0,
      (sum, item) => sum + item.scanned,
    );
    final remaining = total - scanned;

    return SgxScreen(
      title: 'QR Progress',
      showNotifications: true,
      children: [
        Card(
          color: AppColors.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OVERALL PROGRESS',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _Stat(label: 'Total', value: '$total'),
                    ),
                    Expanded(
                      child: _Stat(
                        label: 'Scanned',
                        value: '$scanned',
                        color: AppColors.primary,
                      ),
                    ),
                    Expanded(
                      child: _Stat(label: 'Remaining', value: '$remaining'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                LinearProgressIndicator(value: scanned / total, minHeight: 10),
                const SizedBox(height: AppSpacing.sm),
                const Text('Updated just now · Pull down to refresh'),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...mockQrProgress.map((item) => _QrProgressCard(item: item)),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _QrProgressCard extends StatelessWidget {
  const _QrProgressCard({required this.item});

  final MockQrProgress item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(child: Icon(item.icon)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        item.reference,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Chip(label: Text(item.remaining == 0 ? 'Complete' : 'Active')),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text(
                  '${item.scanned} scanned',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text('${item.remaining} remaining'),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(value: item.progress, minHeight: 8),
            const Divider(height: AppSpacing.lg),
            Row(
              children: [
                const Text('Earned from this batch'),
                const Spacer(),
                Text(
                  MoneyFormatter.format(item.earned),
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
