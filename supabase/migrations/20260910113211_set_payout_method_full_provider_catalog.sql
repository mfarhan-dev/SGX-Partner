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
  if p_method not in (
    'easy_paisa', 'jazz_cash', 'sada_pay', 'naya_pay', 'u_paisa',
    'meezan_bank', 'hbl', 'ubl', 'mcb_bank', 'bank_alfalah',
    'allied_bank', 'askari_bank', 'faysal_bank', 'bank_al_habib', 'nbp'
  ) then
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
