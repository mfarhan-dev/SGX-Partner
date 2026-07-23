import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import 'sgx_app_bar.dart';

class SgxScreen extends StatelessWidget {
  const SgxScreen({
    super.key,
    required this.title,
    required this.children,
    this.showBack = false,
    this.showNotifications = true,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.sm,
      AppSpacing.md,
      AppSpacing.lg,
    ),
  });

  final String title;
  final List<Widget> children;
  final bool showBack;
  final bool showNotifications;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SgxAppBar(
        title: title,
        showBack: showBack,
        showNotifications: showNotifications,
      ),
      body: SafeArea(
        child: ListView(padding: padding, children: children),
      ),
    );
  }
}
