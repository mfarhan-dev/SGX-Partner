
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
  v_existing_count integer;
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

  select count(*) into v_existing_count
  from public.payout_accounts
  where (v_mechanic_id is not null and mechanic_id = v_mechanic_id)
     or (v_wholesaler_id is not null and wholesaler_id = v_wholesaler_id);

  insert into public.payout_accounts (
    mechanic_id, wholesaler_id, provider, account_title, account_number,
    is_default, created_by, updated_by
  )
  values (
    v_mechanic_id, v_wholesaler_id, p_provider, trim(p_account_title), trim(p_account_number),
    v_existing_count = 0, (select auth.uid()), (select auth.uid())
  )
  returning * into v_row;

  return v_row;
end;
$function$;

create or replace function public.update_payout_account(
  p_account_id uuid,
  p_account_title text,
  p_account_number text
)
returns public.payout_accounts
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_row public.payout_accounts%rowtype;
begin
  if trim(coalesce(p_account_title, '')) = '' or trim(coalesce(p_account_number, '')) = '' then
    raise exception 'Account title and number are required' using errcode = '22023';
  end if;

  update public.payout_accounts
  set account_title = trim(p_account_title),
      account_number = trim(p_account_number),
      updated_at = now(),
      updated_by = (select auth.uid())
  where id = p_account_id
    and (
      mechanic_id in (select id from public.mechanics where profile_id = (select auth.uid()))
      or wholesaler_id in (select id from public.wholesalers where profile_id = (select auth.uid()))
    )
  returning * into v_row;

  if v_row.id is null then
    raise exception 'Payout account not found' using errcode = '22023';
  end if;

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
  v_next_id uuid;
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

  -- If the deleted account was the default and others remain, promote
  -- the oldest remaining one so there's always a default when any
  -- account exists.
  if v_deleted.is_default then
    select id into v_next_id
    from public.payout_accounts
    where (v_deleted.mechanic_id is not null and mechanic_id = v_deleted.mechanic_id)
       or (v_deleted.wholesaler_id is not null and wholesaler_id = v_deleted.wholesaler_id)
    order by created_at asc
    limit 1;

    if v_next_id is not null then
      update public.payout_accounts set is_default = true where id = v_next_id;
    end if;
  end if;
end;
$function$;

create or replace function public.set_default_payout_account(p_account_id uuid)
returns void
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_row public.payout_accounts%rowtype;
begin
  select * into v_row
  from public.payout_accounts
  where id = p_account_id
    and (
      mechanic_id in (select id from public.mechanics where profile_id = (select auth.uid()))
      or wholesaler_id in (select id from public.wholesalers where profile_id = (select auth.uid()))
    );

  if v_row.id is null then
    raise exception 'Payout account not found' using errcode = '22023';
  end if;

  update public.payout_accounts
  set is_default = false
  where ((v_row.mechanic_id is not null and mechanic_id = v_row.mechanic_id)
     or (v_row.wholesaler_id is not null and wholesaler_id = v_row.wholesaler_id))
    and id <> p_account_id
    and is_default;

  update public.payout_accounts set is_default = true where id = p_account_id;
end;
$function$;

grant execute on function public.add_payout_account(text, text, text) to authenticated;
grant execute on function public.update_payout_account(uuid, text, text) to authenticated;
grant execute on function public.delete_payout_account(uuid) to authenticated;
grant execute on function public.set_default_payout_account(uuid) to authenticated;
