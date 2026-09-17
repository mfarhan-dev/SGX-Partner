alter table public.mechanics
  add column payout_method text not null default 'cash_collection'
    constraint mechanics_payout_method_check
    check (payout_method in ('easy_paisa', 'jazz_cash', 'bank_transfer', 'cash_collection')),
  add column payout_account_title text,
  add column payout_account_number text,
  add constraint mechanics_payout_account_required check (
    payout_method = 'cash_collection'
    or (payout_account_title is not null and payout_account_number is not null)
  );

alter table public.wholesalers
  add column payout_method text not null default 'cash_collection'
    constraint wholesalers_payout_method_check
    check (payout_method in ('easy_paisa', 'jazz_cash', 'bank_transfer', 'cash_collection')),
  add column payout_account_title text,
  add column payout_account_number text,
  add constraint wholesalers_payout_account_required check (
    payout_method = 'cash_collection'
    or (payout_account_title is not null and payout_account_number is not null)
  );

comment on column public.mechanics.payout_method is
  'How this mechanic wants to receive withdrawals -- set via set_payout_method(), snapshotted onto each withdrawals row at request_withdrawal() time. Defaults to cash_collection so a partner is never blocked from requesting.';
comment on column public.wholesalers.payout_method is
  'How this wholesaler wants to receive withdrawals -- set via set_payout_method(), snapshotted onto each withdrawals row at request_withdrawal() time. Defaults to cash_collection so a partner is never blocked from requesting.';

create or replace function public.set_payout_method(
  p_method text,
  p_account_title text default null,
  p_account_number text default null
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
  if p_method not in ('easy_paisa', 'jazz_cash', 'bank_transfer', 'cash_collection') then
    raise exception 'Invalid payout method' using errcode = '22023';
  end if;

  v_title := nullif(trim(coalesce(p_account_title, '')), '');
  v_number := nullif(trim(coalesce(p_account_number, '')), '');

  if p_method <> 'cash_collection' and (v_title is null or v_number is null) then
    raise exception 'Account title and number are required for this payout method'
      using errcode = '22023';
  end if;

  select id into v_mechanic_id from public.mechanics
    where profile_id = (select auth.uid()) and is_active;
  select id into v_wholesaler_id from public.wholesalers
    where profile_id = (select auth.uid()) and is_active;

  if v_mechanic_id is null and v_wholesaler_id is null then
    raise exception 'No active partner profile for this session' using errcode = '28000';
  end if;

  if p_method = 'cash_collection' then
    v_title := null;
    v_number := null;
  end if;

  if v_mechanic_id is not null then
    update public.mechanics
    set payout_method = p_method,
        payout_account_title = v_title,
        payout_account_number = v_number
    where id = v_mechanic_id;

    return query
      select m.payout_method, m.payout_account_title, m.payout_account_number
      from public.mechanics m where m.id = v_mechanic_id;
  else
    update public.wholesalers
    set payout_method = p_method,
        payout_account_title = v_title,
        payout_account_number = v_number
    where id = v_wholesaler_id;

    return query
      select w.payout_method, w.payout_account_title, w.payout_account_number
      from public.wholesalers w where w.id = v_wholesaler_id;
  end if;
end;
$function$;

revoke all on function public.set_payout_method(text, text, text) from public;
revoke all on function public.set_payout_method(text, text, text) from anon;
grant execute on function public.set_payout_method(text, text, text) to authenticated;
