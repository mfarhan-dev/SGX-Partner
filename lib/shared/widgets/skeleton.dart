import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// A soft pulsing grey block, shaped like the real content it stands
/// in for -- the loading-state convention most real apps use (Google
/// apps, WhatsApp) instead of a bare spinner, because it shows the
/// shape of what's coming instead of leaving a blank/dashed screen
/// that reads as broken.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);
  late final _opacity = Tween<double>(
    begin: 0.45,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.outlineOf(context),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}
