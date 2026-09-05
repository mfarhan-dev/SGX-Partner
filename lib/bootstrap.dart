import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/storage/local_preferences.dart';
import 'core/supabase/supabase_env.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalPreferences.initialize();
  await Supabase.initialize(
    url: SupabaseEnv.url,
    publishableKey: SupabaseEnv.publishableKey,
  );

  runApp(const ProviderScope(child: SGXPartnersApp()));
}
