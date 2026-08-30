-- ============================================================
-- Kategori: policy tulis khusus admin (CRUD dari aplikasi admin)
-- ============================================================

alter table categories enable row level security;

drop policy if exists "categories_select" on categories;
create policy "categories_select" on categories
  for select using (true);

drop policy if exists "categories_admin_insert" on categories;
create policy "categories_admin_insert" on categories
  for insert to authenticated
  with check (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

drop policy if exists "categories_admin_update" on categories;
create policy "categories_admin_update" on categories
  for update to authenticated
  using (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  )
  with check (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

drop policy if exists "categories_admin_delete" on categories;
create policy "categories_admin_delete" on categories
  for delete to authenticated
  using (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );
