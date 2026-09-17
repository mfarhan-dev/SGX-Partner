-- ============================================================
-- product_images + Storage bucket
--
-- Replaces the single image_url column in the Module 03 spec.
-- The product form already ships an 8-slot gallery whose first
-- slot is the cover, so the data model matches the built UI.
-- ============================================================

create table public.product_images (
  id uuid primary key default gen_random_uuid(),

  product_id uuid not null
    references public.products(id) on delete cascade,

  -- Object key inside the product-images bucket.
  storage_path text not null
    check (char_length(storage_path) between 1 and 500),

  -- 1 = cover slot in the form, 2..8 follow.
  sort_order smallint not null default 1
    check (sort_order between 1 and 8),

  is_cover boolean not null default false,

  alt_text text
    check (alt_text is null or char_length(alt_text) <= 200),

  file_size_bytes integer
    check (file_size_bytes is null or (file_size_bytes > 0 and file_size_bytes <= 5242880)),

  mime_type text
    check (mime_type is null or mime_type in ('image/jpeg', 'image/png', 'image/webp')),

  created_at timestamptz not null default now(),
  created_by uuid references public.profiles(id) on delete set null,

  constraint product_images_storage_path_unique unique (storage_path),
  constraint product_images_slot_unique unique (product_id, sort_order)
);

create index product_images_product_idx on public.product_images (product_id);
create index product_images_created_by_idx on public.product_images (created_by);

-- Exactly one cover per product.
create unique index product_images_one_cover_idx
  on public.product_images (product_id)
  where is_cover = true;

-- ------------------------------------------------------------
-- Cap at 8 images per product, matching the form's
-- "Maximum 8 images allowed." guard.
-- ------------------------------------------------------------
create or replace function public.enforce_product_image_limit()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  existing_count integer;
begin
  select count(*) into existing_count
  from public.product_images
  where product_id = new.product_id;

  if existing_count >= 8 then
    raise exception 'Maximum 8 images allowed.'
      using errcode = '23514';
  end if;

  return new;
end;
$$;

create trigger product_images_limit
before insert on public.product_images
for each row execute function public.enforce_product_image_limit();

-- ------------------------------------------------------------
-- RLS: metadata is staff-only, same as products.
-- ------------------------------------------------------------
alter table public.product_images enable row level security;

create policy product_images_select_staff on public.product_images
for select to authenticated
using ((select private.is_staff()));

create policy product_images_write_staff on public.product_images
for all to authenticated
using ((select private.is_staff()))
with check ((select private.is_staff()));

grant select, insert, update, delete on public.product_images to authenticated;

-- ------------------------------------------------------------
-- Storage bucket: public reads so the Flutter catalogs load from
-- CDN without signed-URL round trips. Writes are staff-only.
-- 5 MB / JPEG-PNG-WebP enforced server-side per the threat model.
-- ------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'product-images',
  'product-images',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do nothing;

create policy "product images are publicly readable"
on storage.objects for select
to public
using (bucket_id = 'product-images');

create policy "staff can upload product images"
on storage.objects for insert
to authenticated
with check (bucket_id = 'product-images' and (select private.is_staff()));

create policy "staff can update product images"
on storage.objects for update
to authenticated
using (bucket_id = 'product-images' and (select private.is_staff()))
with check (bucket_id = 'product-images' and (select private.is_staff()));

create policy "staff can delete product images"
on storage.objects for delete
to authenticated
using (bucket_id = 'product-images' and (select private.is_staff()));
