create or replace function private.track_scanned_qr_campaign_progress()
returns trigger language plpgsql security invoker set search_path='' as $$
declare scan_date date;
begin
  if old.status=new.status or new.status<>'scanned' or new.mechanic_id is null or new.scanned_at is null or new.mechanic_reward_snapshot<=0 then return new; end if;
  scan_date := (new.scanned_at at time zone 'Asia/Karachi')::date;
  insert into public.campaign_progress(campaign_id,audience,mechanic_id,subject_name_snapshot,subject_area_snapshot,progress_amount)
  select campaign.id,'mechanic',new.mechanic_id,mechanic.full_name,mechanic.area,new.mechanic_reward_snapshot
  from public.campaigns campaign
  join public.campaign_audiences audience on audience.campaign_id=campaign.id and audience.audience='mechanic'
  join public.mechanics mechanic on mechanic.id=new.mechanic_id
  where campaign.status='active' and scan_date between campaign.start_date and campaign.end_date
  on conflict(campaign_id,mechanic_id) where mechanic_id is not null
  do update set progress_amount=public.campaign_progress.progress_amount+excluded.progress_amount,
    subject_name_snapshot=excluded.subject_name_snapshot,subject_area_snapshot=excluded.subject_area_snapshot,updated_at=now();
  update public.campaign_progress progress
  set qualified_at=now(),qualified_value=progress.progress_amount,updated_at=now()
  from public.campaigns campaign
  where progress.campaign_id=campaign.id and progress.audience='mechanic' and progress.mechanic_id=new.mechanic_id
    and campaign.status='active' and scan_date between campaign.start_date and campaign.end_date
    and progress.qualified_at is null and progress.progress_amount>=campaign.threshold_amount;
  return new;
end; $$;
revoke all on function private.track_scanned_qr_campaign_progress() from public,anon,authenticated;
create trigger qr_codes_track_mechanic_campaign_progress after update of status on public.qr_codes
for each row when(old.status is distinct from new.status and new.status='scanned')
execute function private.track_scanned_qr_campaign_progress();
insert into public.campaign_progress(campaign_id,audience,mechanic_id,subject_name_snapshot,subject_area_snapshot,progress_amount,qualified_at,qualified_value)
select campaign.id,'mechanic',qr.mechanic_id,mechanic.full_name,mechanic.area,sum(qr.mechanic_reward_snapshot),
 case when sum(qr.mechanic_reward_snapshot)>=campaign.threshold_amount then now() else null end,
 case when sum(qr.mechanic_reward_snapshot)>=campaign.threshold_amount then sum(qr.mechanic_reward_snapshot) else null end
from public.campaigns campaign
join public.campaign_audiences audience on audience.campaign_id=campaign.id and audience.audience='mechanic'
join public.qr_codes qr on qr.status='scanned' and qr.mechanic_id is not null and qr.scanned_at is not null and qr.mechanic_reward_snapshot>0
 and (qr.scanned_at at time zone 'Asia/Karachi')::date between campaign.start_date and campaign.end_date
join public.mechanics mechanic on mechanic.id=qr.mechanic_id
where campaign.status='active'
group by campaign.id,campaign.threshold_amount,qr.mechanic_id,mechanic.full_name,mechanic.area
on conflict(campaign_id,mechanic_id) where mechanic_id is not null
do update set subject_name_snapshot=excluded.subject_name_snapshot,subject_area_snapshot=excluded.subject_area_snapshot,
 progress_amount=excluded.progress_amount,qualified_at=excluded.qualified_at,qualified_value=excluded.qualified_value,updated_at=now();
