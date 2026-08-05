-- ============================================================
-- Area 2: Review & Rating Produk
-- ============================================================

create table if not exists reviews (
  id bigserial primary key,
  product_id uuid not null references products(id) on delete cascade,
  user_id uuid not null references profiles(id) on delete cascade,
  rating int not null check (rating between 1 and 5),
  title text,
  comment text,
  created_at timestamptz not null default now(),
  unique (product_id, user_id)
);

-- Denormalisasi rating rata-rata pada tabel product untuk performa & query mudah
alter table products add column if not exists total_rating numeric(3,2) not null default 0;
alter table products add column if not exists rating_count int not null default 0;

-- Fungsi untuk menghitung ulang rating rata-rata sebuah produk
create or replace function update_product_rating(p_product_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update products p
  set total_rating   = coalesce(
        round((select avg(rating)::numeric from reviews where product_id = p_product_id), 2),
        0
      ),
      rating_count   = (select count(*) from reviews r where r.product_id = p_product_id)
  where p.id = p_product_id;
end;
$$;

-- Trigger agar total_rating / rating_count selalu sinkron
create or replace function trg_review_rating()
returns trigger
language plpgsql
security definer
as $$
begin
  perform update_product_rating(
    case when tg_op = 'DELETE' then old.product_id else new.product_id end
  );
  return coalesce(new, old);
end;
$$;

drop trigger if exists review_rating_trigger on reviews;
create trigger review_rating_trigger
after insert or update or delete on reviews
for each row execute function trg_review_rating();

-- ============================================================
-- Kebijakan RLS: user dapat membaca semua review, hanya menulis review miliknya
-- ============================================================
alter table reviews enable row level security;

drop policy if exists "reviews_select" on reviews;
create policy "reviews_select" on reviews for select using (true);

drop policy if exists "reviews_insert" on reviews;
create policy "reviews_insert" on reviews
  for insert with check (auth.uid() = user_id);

drop policy if exists "reviews_update" on reviews;
create policy "reviews_update" on reviews
  for update using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "reviews_delete" on reviews;
create policy "reviews_delete" on reviews
  for delete using (auth.uid() = user_id);