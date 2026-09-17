alter table public.mechanics
  drop constraint mechanics_payout_method_check,
  drop constraint mechanics_payout_account_required,
  alter column payout_method drop default,
  alter column payout_method drop not null;

update public.mechanics set payout_method = null where payout_method = 'cash_collection';

alter table public.mechanics
  add constraint mechanics_payout_method_check
    check (payout_method is null or payout_method in ('easy_paisa', 'jazz_cash', 'bank_transfer')),
  add constraint mechanics_payout_account_required
    check (payout_method is null or (payout_account_title is not null and payout_account_number is not null));

alter table public.wholesalers
  drop constraint wholesalers_payout_method_check,
  drop constraint wholesalers_payout_account_required,
  alter column payout_method drop default,
  alter column payout_method drop not null;

update public.wholesalers set payout_method = null where payout_method = 'cash_collection';

alter table public.wholesalers
  add constraint wholesalers_payout_method_check
    check (payout_method is null or payout_method in ('easy_paisa', 'jazz_cash', 'bank_transfer')),
  add constraint wholesalers_payout_account_required
    check (payout_method is null or (payout_account_title is not null and payout_account_number is not null));

comment on column public.mechanics.payout_method is
  'How this mechanic wants to receive withdrawals -- set via set_payout_method(), snapshotted onto each withdrawals row at request_withdrawal() time. Null means not configured yet -- request_withdrawal() blocks with a clear error until this is set.';
comment on column public.wholesalers.payout_method is
  'How this wholesaler wants to receive withdrawals -- set via set_payout_method(), snapshotted onto each withdrawals row at request_withdrawal() time. Null means not configured yet -- request_withdrawal() blocks with a clear error until this is set.';

alter table public.withdrawals drop constraint withdrawals_method_check;
alter table public.withdrawals
  add constraint withdrawals_method_check check (method in ('easy_paisa', 'jazz_cash', 'bank_transfer'));

create or replace function public.set_payout_method(
  p_method text,
  p_account_title text,
  p_account_number text
)
returns table(payout_method text, payout_account_title text, payout_account_number text)
language plpgsql security definer set search_path to ''
as $function$
declare
  v_mechanic_id uuid;
  v_wholesaler_id uuid;
  v_title text;
  v_number text;
begin
  if p_method not in ('easy_paisa', 'jazz_cash', 'bank_transfer') then
    raise exception 'Invalid payout method' using errcode = '22023';
  end if;

  v_title := nullif(trim(coalesce(p_account_title, '')), '');
  v_number := nullif(trim(coalesce(p_account_number, '')), '');

  if v_title is null or v_number is null then
    raise exception 'Account title and number are required' using errcode = '22023';
  end if;

  select id into v_mechanic_id from public.mechanics
    where profile_id = (select auth.uid()) and is_active;
  select id into v_wholesaler_id from public.wholesalers
    where profile_id = (select auth.uid()) and is_active;

  if v_mechanic_id is null and v_wholesaler_id is null then
    raise exception 'No active partner profile for this session' using errcode = '28000';
  end if;

  if v_mechanic_id is not null then
    update public.mechanics
    set payout_method = p_method, payout_account_title = v_title, payout_account_number = v_number
    where id = v_mechanic_id;

    return query
      select m.payout_method, m.payout_account_title, m.payout_account_number
      from public.mechanics m where m.id = v_mechanic_id;
  else
    update public.wholesalers
    set payout_method = p_method, payout_account_title = v_title, payout_account_number = v_number
    where id = v_wholesaler_id;

    return query
      select w.payout_method, w.payout_account_title, w.payout_account_number
      from public.wholesalers w where w.id = v_wholesaler_id;
  end if;
end;
$function$;

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

  if v_method is null or v_account_title is null or v_account_number is null then
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
