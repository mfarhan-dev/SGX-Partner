import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notifications/push_notifications_coordinator.dart';
import 'localization/locale_controller.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

class SGXPartnersApp extends ConsumerStatefulWidget {
  const SGXPartnersApp({super.key});

  @override
  ConsumerState<SGXPartnersApp> createState() => _SGXPartnersAppState();
}

class _SGXPartnersAppState extends ConsumerState<SGXPartnersApp> {
  @override
  void initState() {
    super.initState();
    // Deferred past the first frame rather than called here: the
    // coordinator reads the router and the auth provider, and touching
    // providers while the tree is still building is what caused the
    // splash-screen hang documented in SplashScreen.initState. The start
    // itself is idempotent, so a rebuild above us is harmless.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(pushNotificationsCoordinatorProvider).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'SGX Partners',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      routerConfig: router,
    );
  }
}
