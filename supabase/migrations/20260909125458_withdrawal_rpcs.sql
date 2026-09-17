create or replace function public.request_withdrawal(
  p_amount integer,
  p_method text,
  p_account_title text,
  p_account_number text
)
returns public.withdrawals
language plpgsql security definer set search_path to ''
as $function$
declare
  v_mechanic_id uuid;
  v_wholesaler_id uuid;
  v_min_amount integer;
  v_balance integer;
  v_row public.withdrawals%rowtype;
begin
  select id into v_mechanic_id from public.mechanics
    where profile_id = (select auth.uid()) and is_active;
  select id into v_wholesaler_id from public.wholesalers
    where profile_id = (select auth.uid()) and is_active;

  if v_mechanic_id is null and v_wholesaler_id is null then
    raise exception 'No active partner profile for this session' using errcode = '28000';
  end if;

  if p_method not in ('easy_paisa', 'jazz_cash', 'bank_transfer', 'cash_collection') then
    raise exception 'Invalid payment method' using errcode = '22023';
  end if;

  select min_withdrawal_amount into v_min_amount from public.app_settings;
  if p_amount < v_min_amount then
    raise exception 'Minimum withdrawal amount is Rs. %', v_min_amount using errcode = '22023';
  end if;

  -- Lock the balance row for the duration of this check-then-deduct so
  -- two concurrent withdrawal requests can't both pass the balance
  -- check against the same starting number.
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
    v_mechanic_id, v_wholesaler_id, p_amount, p_method, p_account_title, p_account_number, (select auth.uid())
  )
  returning * into v_row;

  return v_row;
end;
$function$;

revoke all on function public.request_withdrawal(integer, text, text, text) from public;
revoke all on function public.request_withdrawal(integer, text, text, text) from anon;
grant execute on function public.request_withdrawal(integer, text, text, text) to authenticated;

create or replace function public.confirm_withdrawal_received(p_withdrawal_id uuid)
returns public.withdrawals
language plpgsql security definer set search_path to ''
as $function$
declare
  v_row public.withdrawals%rowtype;
begin
  select w.* into v_row from public.withdrawals w
  where w.id = p_withdrawal_id
    and (
      w.mechanic_id in (select id from public.mechanics where profile_id = (select auth.uid()))
      or w.wholesaler_id in (select id from public.wholesalers where profile_id = (select auth.uid()))
    )
  for update;

  if not found then
    raise exception 'Withdrawal not found' using errcode = '28000';
  end if;

  if v_row.status <> 'payment_sent' then
    raise exception 'Withdrawal is not awaiting confirmation' using errcode = '22023';
  end if;

  update public.withdrawals set status = 'confirmed' where id = p_withdrawal_id
  returning * into v_row;

  return v_row;
end;
$function$;

revoke all on function public.confirm_withdrawal_received(uuid) from public;
revoke all on function public.confirm_withdrawal_received(uuid) from anon;
grant execute on function public.confirm_withdrawal_received(uuid) to authenticated;

create or replace function public.dispute_withdrawal_received(p_withdrawal_id uuid, p_reason text)
returns public.withdrawals
language plpgsql security definer set search_path to ''
as $function$
declare
  v_row public.withdrawals%rowtype;
begin
  select w.* into v_row from public.withdrawals w
  where w.id = p_withdrawal_id
    and (
      w.mechanic_id in (select id from public.mechanics where profile_id = (select auth.uid()))
      or w.wholesaler_id in (select id from public.wholesalers where profile_id = (select auth.uid()))
    )
  for update;

  if not found then
    raise exception 'Withdrawal not found' using errcode = '28000';
  end if;

  if v_row.status <> 'payment_sent' then
    raise exception 'Withdrawal is not awaiting confirmation' using errcode = '22023';
  end if;

  update public.withdrawals set status = 'disputed', dispute_reason = p_reason where id = p_withdrawal_id
  returning * into v_row;

  return v_row;
end;
$function$;

revoke all on function public.dispute_withdrawal_received(uuid, text) from public;
revoke all on function public.dispute_withdrawal_received(uuid, text) from anon;
grant execute on function public.dispute_withdrawal_received(uuid, text) to authenticated;
