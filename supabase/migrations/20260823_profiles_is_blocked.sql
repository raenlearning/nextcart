-- ============================================================
-- Blokir user: kolom is_blocked di profiles
-- ============================================================

alter table profiles
  add column if not exists is_blocked boolean not null default false;

-- ============================================================
-- RLS: hanya admin boleh mengubah is_blocked user lain.
-- (update profil sendiri tetap mengikuti policy yang sudah ada;
--  policy khusus ini menutup celah perubahan data user lain.)
-- ============================================================

drop policy if exists "profiles_admin_update" on profiles;
create policy "profiles_admin_update" on profiles
  for update to authenticated
  using (
    id = auth.uid()
    or exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  )
  with check (
    id = auth.uid()
    or exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- ============================================================
-- Voucher: policy tulis khusus admin (CRUD dari aplikasi admin)
-- ============================================================

drop policy if exists "vouchers_admin_insert" on vouchers;
create policy "vouchers_admin_insert" on vouchers
  for insert to authenticated
  with check (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

drop policy if exists "vouchers_admin_update" on vouchers;
create policy "vouchers_admin_update" on vouchers
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

drop policy if exists "vouchers_admin_delete" on vouchers;
create policy "vouchers_admin_delete" on vouchers
  for delete to authenticated
  using (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );
