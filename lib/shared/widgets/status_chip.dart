import 'package:flutter/material.dart';

import '../models/status_presentation.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final StatusPresentation status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status.tone) {
      StatusTone.primary => Theme.of(context).colorScheme.primary,
      StatusTone.success => Colors.green.shade700,
      StatusTone.warning => Colors.orange.shade800,
      StatusTone.error => Theme.of(context).colorScheme.error,
      StatusTone.neutral => Theme.of(context).colorScheme.outline,
    };

    return Chip(
      avatar: status.icon == null ? null : Icon(status.icon, size: 16),
      label: Text(status.label),
      side: BorderSide(color: color),
    );
  }
}
