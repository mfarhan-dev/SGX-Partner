import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import 'sgx_app_bar.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    this.description,
    this.primaryAction,
  });

  final String title;
  final String? description;
  final Widget? primaryAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SgxAppBar(title: title),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description ?? 'Mock implementation placeholder.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (primaryAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              primaryAction!,
            ],
          ],
        ),
      ),
    );
  }
}
