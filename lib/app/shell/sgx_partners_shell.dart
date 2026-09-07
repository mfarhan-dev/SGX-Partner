import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../shared/models/app_role.dart';
import '../../shared/widgets/confirm_dialog.dart';
import 'mechanic_shell.dart';
import 'wholesaler_shell.dart';

/// Every tab screen (Home/Products/Activity/Settings, or the
/// wholesaler equivalents) is reached with `context.go()`, which
/// replaces the current route instead of pushing onto a back stack --
/// so system back from any of them was popping straight out of the
/// app with no warning. Wrapping the whole shell in PopScope catches
/// that pop here (the one common ancestor for both roles) and asks
/// first, instead of every tab screen needing its own copy of this.
class SgxPartnersShell extends ConsumerWidget {
  const SgxPartnersShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authControllerProvider).profile?.role;
    final shell = role == AppRole.wholesaler
        ? WholesalerShell(child: child)
        : MechanicShell(child: child);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final confirmed = await showConfirmDialog(
          context: context,
          title: 'Exit app?',
          message: 'Are you sure you want to exit SGX Partners?',
          confirmLabel: 'Exit',
        );
        if (confirmed) SystemNavigator.pop();
      },
      child: shell,
    );
  }
}
