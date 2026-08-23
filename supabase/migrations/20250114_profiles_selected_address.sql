-- ============================================================
-- Alamat aktif terpilih (sumber tunggal: shipping_addresses)
-- Dipakai oleh home "Kirim ke", profil, dan cart checkout.
-- ============================================================

alter table profiles
  add column if not exists selected_address_id uuid
    references shipping_addresses(id) on delete set null;

create index if not exists profiles_selected_address_idx
  on profiles (selected_address_id);