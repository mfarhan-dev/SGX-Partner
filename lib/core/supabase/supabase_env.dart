/// Project connection details for the SGX Supabase backend.
///
/// The anon/publishable key is safe to ship in a client app by design —
/// it identifies the project, not a user, and every table it can reach
/// is still gated by Row Level Security. Never put the service role key
/// here or anywhere in the app.
class SupabaseEnv {
  const SupabaseEnv._();

  static const url = 'https://ghojtefwuzubqguqcbwc.supabase.co';
  static const publishableKey =
      'sb_publishable_JUDtaZiYa1uzkfSW1SZigA_851Mi8t3';
}
