import 'package:flutter/material.dart';

/// Photo if there is one, otherwise initials from the name -- the same
/// fallback already used on the Settings header, pulled out here so
/// Home's greeting can show the exact same thing instead of drifting
/// out of sync with its own copy of this logic.
class PartnerAvatar extends StatelessWidget {
  const PartnerAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 20,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String name;
  final String? photoUrl;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
      child: photoUrl == null
          ? Text(
              initials.isEmpty ? '?' : initials,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w800,
              ),
            )
          : null,
    );
  }
}
