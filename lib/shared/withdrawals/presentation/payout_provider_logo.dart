import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/payout_provider.dart';

/// Real logo where one was found (each institution's own Wikipedia
/// infobox / official site), a colored monogram otherwise. Shared by
/// the Payout Method screen, the Withdraw Money sheet, and the add-
/// account picker so every place a provider shows up looks identical.
class PayoutProviderLogo extends StatelessWidget {
  const PayoutProviderLogo({
    super.key,
    required this.provider,
    required this.size,
  });

  final PayoutProvider provider;
  final double size;

  @override
  Widget build(BuildContext context) {
    final logo = provider.logoAsset;
    if (logo == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: provider.monogramColor,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          provider.monogram ?? '?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.36,
          ),
        ),
      );
    }

    return Container(
      width: size * 1.5,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.outlineOf(context)),
      ),
      child: provider.isSvgLogo
          ? SvgPicture.asset(logo, fit: BoxFit.contain)
          : Image.asset(logo, fit: BoxFit.contain),
    );
  }
}
