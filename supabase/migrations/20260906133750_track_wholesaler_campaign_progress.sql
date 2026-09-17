create or replace function private.track_dispatched_invoice_campaign_progress()
returns trigger language plpgsql security invoker set search_path = '' as $$
begin
  if old.status = new.status or new.status <> 'dispatched' or new.sale_type <> 'wholesaler' or new.is_cash_walk_in or new.wholesaler_id is null then return new; end if;
  insert into public.campaign_progress (campaign_id,audience,wholesaler_id,subject_name_snapshot,subject_area_snapshot,progress_amount)
  select campaign.id,'wholesaler',new.wholesaler_id,wholesaler.shop_name,wholesaler.area,new.payable_total
  from public.campaigns campaign
  join public.campaign_audiences audience on audience.campaign_id=campaign.id and audience.audience='wholesaler'
  join public.wholesalers wholesaler on wholesaler.id=new.wholesaler_id
  where campaign.status='active' and new.invoice_date between campaign.start_date and campaign.end_date
  on conflict (campaign_id,wholesaler_id) where wholesaler_id is not null
  do update set progress_amount=public.campaign_progress.progress_amount+excluded.progress_amount,
    subject_name_snapshot=excluded.subject_name_snapshot,subject_area_snapshot=excluded.subject_area_snapshot,updated_at=now();
  update public.campaign_progress progress
  set qualified_at=now(),qualified_value=progress.progress_amount,updated_at=now()
  from public.campaigns campaign
  where progress.campaign_id=campaign.id and progress.audience='wholesaler' and progress.wholesaler_id=new.wholesaler_id
    and campaign.status='active' and new.invoice_date between campaign.start_date and campaign.end_date
    and progress.qualified_at is null and progress.progress_amount>=campaign.threshold_amount;
  return new;
end; $$;
revoke all on function private.track_dispatched_invoice_campaign_progress() from public, anon, authenticated;
create trigger invoices_track_wholesaler_campaign_progress after update of status on public.invoices
for each row when (old.status is distinct from new.status and new.status='dispatched')
execute function private.track_dispatched_invoice_campaign_progress();
insert into public.campaign_progress (campaign_id,audience,wholesaler_id,subject_name_snapshot,subject_area_snapshot,progress_amount,qualified_at,qualified_value)
select campaign.id,'wholesaler',invoice.wholesaler_id,wholesaler.shop_name,wholesaler.area,sum(invoice.payable_total),
  case when sum(invoice.payable_total)>=campaign.threshold_amount then now() else null end,
  case when sum(invoice.payable_total)>=campaign.threshold_amount then sum(invoice.payable_total) else null end
from public.campaigns campaign
join public.campaign_audiences audience on audience.campaign_id=campaign.id and audience.audience='wholesaler'
join public.invoices invoice on invoice.status='dispatched' and invoice.sale_type='wholesaler' and not invoice.is_cash_walk_in
  and invoice.wholesaler_id is not null and invoice.invoice_date between campaign.start_date and campaign.end_date
join public.wholesalers wholesaler on wholesaler.id=invoice.wholesaler_id
where campaign.status='active'
group by campaign.id,campaign.threshold_amount,invoice.wholesaler_id,wholesaler.shop_name,wholesaler.area
on conflict (campaign_id,wholesaler_id) where wholesaler_id is not null
do update set subject_name_snapshot=excluded.subject_name_snapshot,subject_area_snapshot=excluded.subject_area_snapshot,
  progress_amount=excluded.progress_amount,qualified_at=excluded.qualified_at,qualified_value=excluded.qualified_value,updated_at=now();
