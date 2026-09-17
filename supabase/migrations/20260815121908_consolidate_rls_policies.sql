-- ============================================================
-- Collapse overlapping permissive policies.
--
-- "for all" write policies also matched SELECT, so every read
-- evaluated two policies. Split writes into insert/update/delete
-- and merge the profiles read/update pairs into single policies.
-- ============================================================

-- profiles: one SELECT policy (own row OR staff), one UPDATE policy.
drop policy profiles_select_own on public.profiles;
drop policy profiles_select_staff on public.profiles;
drop policy profiles_update_own on public.profiles;
drop policy profiles_update_staff on public.profiles;

create policy profiles_select on public.profiles
for select to authenticated
using (
  (select auth.uid()) = id
  or (select private.is_staff())
);

create policy profiles_update on public.profiles
for update to authenticated
using (
  (select auth.uid()) = id
  or (select private.is_staff())
)
with check (
  (select auth.uid()) = id
  or (select private.is_staff())
);

-- categories
drop policy categories_write_staff on public.categories;

create policy categories_insert_staff on public.categories
for insert to authenticated with check ((select private.is_staff()));
create policy categories_update_staff on public.categories
for update to authenticated using ((select private.is_staff()))
with check ((select private.is_staff()));
create policy categories_delete_staff on public.categories
for delete to authenticated using ((select private.is_staff()));

-- brands
drop policy brands_write_staff on public.brands;

create policy brands_insert_staff on public.brands
for insert to authenticated with check ((select private.is_staff()));
create policy brands_update_staff on public.brands
for update to authenticated using ((select private.is_staff()))
with check ((select private.is_staff()));
create policy brands_delete_staff on public.brands
for delete to authenticated using ((select private.is_staff()));

-- products
drop policy products_write_staff on public.products;

create policy products_insert_staff on public.products
for insert to authenticated with check ((select private.is_staff()));
create policy products_update_staff on public.products
for update to authenticated using ((select private.is_staff()))
with check ((select private.is_staff()));
create policy products_delete_staff on public.products
for delete to authenticated using ((select private.is_staff()));

-- product_images
drop policy product_images_write_staff on public.product_images;

create policy product_images_insert_staff on public.product_images
for insert to authenticated with check ((select private.is_staff()));
create policy product_images_update_staff on public.product_images
for update to authenticated using ((select private.is_staff()))
with check ((select private.is_staff()));
create policy product_images_delete_staff on public.product_images
for delete to authenticated using ((select private.is_staff()));

-- claims
drop policy claims_write_staff on public.claims;

create policy claims_insert_staff on public.claims
for insert to authenticated with check ((select private.is_staff()));
create policy claims_update_staff on public.claims
for update to authenticated using ((select private.is_staff()))
with check ((select private.is_staff()));
create policy claims_delete_staff on public.claims
for delete to authenticated using ((select private.is_staff()));
