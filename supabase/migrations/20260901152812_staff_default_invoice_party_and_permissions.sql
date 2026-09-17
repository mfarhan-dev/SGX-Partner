alter table public.profiles
  add column default_invoice_party text
    check (default_invoice_party is null or default_invoice_party in ('wholesaler', 'mechanic'));

alter table public.profiles
  add column permission_overrides jsonb;
