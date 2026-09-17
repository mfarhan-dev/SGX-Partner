alter table public.withdrawals
  alter column account_title drop not null,
  alter column account_number drop not null;

comment on column public.withdrawals.account_title is
  'Snapshotted from the partner''s payout_account_title at request time. Null for cash_collection, which needs no account details.';
comment on column public.withdrawals.account_number is
  'Snapshotted from the partner''s payout_account_number at request time. Null for cash_collection, which needs no account details.';

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
    v_mechanic_id, v_wholesaler_id, p_amount, v_method, v_account_title, v_account_number,
    (select auth.uid())
  )
  returning * into v_row;

  return v_row;
end;
$function$;
