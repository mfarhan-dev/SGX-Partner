import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/sgx_app_bar.dart';
import '../data/wholesaler_qr_progress_providers.dart';
import '../domain/qr_progress_models.dart';
import 'widgets/qr_progress_card.dart';
import 'widgets/qr_progress_screen_skeleton.dart';

class QrProgressScreen extends ConsumerWidget {
  const QrProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(wholesalerQrProgressProvider);

    // Real, session-cached data (see the provider file) can go stale
    // the moment a mechanic scans a code tied to this wholesaler's
    // invoice, from entirely outside this app -- same reasoning as the
    // khata ledger and mechanic Activity screens, and the same fix:
    // pull-to-refresh actually has to invalidate and refetch.
    Future<void> refresh() async {
      ref.invalidate(wholesalerQrProgressProvider);
      await ref.read(wholesalerQrProgressProvider.future);
    }

    return Scaffold(
      appBar: const SgxAppBar(title: 'QR Progress'),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refresh,
          child: batchesAsync.when(
            data: (batches) => _content(context, batches),
            loading: () => ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: const [QrProgressScreenSkeleton()],
            ),
            error: (error, stackTrace) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xl,
              ),
              children: [
                Center(
                  child: Text(
                    'Could not load QR progress. Pull to refresh or try again later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.mutedTextOf(context)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, List<QrProgressBatch> batches) {
    final total = batches.fold<int>(0, (sum, batch) => sum + batch.total);
    final scanned = batches.fold<int>(0, (sum, batch) => sum + batch.scanned);
    final remaining = total - scanned;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Card(
          color: AppColors.surfaceContainerOf(context),
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
                LinearProgressIndicator(
                  value: total == 0 ? 0 : scanned / total,
                  minHeight: 10,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text('Pull down to refresh'),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (batches.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(
              child: Text(
                'No dispatched invoices with QR codes yet.',
                style: TextStyle(color: AppColors.mutedTextOf(context)),
              ),
            ),
          )
        else
          ...batches.map((batch) => QrProgressCard(batch: batch)),
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
