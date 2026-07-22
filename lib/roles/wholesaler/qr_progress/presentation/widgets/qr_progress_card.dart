import 'package:flutter/material.dart';

class QrProgressCard extends StatelessWidget {
  const QrProgressCard({
    super.key,
    required this.title,
    required this.scanned,
    required this.total,
  });

  final String title;
  final int scanned;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text('$scanned of $total scanned'),
      ),
    );
  }
}
