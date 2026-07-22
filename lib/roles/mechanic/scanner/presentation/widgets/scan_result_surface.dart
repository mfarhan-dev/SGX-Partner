import 'package:flutter/material.dart';

class ScanResultSurface extends StatelessWidget {
  const ScanResultSurface({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(title: Text(message)));
  }
}
