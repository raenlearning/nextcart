-- ============================================================
-- Area 1: Voucher / Kupon Diskon
-- ============================================================

create table if not exists vouchers (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  description text,
  discount_type text not null default 'percent' check (discount_type in ('percent', 'fixed')),
  discount_value numeric(12,2) not null check (discount_value >= 0),
  max_discount numeric(12,2),          -- batas maksimal diskon (untuk persen)
  min_purchase numeric(12,2) not null default 0, -- minimal belanja agar valid
  usage_limit int not null default 0,  -- 0 = tanpa batas
  used_count int not null default 0,
  valid_from timestamptz not null default now(),
  valid_until timestamptz,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists vouchers_code_idx on vouchers (code);

-- ============================================================
-- RLS: voucher hanya bisa dibaca (publik), tidak bisa diubah user
-- ============================================================
alter table vouchers enable row level security;

drop policy if exists "vouchers_select" on vouchers;
create policy "vouchers_select" on vouchers for select using (true);