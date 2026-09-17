-- products/product_images were staff-only -- a mechanic or wholesaler
-- had zero visibility into the catalog. Per instruction, prices are
-- NOT shown for now, so these deliberately never select any price
-- column (buying_price, customer_price, mechanic_price,
-- wholesaler_price, discount_price) -- only display-safe fields.
-- product-images itself is already a public storage bucket, so no
-- signed-URL/RLS work needed there, just the table-level read.

create or replace function public.get_catalog_products()
returns table(
  id uuid,
  name text,
  category text,
  brand text,
  stock integer,
  cover_image_path text
)
language sql
stable
security definer
set search_path to ''
as $function$
  select
    p.id,
    p.name,
    c.name as category,
    b.name as brand,
    p.stock,
    (
      select pi.storage_path
      from public.product_images pi
      where pi.product_id = p.id
      order by pi.is_cover desc, pi.sort_order asc
      limit 1
    ) as cover_image_path
  from public.products p
  left join public.categories c on c.id = p.category_id
  left join public.brands b on b.id = p.brand_id
  where p.deleted_at is null
  order by p.created_at desc;
$function$;

revoke all on function public.get_catalog_products() from public;
revoke all on function public.get_catalog_products() from anon;
grant execute on function public.get_catalog_products() to authenticated;

create or replace function public.get_catalog_product(p_product_id uuid)
returns table(
  id uuid,
  name text,
  description text,
  category text,
  brand text,
  stock integer,
  image_paths text[]
)
language sql
stable
security definer
set search_path to ''
as $function$
  select
    p.id,
    p.name,
    p.description,
    c.name as category,
    b.name as brand,
    p.stock,
    (
      select array_agg(pi.storage_path order by pi.is_cover desc, pi.sort_order asc)
      from public.product_images pi
      where pi.product_id = p.id
    ) as image_paths
  from public.products p
  left join public.categories c on c.id = p.category_id
  left join public.brands b on b.id = p.brand_id
  where p.id = p_product_id
    and p.deleted_at is null;
$function$;

revoke all on function public.get_catalog_product(uuid) from public;
revoke all on function public.get_catalog_product(uuid) from anon;
grant execute on function public.get_catalog_product(uuid) to authenticated;
