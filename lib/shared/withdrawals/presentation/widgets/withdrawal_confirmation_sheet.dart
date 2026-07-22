import 'package:flutter/material.dart';

class WithdrawalConfirmationSheet extends StatelessWidget {
  const WithdrawalConfirmationSheet({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: onConfirm,
          child: const Text('Confirm withdrawal'),
        ),
      ),
    );
  }
}
