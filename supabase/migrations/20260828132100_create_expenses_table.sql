create sequence if not exists public.expense_number_seq;

create table public.expenses (
  id uuid primary key default gen_random_uuid(),
  expense_no text not null unique
    default ('EXP-' || lpad(nextval('public.expense_number_seq')::text, 4, '0')),

  expense_date date not null default current_date,
  category text not null check (
    category in (
      'rent', 'electricity', 'salaries', 'transport', 'packaging', 'repairs', 'tea_food', 'other',
      'points_redemption', 'points_withdrawal', 'stock_loss'
    )
  ),
  source text not null default 'manual' check (source in ('manual', 'auto')),
  amount numeric(12, 2) not null check (amount > 0),

  note text check (note is null or char_length(note) <= 500),
  reference text check (reference is null or char_length(reference) <= 200),

  source_type text check (source_type is null or source_type in ('invoice', 'withdrawal', 'claim')),
  source_id uuid,

  receipt_storage_path text
    check (receipt_storage_path is null or char_length(receipt_storage_path) between 1 and 500),
  receipt_file_size_bytes integer
    check (receipt_file_size_bytes is null or (receipt_file_size_bytes > 0 and receipt_file_size_bytes <= 5242880)),
  receipt_mime_type text
    check (receipt_mime_type is null or receipt_mime_type in ('image/jpeg', 'image/png', 'image/webp')),

  deleted_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null,

  constraint expenses_source_matches_link check (
    (source = 'manual' and source_type is null and source_id is null) or
    (source = 'auto' and source_type is not null and source_id is not null)
  )
);

comment on table public.expenses is
  'Business money-out records. Manual rows are staff-entered and editable; auto rows are written by other modules (Invoices, Withdrawals, Claims) and read-only here - fix the source record, not the expense.';

create index expenses_date_idx on public.expenses (expense_date desc) where deleted_at is null;
create index expenses_category_idx on public.expenses (category) where deleted_at is null;
create index expenses_source_idx on public.expenses (source) where deleted_at is null;
create index expenses_source_link_idx on public.expenses (source_type, source_id);

alter table public.expenses enable row level security;

create policy expenses_select_staff on public.expenses
  for select using ((select private.is_staff()));
create policy expenses_insert_staff on public.expenses
  for insert with check ((select private.is_staff()));
create policy expenses_update_staff on public.expenses
  for update using ((select private.is_staff())) with check ((select private.is_staff()));

create trigger expenses_updated_at
  before update on public.expenses
  for each row execute function public.handle_updated_at();

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'expense-receipts',
  'expense-receipts',
  false,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do nothing;

create policy "staff can read expense receipts"
on storage.objects for select
to authenticated
using (bucket_id = 'expense-receipts' and (select private.is_staff()));

create policy "staff can upload expense receipts"
on storage.objects for insert
to authenticated
with check (bucket_id = 'expense-receipts' and (select private.is_staff()));

create policy "staff can update expense receipts"
on storage.objects for update
to authenticated
using (bucket_id = 'expense-receipts' and (select private.is_staff()))
with check (bucket_id = 'expense-receipts' and (select private.is_staff()));

create policy "staff can delete expense receipts"
on storage.objects for delete
to authenticated
using (bucket_id = 'expense-receipts' and (select private.is_staff()));
