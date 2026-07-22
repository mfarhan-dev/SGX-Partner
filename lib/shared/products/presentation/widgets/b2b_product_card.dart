import 'package:flutter/material.dart';

class B2bProductCard extends StatelessWidget {
  const B2bProductCard({
    super.key,
    required this.name,
    required this.brand,
    required this.category,
    this.onTap,
  });

  final String name;
  final String brand;
  final String category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text('$brand • $category'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
