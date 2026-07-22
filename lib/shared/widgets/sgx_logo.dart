import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SgxLogo extends StatelessWidget {
  const SgxLogo({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'SGX Partners',
      image: true,
      child: SvgPicture.asset(
        'assets/branding/sgx-app-icon.svg',
        width: size,
        height: size,
      ),
    );
  }
}
