create or replace function public.update_wholesaler_profile(
  p_owner_name text,
  p_area text,
  p_address text default null,
  p_shop_name text default null,
  p_photo_storage_path text default null,
  p_photo_file_size_bytes integer default null,
  p_photo_mime_type text default null,
  p_cnic text default null
)
returns wholesalers
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_uid uuid := auth.uid();
  v_phone_raw text;
  v_phone text;
  v_wholesaler public.wholesalers%rowtype;
begin
  if v_uid is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  if p_shop_name is null or char_length(trim(p_shop_name)) < 2 then
    raise exception 'Shop name is required' using errcode = '23502';
  end if;

  if p_cnic is not null and p_cnic !~ '^[0-9]{5}-[0-9]{7}-[0-9]$' then
    raise exception 'CNIC must be in the format 00000-0000000-0' using errcode = '22023';
  end if;

  if p_photo_storage_path is not null
     and p_photo_storage_path not like (v_uid::text || '/%') then
    raise exception 'Photo path must belong to the current user' using errcode = '42501';
  end if;

  select u.phone into v_phone_raw from auth.users u where u.id = v_uid;
  v_phone := private.normalize_pk_phone(v_phone_raw);
  if v_phone is null then
    raise exception 'No verified phone on this account' using errcode = '22023';
  end if;

  update public.wholesalers as w
  set
    owner_name = p_owner_name,
    phone = v_phone,
    area = p_area,
    address = p_address,
    shop_name = p_shop_name,
    photo_storage_path = coalesce(p_photo_storage_path, w.photo_storage_path),
    photo_file_size_bytes = coalesce(p_photo_file_size_bytes, w.photo_file_size_bytes),
    photo_mime_type = coalesce(p_photo_mime_type, w.photo_mime_type),
    cnic = coalesce(p_cnic, w.cnic),
    updated_by = v_uid
  where w.profile_id = v_uid
  returning * into v_wholesaler;

  if not found then
    raise exception 'No wholesaler profile found for this session' using errcode = '22023';
  end if;

  update public.profiles set full_name = p_owner_name, phone = v_phone where id = v_uid;

  return v_wholesaler;
end;
$function$;

revoke all on function public.update_wholesaler_profile(text, text, text, text, text, integer, text, text) from public;
revoke all on function public.update_wholesaler_profile(text, text, text, text, text, integer, text, text) from anon;
grant execute on function public.update_wholesaler_profile(text, text, text, text, text, integer, text, text) to authenticated;
