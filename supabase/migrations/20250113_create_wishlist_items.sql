-- ============================================================
-- Area 7: Wishlist Produk User
-- Membuat schema reproducible + unique constraint + RLS
-- (tabel ini sebelumnya dibuat manual di Dashboard)
-- ============================================================

create table if not exists wishlist_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  product_id uuid not null references products(id) on delete cascade,
  created_at timestamptz not null default now()
);

-- Index lookup per user + per produk
create index if not exists wishlist_items_user_idx
  on wishlist_items (user_id);

create index if not exists wishlist_items_product_idx
  on wishlist_items (product_id);

-- Uniqueness: satu produk hanya sekali per user (cegah duplikat)
do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'wishlist_items_user_product_unique'
      and conrelid = 'wishlist_items'::regclass
  ) then
    alter table wishlist_items
      add constraint wishlist_items_user_product_unique
      unique (user_id, product_id);
  end if;
end;
$$;

-- ============================================================
-- RLS
-- ============================================================
alter table wishlist_items enable row level security;

drop policy if exists "wishlist_items_select" on wishlist_items;
create policy "wishlist_items_select" on wishlist_items
  for select using (auth.uid() = user_id);

drop policy if exists "wishlist_items_insert" on wishlist_items;
create policy "wishlist_items_insert" on wishlist_items
  for insert with check (auth.uid() = user_id);

drop policy if exists "wishlist_items_delete" on wishlist_items;
create policy "wishlist_items_delete" on wishlist_items
  for delete using (auth.uid() = user_id);