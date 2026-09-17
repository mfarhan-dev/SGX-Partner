
-- Ordering is now purely insertion order (created_at) -- the partner
-- adds SadaPay then JazzCash, both the Payout Method list and the
-- Withdraw Money "Pay to" grid show them in that same order. No more
-- "default" flag to set or reason about.

drop function if exists public.set_default_payout_account(uuid);

drop index if exists public.payout_accounts_one_default_mechanic;
drop index if exists public.payout_accounts_one_default_wholesaler;

alter table public.payout_accounts drop column is_default;

create or replace function public.add_payout_account(
  p_provider text,
  p_account_title text,
  p_account_number text
)
returns public.payout_accounts
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_mechanic_id uuid;
  v_wholesaler_id uuid;
  v_row public.payout_accounts%rowtype;
begin
  if p_provider not in (
    'easy_paisa', 'jazz_cash', 'sada_pay', 'naya_pay', 'u_paisa',
    'meezan_bank', 'hbl', 'ubl', 'mcb_bank', 'bank_alfalah',
    'allied_bank', 'askari_bank', 'faysal_bank', 'bank_al_habib', 'nbp'
  ) then
    raise exception 'Unknown payout provider: %', p_provider using errcode = '22023';
  end if;
  if trim(coalesce(p_account_title, '')) = '' or trim(coalesce(p_account_number, '')) = '' then
    raise exception 'Account title and number are required' using errcode = '22023';
  end if;

  select id into v_mechanic_id from public.mechanics where profile_id = (select auth.uid()) and is_active;
  if v_mechanic_id is null then
    select id into v_wholesaler_id from public.wholesalers where profile_id = (select auth.uid()) and is_active;
  end if;
  if v_mechanic_id is null and v_wholesaler_id is null then
    raise exception 'No active partner profile for this session' using errcode = '28000';
  end if;

  insert into public.payout_accounts (
    mechanic_id, wholesaler_id, provider, account_title, account_number,
    created_by, updated_by
  )
  values (
    v_mechanic_id, v_wholesaler_id, p_provider, trim(p_account_title), trim(p_account_number),
    (select auth.uid()), (select auth.uid())
  )
  returning * into v_row;

  return v_row;
end;
$function$;

create or replace function public.delete_payout_account(p_account_id uuid)
returns void
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_deleted public.payout_accounts%rowtype;
begin
  delete from public.payout_accounts
  where id = p_account_id
    and (
      mechanic_id in (select id from public.mechanics where profile_id = (select auth.uid()))
      or wholesaler_id in (select id from public.wholesalers where profile_id = (select auth.uid()))
    )
  returning * into v_deleted;

  if v_deleted.id is null then
    raise exception 'Payout account not found' using errcode = '22023';
  end if;
end;
$function$;

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
    -- No account named -- use whichever was added first (insertion
    -- order), matching the same order the app shows everywhere now
    -- that there's no separate "default" flag.
    select * into v_account
    from public.payout_accounts
    where (v_mechanic_id is not null and mechanic_id = v_mechanic_id)
       or (v_wholesaler_id is not null and wholesaler_id = v_wholesaler_id)
    order by created_at asc
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
