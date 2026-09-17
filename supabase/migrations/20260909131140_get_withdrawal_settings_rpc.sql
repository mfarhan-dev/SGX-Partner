create or replace function public.get_withdrawal_settings()
returns table(min_withdrawal_amount integer, withdrawal_processing_time text)
language sql security definer set search_path to ''
as $function$
  select s.min_withdrawal_amount, s.withdrawal_processing_time
  from public.app_settings s;
$function$;

revoke all on function public.get_withdrawal_settings() from public;
revoke all on function public.get_withdrawal_settings() from anon;
grant execute on function public.get_withdrawal_settings() to authenticated;
