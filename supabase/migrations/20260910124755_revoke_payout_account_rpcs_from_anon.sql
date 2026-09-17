
revoke all on function public.add_payout_account(text, text, text) from anon;
revoke all on function public.update_payout_account(uuid, text, text) from anon;
revoke all on function public.delete_payout_account(uuid) from anon;
revoke all on function public.set_default_payout_account(uuid) from anon;
revoke all on function public.request_withdrawal(integer, uuid) from anon;
