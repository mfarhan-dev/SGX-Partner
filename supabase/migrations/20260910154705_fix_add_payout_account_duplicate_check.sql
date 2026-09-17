
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

  if exists (
    select 1 from public.payout_accounts
    where provider = p_provider
      and (
        (v_mechanic_id is not null and mechanic_id = v_mechanic_id)
        or (v_wholesaler_id is not null and wholesaler_id = v_wholesaler_id)
      )
  ) then
    raise exception 'You already have a saved % account', p_provider using errcode = '22023';
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
