-- ============================================================
-- Area 3: Alamat Pengiriman (CRUD)
-- ============================================================

create table if not exists shipping_addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  label text,                      -- contoh: "Rumah", "Kantor"
  recipient_name text,             -- nama penerima
  phone text,                      -- nomor telepon penerima
  full_address text not null,      -- alamat lengkap
  latitude double precision,       -- opsional: koordinat dari map
  longitude double precision,
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists shipping_addresses_user_idx
  on shipping_addresses (user_id);

-- Paksa hanya satu alamat default per user
create or replace function trg_single_default_address()
returns trigger
language plpgsql
security definer
as $$
begin
  if new.is_default then
    update shipping_addresses
    set is_default = false
    where user_id = new.user_id and id <> new.id;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_single_default_address on shipping_addresses;
create trigger trg_single_default_address
after insert or update of is_default on shipping_addresses
for each row execute function trg_single_default_address();

-- ============================================================
-- RLS
-- ============================================================
alter table shipping_addresses enable row level security;

drop policy if exists "shipping_addresses_select" on shipping_addresses;
create policy "shipping_addresses_select" on shipping_addresses
  for select using (auth.uid() = user_id);

drop policy if exists "shipping_addresses_insert" on shipping_addresses;
create policy "shipping_addresses_insert" on shipping_addresses
  for insert with check (auth.uid() = user_id);

drop policy if exists "shipping_addresses_update" on shipping_addresses;
create policy "shipping_addresses_update" on shipping_addresses
  for update using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "shipping_addresses_delete" on shipping_addresses;
create policy "shipping_addresses_delete" on shipping_addresses
  for delete using (auth.uid() = user_id);