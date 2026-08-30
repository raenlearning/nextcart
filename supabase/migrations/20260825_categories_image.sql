-- ============================================================
-- Kategori: kolom image_url + bucket Storage "category-images"
-- ============================================================

alter table categories add column if not exists image_url text;

-- Bucket (public read agar URL bisa ditampilkan langsung)
insert into storage.buckets (id, name, public)
values ('category-images', 'category-images', true)
on conflict (id) do nothing;

-- Read: publik
drop policy if exists "category_images_public_read" on storage.objects;
create policy "category_images_public_read" on storage.objects
  for select using (bucket_id = 'category-images');

-- Write/Update/Delete: hanya admin
drop policy if exists "category_images_admin_write" on storage.objects;
create policy "category_images_admin_write" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'category-images'
    and exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

drop policy if exists "category_images_admin_update" on storage.objects;
create policy "category_images_admin_update" on storage.objects
  for update to authenticated
  using (
    bucket_id = 'category-images'
    and exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  )
  with check (bucket_id = 'category-images');

drop policy if exists "category_images_admin_delete" on storage.objects;
create policy "category_images_admin_delete" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'category-images'
    and exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );
