create index campaign_progress_wholesaler_id_idx on public.campaign_progress (wholesaler_id) where wholesaler_id is not null;
create index campaign_progress_mechanic_id_idx on public.campaign_progress (mechanic_id) where mechanic_id is not null;
create index campaign_progress_customer_profile_id_idx on public.campaign_progress (customer_profile_id) where customer_profile_id is not null;
create index campaign_progress_prize_delivered_by_idx on public.campaign_progress (prize_delivered_by) where prize_delivered_by is not null;
create index campaign_timeline_actor_profile_id_idx on public.campaign_timeline (actor_profile_id) where actor_profile_id is not null;
create index campaigns_created_by_idx on public.campaigns (created_by) where created_by is not null;
create index campaigns_updated_by_idx on public.campaigns (updated_by) where updated_by is not null;
