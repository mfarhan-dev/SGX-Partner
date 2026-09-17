create or replace function public.request_withdrawal(p_amount integer)
returns public.withdrawals
language plpgsql security definer set search_path to ''
as $function$
declare
  v_mechanic_id uuid;
  v_wholesaler_id uuid;
  v_min_amount integer;
  v_balance integer;
  v_method text;
  v_account_title text;
  v_account_number text;
  v_row public.withdrawals%rowtype;
begin
  select id, payout_method, payout_account_title, payout_account_number
    into v_mechanic_id, v_method, v_account_title, v_account_number
  from public.mechanics
  where profile_id = (select auth.uid()) and is_active;

  if v_mechanic_id is null then
    select id, payout_method, payout_account_title, payout_account_number
      into v_wholesaler_id, v_method, v_account_title, v_account_number
    from public.wholesalers
    where profile_id = (select auth.uid()) and is_active;
  end if;

  if v_mechanic_id is null and v_wholesaler_id is null then
    raise exception 'No active partner profile for this session' using errcode = '28000';
  end if;

  -- Cash collection needs no account details on file; every other
  -- method is guaranteed to have both by set_payout_method()'s own
  -- check constraint, but this stays defensive in case that ever
  -- changes.
  if v_method <> 'cash_collection'
     and (v_account_title is null or v_account_number is null) then
    raise exception 'Set up a payout method in Settings before requesting a withdrawal'
      using errcode = '22023';
  end if;

  select min_withdrawal_amount into v_min_amount from public.app_settings;
  if p_amount < v_min_amount then
    raise exception 'Minimum withdrawal amount is Rs. %', v_min_amount using errcode = '22023';
  end if;

  perform set_config('sgx.points_sync', 'on', true);

  if v_mechanic_id is not null then
    select points_balance into v_balance from public.mechanics where id = v_mechanic_id for update;
    if p_amount > v_balance then
      perform set_config('sgx.points_sync', 'off', true);
      raise exception 'Insufficient balance' using errcode = '22023';
    end if;
    update public.mechanics set points_balance = points_balance - p_amount where id = v_mechanic_id;
  else
    select points_balance into v_balance from public.wholesalers where id = v_wholesaler_id for update;
    if p_amount > v_balance then
      perform set_config('sgx.points_sync', 'off', true);
      raise exception 'Insufficient balance' using errcode = '22023';
    end if;
    update public.wholesalers set points_balance = points_balance - p_amount where id = v_wholesaler_id;
  end if;

  perform set_config('sgx.points_sync', 'off', true);

  insert into public.withdrawals (
    mechanic_id, wholesaler_id, amount, method, account_title, account_number, created_by
  )
  values (
    v_mechanic_id, v_wholesaler_id, p_amount, v_method,
    coalesce(v_account_title, 'SGX cash collection'),
    coalesce(v_account_number, '-'),
    (select auth.uid())
  )
  returning * into v_row;

  return v_row;
end;
$function$;

-- Signature changed (4 params -> 1) -- drop the old overload so
-- nothing stale is left callable.
drop function if exists public.request_withdrawal(integer, text, text, text);

revoke all on function public.request_withdrawal(integer) from public;
revoke all on function public.request_withdrawal(integer) from anon;
grant execute on function public.request_withdrawal(integer) to authenticated;
