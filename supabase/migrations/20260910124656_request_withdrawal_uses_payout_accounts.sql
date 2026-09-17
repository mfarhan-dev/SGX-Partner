
alter table public.withdrawals
  add column payout_account_id uuid references public.payout_accounts(id) on delete set null;

comment on column public.withdrawals.payout_account_id is
  'Traceability link to the live payout_accounts row used, when it still exists. method/account_title/account_number above remain the authoritative snapshot taken at request time -- they stay accurate even if this account is later edited or deleted.';

create or replace function public.request_withdrawal(p_amount integer, p_payout_account_id uuid default null)
returns withdrawals
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_mechanic_id uuid;
  v_wholesaler_id uuid;
  v_min_amount integer;
  v_balance integer;
  v_account public.payout_accounts%rowtype;
  v_row public.withdrawals%rowtype;
begin
  select id into v_mechanic_id from public.mechanics where profile_id = (select auth.uid()) and is_active;

  if v_mechanic_id is null then
    select id into v_wholesaler_id from public.wholesalers where profile_id = (select auth.uid()) and is_active;
  end if;

  if v_mechanic_id is null and v_wholesaler_id is null then
    raise exception 'No active partner profile for this session' using errcode = '28000';
  end if;

  if p_payout_account_id is not null then
    select * into v_account
    from public.payout_accounts
    where id = p_payout_account_id
      and (
        (v_mechanic_id is not null and mechanic_id = v_mechanic_id)
        or (v_wholesaler_id is not null and wholesaler_id = v_wholesaler_id)
      );
    if v_account.id is null then
      raise exception 'Payout account not found' using errcode = '22023';
    end if;
  else
    select * into v_account
    from public.payout_accounts
    where (v_mechanic_id is not null and mechanic_id = v_mechanic_id)
       or (v_wholesaler_id is not null and wholesaler_id = v_wholesaler_id)
    order by is_default desc, created_at asc
    limit 1;
  end if;

  if v_account.id is null then
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
    mechanic_id, wholesaler_id, amount, method, account_title, account_number,
    payout_account_id, created_by
  )
  values (
    v_mechanic_id, v_wholesaler_id, p_amount, v_account.provider, v_account.account_title, v_account.account_number,
    v_account.id, (select auth.uid())
  )
  returning * into v_row;

  return v_row;
end;
$function$;

grant execute on function public.request_withdrawal(integer, uuid) to authenticated;
