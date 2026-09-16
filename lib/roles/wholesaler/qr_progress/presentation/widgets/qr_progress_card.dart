import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/utils/money_formatter.dart';
import '../../../../../shared/models/money_amount.dart';
import '../../domain/qr_progress_models.dart';

class QrProgressCard extends StatelessWidget {
  const QrProgressCard({super.key, required this.batch});

  final QrProgressBatch batch;

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
                const CircleAvatar(child: Icon(Icons.qr_code_2_outlined)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        batch.productName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        batch.invoiceNumber,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Chip(label: Text(batch.remaining == 0 ? 'Complete' : 'Active')),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text(
                  '${batch.scanned} scanned',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text('${batch.remaining} remaining'),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(value: batch.progress, minHeight: 8),
            const Divider(height: AppSpacing.lg),
            Row(
              children: [
                const Text('Earned from this batch'),
                const Spacer(),
                Text(
                  MoneyFormatter.format(MoneyAmount(cents: batch.earned * 100)),
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
