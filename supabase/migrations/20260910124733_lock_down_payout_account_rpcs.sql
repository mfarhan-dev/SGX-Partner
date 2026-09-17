
revoke all on function public.add_payout_account(text, text, text) from public;
revoke all on function public.update_payout_account(uuid, text, text) from public;
revoke all on function public.delete_payout_account(uuid) from public;
revoke all on function public.set_default_payout_account(uuid) from public;
revoke all on function public.request_withdrawal(integer, uuid) from public;

grant execute on function public.add_payout_account(text, text, text) to authenticated;
grant execute on function public.update_payout_account(uuid, text, text) to authenticated;
grant execute on function public.delete_payout_account(uuid) to authenticated;
grant execute on function public.set_default_payout_account(uuid) to authenticated;
grant execute on function public.request_withdrawal(integer, uuid) to authenticated;
