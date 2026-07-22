import 'package:flutter/material.dart';

class WithdrawalStatusPanel extends StatelessWidget {
  const WithdrawalStatusPanel({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(status, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
