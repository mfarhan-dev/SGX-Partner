-- confirm_withdrawal_received and dispute_withdrawal_received previously
-- only updated the withdrawals row -- nothing durable/queryable recorded
-- that the *mechanic/wholesaler* took this action. The admin panel's
-- timeline read audit_logs exclusively whenever any row existed for a
-- withdrawal (which is always true once staff mark it paid), so these
-- mobile-originated events were silently invisible there. Now both RPCs
-- write their own audit_logs row (source = 'b2b_app', already a valid
-- value in that table's own check constraint) so every state change, from
-- either side, lands in the one ordered history.
--
-- Also fixes the disputed_at gap: dispute_withdrawal_received previously
-- never stamped it (only confirmed_at was handled, by a trigger).

create or replace function public.confirm_withdrawal_received(p_withdrawal_id uuid)
 returns withdrawals
 language plpgsql
 security definer
 set search_path to ''
as $function$
declare
  v_row public.withdrawals%rowtype;
  v_actor_role text;
  v_actor_name text;
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

  if v_row.mechanic_id is not null then
    v_actor_role := 'mechanic';
    select full_name into v_actor_name from public.mechanics where id = v_row.mechanic_id;
  else
    v_actor_role := 'wholesaler';
    select coalesce(shop_name, owner_name) into v_actor_name from public.wholesalers where id = v_row.wholesaler_id;
  end if;

  insert into public.audit_logs (
    actor_profile_id, actor_name, actor_role, module, action, target, summary, outcome, source
  ) values (
    (select auth.uid()), coalesce(v_actor_name, 'Partner'), v_actor_role, 'Withdrawals',
    'Confirmed by ' || v_actor_role, v_row.withdrawal_no,
    initcap(v_actor_role) || ' confirmed receipt of withdrawal ' || v_row.withdrawal_no || ' (Rs. ' || v_row.amount || ').',
    'success', 'b2b_app'
  );

  return v_row;
end;
$function$;

create or replace function public.dispute_withdrawal_received(p_withdrawal_id uuid, p_reason text)
 returns withdrawals
 language plpgsql
 security definer
 set search_path to ''
as $function$
declare
  v_row public.withdrawals%rowtype;
  v_actor_role text;
  v_actor_name text;
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

  update public.withdrawals
  set status = 'disputed', dispute_reason = p_reason, disputed_at = now()
  where id = p_withdrawal_id
  returning * into v_row;

  if v_row.mechanic_id is not null then
    v_actor_role := 'mechanic';
    select full_name into v_actor_name from public.mechanics where id = v_row.mechanic_id;
  else
    v_actor_role := 'wholesaler';
    select coalesce(shop_name, owner_name) into v_actor_name from public.wholesalers where id = v_row.wholesaler_id;
  end if;

  insert into public.audit_logs (
    actor_profile_id, actor_name, actor_role, module, action, target, summary, outcome, source, note
  ) values (
    (select auth.uid()), coalesce(v_actor_name, 'Partner'), v_actor_role, 'Withdrawals',
    'Disputed by ' || v_actor_role, v_row.withdrawal_no,
    initcap(v_actor_role) || ' disputed withdrawal ' || v_row.withdrawal_no || ': ' || p_reason,
    'success', 'b2b_app', p_reason
  );

  return v_row;
end;
$function$;
