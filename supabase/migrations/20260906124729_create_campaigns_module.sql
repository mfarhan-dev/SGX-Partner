-- Module 16 Campaigns.
--
-- This migration establishes the campaign authoring/lifecycle foundation and
-- the durable shapes needed by future progress workers. It does not fabricate
-- progress: wholesaler progress will eventually come from dispatched invoices,
-- mechanic progress from the secure QR redemption flow, and customer progress
-- from delivered orders once those source modules are live.

create sequence if not exists public.campaign_number_seq;

create table public.campaigns (
  id uuid primary key default gen_random_uuid(),
  campaign_no text not null unique
    default ('CMP-' || lpad(nextval('public.campaign_number_seq')::text, 4, '0')),

  -- Drafts require only a useful title. Publication requirements are enforced
  -- by validate_campaign_lifecycle() when status leaves draft.
  title text not null check (char_length(btrim(title)) between 1 and 120),
  description text check (
    description is null or char_length(btrim(description)) between 1 and 1000
  ),
  start_date date,
  end_date date,
  threshold_amount numeric(12, 2) check (
    threshold_amount is null or threshold_amount > 0
  ),
  prize_note text check (
    prize_note is null or char_length(btrim(prize_note)) between 1 and 300
  ),

  -- Keep the Storage path rather than a public URL. The bucket begins private;
  -- mobile delivery can later use signed URLs or audience-aware image access.
  image_storage_path text check (
    image_storage_path is null or char_length(image_storage_path) between 1 and 500
  ),
  image_file_size_bytes integer check (
    image_file_size_bytes is null
    or (image_file_size_bytes > 0 and image_file_size_bytes <= 5242880)
  ),
  image_mime_type text check (
    image_mime_type is null or image_mime_type in ('image/jpeg', 'image/png', 'image/webp')
  ),

  status text not null default 'draft' check (
    status in ('draft', 'scheduled', 'active', 'paused', 'completed', 'cancelled')
  ),
  published_at timestamptz,
  activated_at timestamptz,
  paused_at timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null,

  constraint campaigns_date_pair check (
    (start_date is null and end_date is null)
    or (start_date is not null and end_date is not null)
  ),
  constraint campaigns_date_order check (
    start_date is null or end_date >= start_date
  ),
  constraint campaigns_image_metadata_consistent check (
    (image_storage_path is null and image_file_size_bytes is null and image_mime_type is null)
    or (image_storage_path is not null and image_file_size_bytes is not null and image_mime_type is not null)
  )
);

comment on table public.campaigns is
  'Promotional qualification campaigns. Drafts may be incomplete; publication is guarded by a lifecycle trigger.';

create table public.campaign_audiences (
  campaign_id uuid not null references public.campaigns(id) on delete cascade,
  audience text not null check (audience in ('wholesaler', 'mechanic', 'customer')),
  created_at timestamptz not null default now(),
  primary key (campaign_id, audience)
);

comment on table public.campaign_audiences is
  'One row per audience targeted by a campaign. At least one is required before publication.';

create table public.campaign_progress (
  id uuid primary key default gen_random_uuid(),
  campaign_id uuid not null references public.campaigns(id) on delete cascade,
  audience text not null check (audience in ('wholesaler', 'mechanic', 'customer')),

  -- Wholesalers and mechanics are standalone business records today. Customer
  -- mobile identities will use profiles until/unless Module 06 introduces a
  -- separate customer entity. Exactly one subject reference is required.
  wholesaler_id uuid references public.wholesalers(id),
  mechanic_id uuid references public.mechanics(id),
  customer_profile_id uuid references public.profiles(id),

  -- Frozen display values keep completed results readable after a party rename.
  subject_name_snapshot text not null
    check (char_length(btrim(subject_name_snapshot)) between 1 and 200),
  subject_area_snapshot text check (
    subject_area_snapshot is null or char_length(btrim(subject_area_snapshot)) between 1 and 120
  ),

  progress_amount numeric(14, 2) not null default 0 check (progress_amount >= 0),
  qualified_at timestamptz,
  qualified_value numeric(14, 2) check (
    qualified_value is null or qualified_value >= 0
  ),

  prize_status text not null default 'pending' check (prize_status in ('pending', 'delivered')),
  prize_delivered_at timestamptz,
  prize_delivered_by uuid references public.profiles(id) on delete set null,
  prize_delivery_note text check (
    prize_delivery_note is null or char_length(btrim(prize_delivery_note)) between 1 and 500
  ),

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint campaign_progress_targeted_audience_fk
    foreign key (campaign_id, audience)
    references public.campaign_audiences(campaign_id, audience)
    on delete cascade,

  constraint campaign_progress_subject_matches_audience check (
    (audience = 'wholesaler' and wholesaler_id is not null and mechanic_id is null and customer_profile_id is null)
    or (audience = 'mechanic' and wholesaler_id is null and mechanic_id is not null and customer_profile_id is null)
    or (audience = 'customer' and wholesaler_id is null and mechanic_id is null and customer_profile_id is not null)
  ),
  constraint campaign_progress_qualification_consistent check (
    (qualified_at is null and qualified_value is null)
    or (qualified_at is not null and qualified_value is not null)
  ),
  constraint campaign_progress_prize_consistent check (
    (prize_status = 'pending' and prize_delivered_at is null and prize_delivered_by is null and prize_delivery_note is null)
    or (
      prize_status = 'delivered'
      and qualified_at is not null
      and prize_delivered_at is not null
      and prize_delivered_by is not null
    )
  )
);

comment on table public.campaign_progress is
  'One frozen qualification-progress row per campaign subject. Rows are populated only by trusted source-module processing.';

create unique index campaign_progress_wholesaler_unique
  on public.campaign_progress (campaign_id, wholesaler_id)
  where wholesaler_id is not null;
create unique index campaign_progress_mechanic_unique
  on public.campaign_progress (campaign_id, mechanic_id)
  where mechanic_id is not null;
create unique index campaign_progress_customer_unique
  on public.campaign_progress (campaign_id, customer_profile_id)
  where customer_profile_id is not null;

create table public.campaign_timeline (
  id uuid primary key default gen_random_uuid(),
  campaign_id uuid not null references public.campaigns(id) on delete cascade,
  event_type text not null check (
    event_type in (
      'created', 'updated', 'published', 'started', 'paused', 'resumed',
      'completed', 'cancelled', 'prize_delivered', 'notifications_sent'
    )
  ),
  actor_profile_id uuid references public.profiles(id) on delete set null,
  actor_name_snapshot text not null
    check (char_length(btrim(actor_name_snapshot)) between 1 and 200),
  note text check (note is null or char_length(btrim(note)) between 1 and 500),
  metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(metadata) = 'object'),
  created_at timestamptz not null default now()
);

comment on table public.campaign_timeline is
  'Append-only campaign lifecycle and prize-delivery history.';

create index campaigns_status_dates_idx
  on public.campaigns (status, start_date, end_date);
create index campaigns_created_at_idx
  on public.campaigns (created_at desc);
create index campaign_audiences_audience_idx
  on public.campaign_audiences (audience, campaign_id);
create index campaign_progress_campaign_audience_idx
  on public.campaign_progress (campaign_id, audience);
create index campaign_progress_qualified_idx
  on public.campaign_progress (campaign_id, qualified_at)
  where qualified_at is not null;
create index campaign_timeline_campaign_created_idx
  on public.campaign_timeline (campaign_id, created_at desc);

create trigger campaigns_updated_at
  before update on public.campaigns
  for each row execute function public.handle_updated_at();

create trigger campaign_progress_updated_at
  before update on public.campaign_progress
  for each row execute function public.handle_updated_at();

create or replace function public.validate_campaign_lifecycle()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'DELETE' then
    if old.status <> 'draft' then
      raise exception 'Only a Draft campaign can be deleted.' using errcode = '22023';
    end if;
    return old;
  end if;

  -- Campaign audiences cannot exist before their parent campaign. Requiring
  -- every insert to begin as Draft lets the action create the parent and its
  -- audience rows first, then publish through a guarded status update.
  if tg_op = 'INSERT' and new.status <> 'draft' then
    raise exception 'A campaign must be created as Draft before activation.'
      using errcode = '22023';
  end if;

  if tg_op = 'UPDATE' and new.status <> old.status then
    if old.status = 'draft' and new.status in ('scheduled', 'active') then
      null;
    elsif old.status = 'scheduled' and new.status in ('active', 'paused', 'cancelled') then
      null;
    elsif old.status = 'active' and new.status in ('paused', 'completed', 'cancelled') then
      null;
    elsif old.status = 'paused' and new.status in ('active', 'completed', 'cancelled') then
      null;
    else
      raise exception 'Invalid campaign status transition: % -> %', old.status, new.status
        using errcode = '22023';
    end if;
  end if;

  -- Once published, qualification must remain deterministic. Marketing copy
  -- and artwork may still be corrected on Scheduled campaigns, but changing
  -- dates or the threshold would rewrite who should qualify.
  if tg_op = 'UPDATE' and old.status <> 'draft' and (
    new.start_date is distinct from old.start_date
    or new.end_date is distinct from old.end_date
    or new.threshold_amount is distinct from old.threshold_amount
  ) then
    raise exception 'Published campaign dates and threshold cannot be changed.'
      using errcode = '22023';
  end if;

  if new.status <> 'draft' then
    if new.description is null
      or new.start_date is null
      or new.end_date is null
      or new.threshold_amount is null
      or new.prize_note is null
      or new.image_storage_path is null then
      raise exception 'Campaign must be complete before activation.' using errcode = '23514';
    end if;

    if not exists (
      select 1
      from public.campaign_audiences audience_row
      where audience_row.campaign_id = new.id
    ) then
      raise exception 'Campaign requires at least one target audience before activation.'
        using errcode = '23514';
    end if;
  end if;

  if new.status = 'scheduled' and new.start_date <= current_date then
    raise exception 'A scheduled campaign must start in the future.' using errcode = '23514';
  end if;

  if new.status = 'active' and new.end_date < current_date then
    raise exception 'An ended campaign cannot be activated.' using errcode = '23514';
  end if;

  if tg_op = 'UPDATE' and new.status <> old.status then
    if old.status = 'draft' and new.status <> 'draft' and new.published_at is null then
      new.published_at := now();
    end if;

    if new.status = 'active' then
      if new.activated_at is null then new.activated_at := now(); end if;
      new.paused_at := null;
    elsif new.status = 'paused' then
      new.paused_at := now();
    elsif new.status = 'completed' then
      new.completed_at := now();
    elsif new.status = 'cancelled' then
      new.cancelled_at := now();
    end if;
  end if;

  return new;
end;
$$;

create trigger campaigns_validate_lifecycle
  before insert or update or delete on public.campaigns
  for each row execute function public.validate_campaign_lifecycle();

create or replace function public.guard_campaign_audience_mutation()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  parent_status text;
begin
  select campaign.status into parent_status
  from public.campaigns campaign
  where campaign.id = coalesce(new.campaign_id, old.campaign_id);

  -- A cascading delete may already have removed the parent row. That path is
  -- safe; direct audience mutation is permitted only while the parent is Draft.
  if parent_status is not null and parent_status <> 'draft' then
    raise exception 'Published campaign audiences cannot be changed.'
      using errcode = '22023';
  end if;

  return coalesce(new, old);
end;
$$;

create trigger campaign_audiences_guard_mutation
  before insert or update or delete on public.campaign_audiences
  for each row execute function public.guard_campaign_audience_mutation();

create or replace function public.block_campaign_timeline_mutation()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'campaign_timeline is append-only.' using errcode = '22023';
end;
$$;

create trigger campaign_timeline_no_update
  before update or delete on public.campaign_timeline
  for each row execute function public.block_campaign_timeline_mutation();

alter table public.campaigns enable row level security;
alter table public.campaign_audiences enable row level security;
alter table public.campaign_progress enable row level security;
alter table public.campaign_timeline enable row level security;

-- The current demonstration branch intentionally defers module-level
-- permission enforcement. Match the rest of the live module tables by using
-- the verified active-staff boundary; replace these with resolved Campaign
-- permissions when the dedicated authorization branch resumes.
create policy campaigns_select_staff on public.campaigns
  for select using ((select private.is_staff()));
create policy campaigns_insert_staff on public.campaigns
  for insert with check ((select private.is_staff()));
create policy campaigns_update_staff on public.campaigns
  for update using ((select private.is_staff())) with check ((select private.is_staff()));
create policy campaigns_delete_staff on public.campaigns
  for delete using ((select private.is_staff()));

create policy campaign_audiences_select_staff on public.campaign_audiences
  for select using ((select private.is_staff()));
create policy campaign_audiences_insert_staff on public.campaign_audiences
  for insert with check ((select private.is_staff()));
create policy campaign_audiences_update_staff on public.campaign_audiences
  for update using ((select private.is_staff())) with check ((select private.is_staff()));
create policy campaign_audiences_delete_staff on public.campaign_audiences
  for delete using ((select private.is_staff()));

create policy campaign_progress_select_staff on public.campaign_progress
  for select using ((select private.is_staff()));
create policy campaign_progress_insert_staff on public.campaign_progress
  for insert with check ((select private.is_staff()));
create policy campaign_progress_update_staff on public.campaign_progress
  for update using ((select private.is_staff())) with check ((select private.is_staff()));

create policy campaign_timeline_select_staff on public.campaign_timeline
  for select using ((select private.is_staff()));
create policy campaign_timeline_insert_staff on public.campaign_timeline
  for insert with check ((select private.is_staff()));

-- Mobile-facing campaign artwork starts private. Draft media must never become
-- public merely because it was uploaded. Mobile read access is added with the
-- mobile identity/audience policies, or delivered through signed URLs.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'campaign-images',
  'campaign-images',
  false,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do nothing;

create policy "staff can read campaign images"
on storage.objects for select
to authenticated
using (bucket_id = 'campaign-images' and (select private.is_staff()));

create policy "staff can upload campaign images"
on storage.objects for insert
to authenticated
with check (bucket_id = 'campaign-images' and (select private.is_staff()));

create policy "staff can update campaign images"
on storage.objects for update
to authenticated
using (bucket_id = 'campaign-images' and (select private.is_staff()))
with check (bucket_id = 'campaign-images' and (select private.is_staff()));

create policy "staff can delete campaign images"
on storage.objects for delete
to authenticated
using (bucket_id = 'campaign-images' and (select private.is_staff()));
