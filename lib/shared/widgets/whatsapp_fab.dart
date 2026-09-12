import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Floating "contact SGX on WhatsApp" button -- the common pattern in
/// Pakistani apps (Daraz, foodpanda, ...): always reachable regardless
/// of scroll position, and reads instantly by shape and color alone,
/// which matters more here than a small monochrome icon tucked into
/// the app bar corner would for a possibly-less-experienced reader.
/// Real WhatsApp glyph (sourced from Wikipedia's own WhatsApp infobox,
/// same sourcing method as the payout provider logos) -- the SVG
/// already contains its own green circle, so the button itself stays
/// a plain white backing disc rather than double-drawing a background.
class WhatsAppFab extends StatelessWidget {
  const WhatsAppFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: 'Contact SGX on WhatsApp',
      backgroundColor: Colors.white,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: SvgPicture.asset('assets/branding/whatsapp_logo.svg'),
      ),
    );
  }
}
