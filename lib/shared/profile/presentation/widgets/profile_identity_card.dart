import 'package:flutter/material.dart';

class ProfileIdentityCard extends StatelessWidget {
  const ProfileIdentityCard({
    super.key,
    required this.name,
    required this.phoneNumber,
    required this.roleLabel,
  });

  final String name;
  final String phoneNumber;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
        title: Text(name),
        subtitle: Text('$phoneNumber • $roleLabel'),
      ),
    );
  }
}
