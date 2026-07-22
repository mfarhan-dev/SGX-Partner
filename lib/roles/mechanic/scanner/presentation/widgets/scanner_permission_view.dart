import 'package:flutter/material.dart';

class ScannerPermissionView extends StatelessWidget {
  const ScannerPermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Camera permission is required to scan QR codes.'),
    );
  }
}
