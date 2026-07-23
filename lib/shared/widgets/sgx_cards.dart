import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/money_formatter.dart';
import '../mock/sgx_mock_data.dart';
import '../models/money_amount.dart';

class WalletHeroCard extends StatelessWidget {
  const WalletHeroCard({
    super.key,
    required this.available,
    required this.pending,
    required this.lifetime,
    required this.onWithdraw,
    this.compact = false,
  });

  final MoneyAmount available;
  final MoneyAmount pending;
  final MoneyAmount lifetime;
  final VoidCallback onWithdraw;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF172554)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -12,
            top: -16,
            child: Icon(
              Icons.account_balance_wallet,
              color: Color(0x18FFFFFF),
              size: 150,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 22,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Available Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                MoneyFormatter.format(available),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 38 : 44,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _GlassValue(
                      label: 'PENDING',
                      value: MoneyFormatter.format(pending),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _GlassValue(
                      label: 'LIFETIME',
                      value: MoneyFormatter.format(lifetime),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: onWithdraw,
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Withdraw Money'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassValue extends StatelessWidget {
  const _GlassValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product});

  final MockProduct product;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.go('/products/${product.id}'),
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Icon(
                product.icon,
                size: 46,
                color: AppColors.primary.withValues(alpha: 0.78),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(height: 1.25),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.code,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedText,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CampaignTile extends StatelessWidget {
  const CampaignTile({super.key, required this.campaign});

  final MockCampaign campaign;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.go('/campaigns/${campaign.id}'),
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 130,
              decoration: BoxDecoration(
                color: campaign.tone.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(campaign.icon, size: 56, color: campaign.tone),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _MiniPill(label: 'ACTIVE', color: AppColors.success),
                      const Spacer(),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    campaign.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    campaign.dateWindow,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionRow extends StatelessWidget {
  const TransactionRow({super.key, required this.transaction});

  final MockTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final positive = transaction.amount.cents >= 0;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: transaction.tone.withValues(alpha: 0.13),
        child: Icon(transaction.icon, color: transaction.tone),
      ),
      title: Text(transaction.title),
      subtitle: Text(transaction.subtitle),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            MoneyFormatter.format(transaction.amount),
            style: TextStyle(
              color: positive ? AppColors.success : AppColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (transaction.status != null)
            Text(
              transaction.status!,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: transaction.tone),
            ),
        ],
      ),
    );
  }
}

class WithdrawalStatusCard extends StatelessWidget {
  const WithdrawalStatusCard({
    super.key,
    required this.withdrawal,
    required this.routePrefix,
    required this.availableBalance,
  });

  final MockWithdrawal withdrawal;
  final String routePrefix;
  final MoneyAmount availableBalance;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(withdrawal.status);
    final paymentSent = withdrawal.status == 'Payment Sent';
    final completed = withdrawal.status == 'Confirmed';
    final title = switch (withdrawal.status) {
      'Payment Sent' => 'Payment sent by SGX',
      'Confirmed' => 'Withdrawal completed',
      'Disputed' => 'Withdrawal needs review',
      _ => 'Withdrawal requested',
    };
    final statusLabel = paymentSent ? 'Confirm' : withdrawal.status;
    final remaining = MoneyAmount(
      cents: (availableBalance.cents - withdrawal.amount.cents).clamp(
        0,
        availableBalance.cents,
      ),
    );

    return Card(
      margin: EdgeInsets.zero,
      color: paymentSent || completed ? null : AppColors.warningContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('$routePrefix/${withdrawal.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.13),
                    child: Icon(_statusIcon(withdrawal.status), color: color),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            _MiniPill(label: statusLabel, color: color),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${MoneyFormatter.format(withdrawal.amount)} · ${withdrawal.method} · ${withdrawal.date}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.mutedText),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _WithdrawalAmountBox(
                      label: paymentSent ? 'Withdrawn' : 'Requested',
                      value: MoneyFormatter.format(withdrawal.amount),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _WithdrawalAmountBox(
                      label: paymentSent ? 'Left to withdraw' : 'Available',
                      value: MoneyFormatter.format(
                        paymentSent ? remaining : availableBalance,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                paymentSent
                    ? 'Confirm only after the amount is received.'
                    : withdrawal.note,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
              ),
              if (paymentSent) ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () =>
                        context.go('$routePrefix/${withdrawal.id}'),
                    child: const Text('Confirm received'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _statusIcon(String status) {
    return switch (status) {
      'Payment Sent' => Icons.send_outlined,
      'Confirmed' => Icons.check_circle_outline,
      'Disputed' => Icons.error_outline,
      _ => Icons.schedule_outlined,
    };
  }

  Color _statusColor(String status) {
    return switch (status) {
      'Confirmed' || 'Refunded' => AppColors.success,
      'Disputed' => AppColors.error,
      'Payment Sent' => AppColors.primary,
      _ => AppColors.warning,
    };
  }
}

class _WithdrawalAmountBox extends StatelessWidget {
  const _WithdrawalAmountBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.mutedText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class WithdrawalCard extends StatelessWidget {
  const WithdrawalCard({
    super.key,
    required this.withdrawal,
    required this.routePrefix,
  });

  final MockWithdrawal withdrawal;
  final String routePrefix;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => context.go('$routePrefix/${withdrawal.id}'),
        leading: const CircleAvatar(child: Icon(Icons.payments_outlined)),
        title: Text(MoneyFormatter.format(withdrawal.amount)),
        subtitle: Text(
          '${withdrawal.method} · ${withdrawal.date}\n${withdrawal.note}',
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MiniPill(
              label: withdrawal.status,
              color: _statusColor(withdrawal.status),
            ),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'Confirmed' || 'Refunded' => AppColors.success,
      'Disputed' => AppColors.error,
      'Payment Sent' => AppColors.primary,
      _ => AppColors.warning,
    };
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
