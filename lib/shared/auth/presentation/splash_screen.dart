import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_guards.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../shared/widgets/sgx_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // restoreSession() sets provider state synchronously as its first
    // statement (before any await), which Riverpod disallows while the
    // widget tree is still building. Deferring to a microtask lets the
    // current build finish first — the standard fix for "modify a
    // provider while the widget tree was building". Without this the
    // exception was silently swallowed (uncaught in an un-awaited
    // Future), so _bootstrap() never reached its final context.go(),
    // and the splash screen hung forever on every launch.
    Future.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    // Restore any existing Supabase session (a wholesaler/mechanic who
    // logged in before) alongside a minimum splash duration, whichever
    // takes longer — previously this screen ALWAYS sent everyone to
    // the phone login screen regardless of an existing session, so a
    // returning user had to re-verify OTP on every single app launch.
    await Future.wait([
      ref.read(authControllerProvider.notifier).restoreSession(),
      Future<void>.delayed(const Duration(milliseconds: 1200)),
    ]);
    if (!mounted) return;

    final auth = ref.read(authControllerProvider);
    context.go(RouteGuards.protectedLanding(auth));
  }

  @override
  Widget build(BuildContext context) {
    // No AppBar here to auto-derive the status bar style from a light
    // background, and the scaffold itself is the brand red — force
    // light (white) status bar icons so they stay visible on it.
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0x10FFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(28)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: SgxLogo(size: 112),
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      Text(
                        'SGX Partners',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'Scan · Earn · Withdraw',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 40,
                child: Column(
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                        backgroundColor: Color(0x40FFFFFF),
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'SGX PARTNERS · v1.0',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
