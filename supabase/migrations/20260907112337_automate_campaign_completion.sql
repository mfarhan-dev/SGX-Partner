create extension if not exists pg_cron with schema pg_catalog;

create or replace function private.complete_ended_campaigns()
returns integer
language plpgsql
set search_path = ''
as $$
declare
  completed_campaign record;
  completed_count integer := 0;
begin
  for completed_campaign in
    update public.campaigns
    set status = 'completed',
        updated_by = null
    where status = 'active'
      and end_date < (now() at time zone 'Asia/Karachi')::date
    returning id, campaign_no, title, end_date
  loop
    insert into public.campaign_timeline (
      campaign_id,
      event_type,
      actor_name_snapshot,
      note,
      metadata
    ) values (
      completed_campaign.id,
      'completed',
      'System',
      'Campaign automatically completed after its end date.',
      jsonb_build_object('source', 'scheduled_job')
    );

    insert into public.audit_logs (
      actor_name,
      actor_role,
      module,
      action,
      target,
      summary,
      outcome,
      source,
      session_id,
      before_snapshot,
      after_snapshot
    ) values (
      'System',
      'System',
      'System',
      'Campaign Auto-Completed',
      completed_campaign.campaign_no,
      format(
        'Campaign %s automatically completed after ending on %s.',
        completed_campaign.campaign_no,
        completed_campaign.end_date
      ),
      'success',
      'scheduled_job',
      'job_campaign_lifecycle',
      jsonb_build_object('status', 'Active'),
      jsonb_build_object('status', 'Completed')
    );

    completed_count := completed_count + 1;
  end loop;

  return completed_count;
end;
$$;

revoke all on function private.complete_ended_campaigns() from public, anon, authenticated;

select cron.schedule(
  'sgx-complete-ended-campaigns',
  '*/5 * * * *',
  'select private.complete_ended_campaigns();'
);

select private.complete_ended_campaigns();
