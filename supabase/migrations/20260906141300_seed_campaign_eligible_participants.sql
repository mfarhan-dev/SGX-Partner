-- Freeze the eligible wholesaler/mechanic population when a campaign is first
-- published. Progress source triggers update these zero-value rows later.

create or replace function private.seed_campaign_eligible_participants()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if old.status = 'draft' and new.status in ('scheduled', 'active') then
    insert into public.campaign_progress (
      campaign_id,
      audience,
      wholesaler_id,
      subject_name_snapshot,
      subject_area_snapshot
    )
    select
      new.id,
      'wholesaler',
      wholesaler.id,
      wholesaler.shop_name,
      wholesaler.area
    from public.wholesalers as wholesaler
    where wholesaler.is_active
      and exists (
        select 1
        from public.campaign_audiences as target
        where target.campaign_id = new.id
          and target.audience = 'wholesaler'
      )
    on conflict (campaign_id, wholesaler_id) where wholesaler_id is not null
      do nothing;

    insert into public.campaign_progress (
      campaign_id,
      audience,
      mechanic_id,
      subject_name_snapshot,
      subject_area_snapshot
    )
    select
      new.id,
      'mechanic',
      mechanic.id,
      mechanic.full_name,
      mechanic.area
    from public.mechanics as mechanic
    where mechanic.is_active
      and exists (
        select 1
        from public.campaign_audiences as target
        where target.campaign_id = new.id
          and target.audience = 'mechanic'
      )
    on conflict (campaign_id, mechanic_id) where mechanic_id is not null
      do nothing;
  end if;

  return new;
end;
$$;

revoke all on function private.seed_campaign_eligible_participants() from public, anon, authenticated;

create trigger campaigns_seed_eligible_participants
  after update of status on public.campaigns
  for each row
  when (old.status is distinct from new.status)
  execute function private.seed_campaign_eligible_participants();

-- Reconcile campaigns published before this trigger was installed.
insert into public.campaign_progress (
  campaign_id,
  audience,
  wholesaler_id,
  subject_name_snapshot,
  subject_area_snapshot
)
select
  campaign.id,
  'wholesaler',
  wholesaler.id,
  wholesaler.shop_name,
  wholesaler.area
from public.campaigns as campaign
join public.campaign_audiences as target
  on target.campaign_id = campaign.id
 and target.audience = 'wholesaler'
cross join public.wholesalers as wholesaler
where campaign.status in ('scheduled', 'active', 'paused')
  and wholesaler.is_active
on conflict (campaign_id, wholesaler_id) where wholesaler_id is not null
  do nothing;

insert into public.campaign_progress (
  campaign_id,
  audience,
  mechanic_id,
  subject_name_snapshot,
  subject_area_snapshot
)
select
  campaign.id,
  'mechanic',
  mechanic.id,
  mechanic.full_name,
  mechanic.area
from public.campaigns as campaign
join public.campaign_audiences as target
  on target.campaign_id = campaign.id
 and target.audience = 'mechanic'
cross join public.mechanics as mechanic
where campaign.status in ('scheduled', 'active', 'paused')
  and mechanic.is_active
on conflict (campaign_id, mechanic_id) where mechanic_id is not null
  do nothing;
