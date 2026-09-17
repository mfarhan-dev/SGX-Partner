-- These are trigger-only functions, never meant to be called directly via
-- PostgREST's auto-exposed /rest/v1/rpc/<function_name> -- revoke the
-- implicit anon/authenticated EXECUTE grant PostgREST gives every public
-- schema function by default.
revoke all on function public.notify_push_on_user_notification() from public, anon, authenticated;
revoke all on function public.notify_qr_reward_credited() from public, anon, authenticated;
revoke all on function public.notify_withdrawal_status_change() from public, anon, authenticated;
revoke all on function public.notify_withdrawal_submitted() from public, anon, authenticated;

-- Move pg_net out of the public schema into the same dedicated schema this
-- project already uses for its other extensions (uuid-ossp, pgcrypto, ...).
-- pg_net's own net.http_post()/net.http_get() always live in the `net`
-- schema regardless of which schema the extension itself is registered
-- under, so the trigger functions calling net.http_post() are unaffected.
drop extension if exists pg_net;
create extension pg_net with schema extensions;
