-- ============================================================
-- wholesalers + khata_entries, and the khata ledger trigger
--
-- Sales Return (Module 18) settles against a wholesaler's khata,
-- but khata had no home: balances lived in browser localStorage.
-- This gives it one, modelled as an append-only ledger rather
-- than a bare balance column, so the running total can always be
-- explained entry by entry -- which is the whole point of a khata.
--
-- wholesalers.khata_balance is a derived cache of that ledger,
-- maintained by trigger, exactly like products.stock is a cache
-- of stock_adjustments.
-- ============================================================

create table public.wholesalers (
  id uuid primary key default gen_random_uuid(),

  -- Set once the wholesaler logs into the SGX Partners app.
  -- Staff create the account first, so this stays null until then.
  profile_id uuid references public.profiles(id) on delete set null,

  shop_name text not null
    check (char_length(shop_name) between 2 and 100),
  owner_name text not null
    check (char_length(owner_name) between 2 and 100),

  -- Stored as 11 normalized digits (03001234567); the UI formats
  -- the dash in. Unique across all wholesalers per Module 04.
  phone text not null
    check (phone ~ '^03[0-9]{9}$'),

  cnic text
    check (cnic is null or cnic ~ '^[0-9]{5}-[0-9]{7}-[0-9]$'),

  area text not null
    check (area in (
      'Abbottabad', 'Alpuri', 'Bahrain', 'Bannu', 'Batkhela', 'Buner',
      'Charsadda', 'Chitral', 'Dera Ismail Khan', 'Dir (Lower)',
      'Dir (Upper)', 'Hangu', 'Haripur', 'Karak', 'Kohat',
      'Lakki Marwat', 'Malakand', 'Mansehra', 'Mardan', 'Mingora',
      'Nowshera', 'Parachinar', 'Peshawar', 'Risalpur', 'Saidu Sharif',
      'Shabqadar', 'Swabi', 'Tank', 'Timergara', 'Topi', 'Other'
    )),

  address text check (address is null or char_length(address) <= 200),

  -- Object key inside the private wholesaler-photos bucket.
  photo_storage_path text
    check (photo_storage_path is null or char_length(photo_storage_path) between 1 and 500),
  photo_file_size_bytes integer
    check (photo_file_size_bytes is null or (photo_file_size_bytes > 0 and photo_file_size_bytes <= 5242880)),
  photo_mime_type text
    check (photo_mime_type is null or photo_mime_type in ('image/jpeg', 'image/png', 'image/webp')),

  -- Derived from khata_entries by trigger. Never write directly.
  --
  -- Deliberately allowed to go negative: unlike stock, a negative
  -- khata is a real state -- it means SGX owes the wholesaler,
  -- after an overpayment or a sales return larger than the
  -- outstanding balance. Clamping it at zero would silently lose
  -- money the business actually owes.
  khata_balance numeric(12, 2) not null default 0,

  -- Earned when a mechanic scans a QR on this wholesaler's
  -- invoice. Wired with Module 10; stays 0 until then.
  points_balance integer not null default 0
    check (points_balance >= 0),

  is_active boolean not null default true,
  deactivated_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null,

  constraint wholesalers_phone_unique unique (phone),
  constraint wholesalers_cnic_unique unique (cnic),
  constraint wholesalers_photo_storage_path_unique unique (photo_storage_path)
);

create index wholesalers_shop_name_idx on public.wholesalers (shop_name);
create index wholesalers_area_idx on public.wholesalers (area);
create index wholesalers_is_active_idx on public.wholesalers (is_active) where is_active = true;
create index wholesalers_profile_idx on public.wholesalers (profile_id);
create index wholesalers_created_by_idx on public.wholesalers (created_by);
create index wholesalers_updated_by_idx on public.wholesalers (updated_by);

create trigger wholesalers_updated_at
before update on public.wholesalers
for each row execute function public.handle_updated_at();

-- ------------------------------------------------------------
-- khata_entries: the append-only ledger behind khata_balance.
--
-- Debit  = the wholesaler owes more (opening balance, invoice).
-- Credit = the wholesaler owes less (payment, sales return).
-- ------------------------------------------------------------
create table public.khata_entries (
  id uuid primary key default gen_random_uuid(),

  wholesaler_id uuid not null
    references public.wholesalers(id) on delete restrict,

  entry_type text not null
    check (entry_type in (
      'opening_balance',
      'invoice',
      'payment',
      'sales_return'
    )),

  entry_date date not null default current_date,

  -- Invoice number, sales return number (SR-0001), cheque number,
  -- transaction id -- whatever identifies this entry on paper.
  reference text check (reference is null or char_length(reference) <= 50),
  note text check (note is null or char_length(note) <= 200),

  payment_method text
    check (payment_method is null or payment_method in (
      'cash', 'bank_transfer', 'cheque', 'jazzcash', 'easypaisa'
    )),

  debit numeric(12, 2)
    check (debit is null or (debit > 0 and debit <= 9999999.99)),
  credit numeric(12, 2)
    check (credit is null or (credit > 0 and credit <= 9999999.99)),

  -- Filled by the trigger below, not by the application.
  balance_after numeric(12, 2) not null,

  invoice_id uuid,       -- FK added with Module 09 Invoices
  sales_return_id uuid,  -- FK added with Module 18 Sales Return

  created_at timestamptz not null default now(),
  created_by uuid references public.profiles(id) on delete set null,

  -- Every entry moves the balance exactly one way.
  constraint khata_entries_one_sided
    check (num_nonnulls(debit, credit) = 1),

  -- A payment method only makes sense on money coming in.
  constraint khata_entries_payment_method_on_credit
    check (payment_method is null or credit is not null)
);

create index khata_entries_wholesaler_idx on public.khata_entries (wholesaler_id, created_at desc);
create index khata_entries_type_idx on public.khata_entries (entry_type);
create index khata_entries_entry_date_idx on public.khata_entries (entry_date desc);
create index khata_entries_invoice_idx on public.khata_entries (invoice_id);
create index khata_entries_sales_return_idx on public.khata_entries (sales_return_id);
create index khata_entries_created_by_idx on public.khata_entries (created_by);

-- ------------------------------------------------------------
-- Khata ledger. Inserting an entry is the ONLY way the balance
-- moves: the trigger locks the wholesaler row, derives
-- balance_after from the live balance, and writes it back.
-- ------------------------------------------------------------
create or replace function public.apply_khata_entry()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  current_balance numeric(12, 2);
begin
  -- Row lock serializes concurrent entries for the same wholesaler.
  select w.khata_balance into current_balance
  from public.wholesalers w
  where w.id = new.wholesaler_id
  for update;

  if current_balance is null then
    raise exception 'Wholesaler % not found', new.wholesaler_id
      using errcode = '23503';
  end if;

  new.balance_after := current_balance
    + coalesce(new.debit, 0)
    - coalesce(new.credit, 0);

  -- Authorize this one write past the guard trigger below.
  perform set_config('sgx.khata_sync', 'on', true);

  update public.wholesalers
  set khata_balance = new.balance_after
  where id = new.wholesaler_id;

  perform set_config('sgx.khata_sync', 'off', true);

  return new;
end;
$$;

create trigger khata_entries_apply
before insert on public.khata_entries
for each row execute function public.apply_khata_entry();

-- The ledger is append-only. Module 04 states this to the user in
-- the Khata tab helper text; enforce it in the database too.
create or replace function public.block_khata_entry_mutation()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  raise exception 'khata_entries is append-only. Insert a reversing entry instead.'
    using errcode = '0A000';
end;
$$;

create trigger khata_entries_no_update
before update or delete on public.khata_entries
for each row execute function public.block_khata_entry_mutation();

-- khata_balance may only change through the ledger.
create or replace function public.guard_wholesaler_khata_balance()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if new.khata_balance is distinct from old.khata_balance
     and coalesce(current_setting('sgx.khata_sync', true), 'off') <> 'on' then
    raise exception 'wholesalers.khata_balance is derived. Insert a khata_entries row instead of updating the balance directly.'
      using errcode = '0A000';
  end if;
  return new;
end;
$$;

create trigger wholesalers_khata_balance_guard
before update on public.wholesalers
for each row execute function public.guard_wholesaler_khata_balance();

-- ------------------------------------------------------------
-- RLS: staff only for both tables.
--
-- Module 04 deactivates wholesalers rather than deleting them, so
-- khata and invoice history survive. Delete is still granted on
-- wholesalers for one reason: createWholesaler writes the row and
-- its opening-balance entry as two statements, and needs to undo
-- the first if the second fails (same pattern as createClaim).
-- That rollback is safe precisely because khata_entries references
-- wholesalers with `on delete restrict` -- once a single entry
-- exists the row can no longer be deleted, so the escape hatch
-- only ever opens on a wholesaler that has no history yet.
--
-- khata_entries gets no delete policy at all: it is append-only.
-- ------------------------------------------------------------
alter table public.wholesalers enable row level security;
alter table public.khata_entries enable row level security;

create policy wholesalers_select_staff on public.wholesalers
for select to authenticated
using ((select private.is_staff()));

create policy wholesalers_insert_staff on public.wholesalers
for insert to authenticated
with check ((select private.is_staff()));

create policy wholesalers_update_staff on public.wholesalers
for update to authenticated
using ((select private.is_staff()))
with check ((select private.is_staff()));

create policy wholesalers_delete_staff on public.wholesalers
for delete to authenticated
using ((select private.is_staff()));

create policy khata_entries_select_staff on public.khata_entries
for select to authenticated
using ((select private.is_staff()));

create policy khata_entries_insert_staff on public.khata_entries
for insert to authenticated
with check ((select private.is_staff()));

grant select, insert, update, delete on public.wholesalers to authenticated;
grant select, insert on public.khata_entries to authenticated;
