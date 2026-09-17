-- Enforces the status transitions in Module 09 spec §2.2 at the database
-- level (draft -> invoiced|cancelled, invoiced -> dispatched|cancelled;
-- dispatched and cancelled are terminal) and stamps the matching
-- issued_at/dispatched_at/cancelled_at column so the app doesn't have to
-- remember to set it on every write path.
create or replace function public.enforce_invoice_status_transition()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.status = old.status then
    return new;
  end if;

  if old.status = 'draft' and new.status in ('invoiced', 'cancelled') then
    -- allowed
  elsif old.status = 'invoiced' and new.status in ('dispatched', 'cancelled') then
    -- allowed
  else
    raise exception 'Invalid invoice status transition: % -> %', old.status, new.status
      using errcode = '22023';
  end if;

  if new.status = 'invoiced' and new.issued_at is null then
    new.issued_at := now();
  elsif new.status = 'dispatched' and new.dispatched_at is null then
    new.dispatched_at := now();
  elsif new.status = 'cancelled' and new.cancelled_at is null then
    new.cancelled_at := now();
  end if;

  return new;
end;
$$;

create trigger invoices_status_transition
  before update on public.invoices
  for each row execute function public.enforce_invoice_status_transition();

-- Draft invoices stay editable; once an invoice leaves draft its lines are
-- locked (spec §2.1 Editable column). Insert stays unrestricted so
-- issuing an invoice can write status='invoiced' and its lines in one
-- transaction without ever passing through draft.
create or replace function public.enforce_invoice_lines_locked()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  invoice_status text;
begin
  select status into invoice_status
  from public.invoices
  where id = coalesce(new.invoice_id, old.invoice_id);

  if invoice_status is distinct from 'draft' then
    raise exception 'Invoice lines cannot change once the invoice is no longer a draft.'
      using errcode = '0A000';
  end if;

  return coalesce(new, old);
end;
$$;

create trigger invoice_lines_lock_after_draft
  before update or delete on public.invoice_lines
  for each row execute function public.enforce_invoice_lines_locked();
