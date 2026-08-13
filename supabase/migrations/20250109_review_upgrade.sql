-- ============================================================
-- Area 2: Review lengkap (foto, balasan admin)
-- ============================================================

-- Foto review (array URL) + balasan admin
alter table reviews add column if not exists images jsonb not null default '[]';
alter table reviews add column if not exists reply_text text;
alter table reviews add column if not exists reply_at timestamptz;

-- ============================================================
-- Storage bucket untuk foto review (publik)
-- ============================================================
insert into storage.buckets (id, name, public)
values ('review-images', 'review-images', true)
on conflict (id) do nothing;

drop policy if exists "review_images_select" on storage.objects;
create policy "review_images_select" on storage.objects
  for select using (bucket_id = 'review-images');

drop policy if exists "review_images_insert" on storage.objects;
create policy "review_images_insert" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'review-images');

drop policy if exists "review_images_delete" on storage.objects;
create policy "review_images_delete" on storage.objects
  for delete using (bucket_id = 'review-images');

-- ============================================================
-- RPC reply_review: admin membalas ulasan
-- (security definer agar bisa update review milik user lain).
-- ============================================================
create or replace function reply_review(p_review_id bigint, p_text text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_is_admin boolean;
begin
  select (role = 'admin') into v_is_admin
    from profiles where id = auth.uid();

  if coalesce(v_is_admin, false) = false then
    return jsonb_build_object('ok', false, 'error', 'Hanya admin yang dapat membalas ulasan.');
  end if;

  if p_text is null or trim(p_text) = '' then
    return jsonb_build_object('ok', false, 'error', 'Balasan tidak boleh kosong.');
  end if;

  update reviews
    set reply_text = trim(p_text),
        reply_at = now()
    where id = p_review_id;

  return jsonb_build_object('ok', true);
end;
$$;

grant execute on function reply_review(bigint, text) to authenticated;
