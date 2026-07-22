import 'package:flutter/material.dart';

enum StatusTone { primary, success, warning, error, neutral }

class StatusPresentation {
  const StatusPresentation({
    required this.label,
    required this.tone,
    this.icon,
  });

  final String label;
  final StatusTone tone;
  final IconData? icon;
}
