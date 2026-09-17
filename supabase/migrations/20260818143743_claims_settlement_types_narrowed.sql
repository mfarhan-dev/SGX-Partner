alter table public.claims
  drop constraint claims_settlement_type_check;

alter table public.claims
  add constraint claims_settlement_type_check
    check (settlement_type is null or settlement_type in ('replacement_stock', 'credit_note'));
