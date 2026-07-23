import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/mock/sgx_mock_data.dart';
import '../../../../shared/widgets/sgx_screen.dart';

class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SgxScreen(
      title: 'Scan History',
      showBack: true,
      showNotifications: false,
      children: [
        Card(
          color: AppColors.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryValue(label: 'Total scans', value: '124'),
                ),
                Expanded(
                  child: _SummaryValue(
                    label: 'Earned from scans',
                    value: 'Rs. 28,540',
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('TODAY', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        ...mockScans.map(
          (scan) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(child: Icon(scan.icon)),
            title: Text(scan.productName),
            subtitle: Text('${scan.time} · ${scan.shopName}'),
            trailing: Text(
              '+${MoneyFormatter.format(scan.reward)}',
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
