import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../shared/models/app_role.dart';
import 'mechanic_shell.dart';
import 'wholesaler_shell.dart';

class SgxPartnersShell extends ConsumerWidget {
  const SgxPartnersShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authControllerProvider).profile?.role;
    if (role == AppRole.wholesaler) {
      return WholesalerShell(child: child);
    }
    return MechanicShell(child: child);
  }
}
