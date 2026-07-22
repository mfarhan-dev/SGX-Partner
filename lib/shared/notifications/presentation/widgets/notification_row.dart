import 'package:flutter/material.dart';

class NotificationRow extends StatelessWidget {
  const NotificationRow({
    super.key,
    required this.title,
    required this.body,
    this.onTap,
  });

  final String title;
  final String body;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.notifications_outlined),
      title: Text(title),
      subtitle: Text(body),
      onTap: onTap,
    );
  }
}
