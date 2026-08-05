-- ============================================================
-- Area 4: Notifikasi (in-app) + FCM push tokens
-- ============================================================

-- Token FCM per user untuk push notification
create table if not exists push_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  token text not null,
  platform text not null default 'mobile',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, token)
);

create index if not exists push_tokens_user_idx on push_tokens (user_id);

-- Notifikasi in-app yang ditampilkan di aplikasi
create table if not exists notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  title text not null,
  body text,
  type text not null default 'general',  -- order, promo, wallet, shop, general
  data jsonb,                            -- payload tambahan (mis. order_id)
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists notifications_user_idx
  on notifications (user_id, created_at desc);

-- ============================================================
-- Trigger: notifikasi saat status pesanan berubah
-- ============================================================
create or replace function trg_order_status_notification()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_status_label text;
  v_title text;
  v_body text;
begin
  if new.status = old.status then
    return new;
  end if;

  v_status_label := case new.status
    when 'waiting_payment' then 'Menunggu Pembayaran'
    when 'processing'      then 'Diproses'
    when 'delivered'       then 'Dikirim'
    when 'completed'       then 'Selesai'
    when 'cancelled'       then 'Dibatalkan'
    else new.status
  end;

  v_title := 'Status Pesanan Diperbarui';
  v_body := format('Pesanan kamu sekarang berstatus: %s.', v_status_label);

  insert into notifications (user_id, title, body, type, data)
  values (
    new.user_id,
    v_title,
    v_body,
    'order',
    jsonb_build_object('order_id', new.id, 'status', new.status)
  );

  return new;
end;
$$;

drop trigger if exists trg_order_status_notification on orders;
create trigger trg_order_status_notification
after update of status on orders
for each row execute function trg_order_status_notification();

-- ============================================================
-- RLS
-- ============================================================
alter table notifications enable row level security;
alter table push_tokens enable row level security;

drop policy if exists "notifications_select" on notifications;
create policy "notifications_select" on notifications
  for select using (auth.uid() = user_id);

drop policy if exists "notifications_insert" on notifications;
create policy "notifications_insert" on notifications
  for insert with check (auth.uid() = user_id);

drop policy if exists "notifications_update" on notifications;
create policy "notifications_update" on notifications
  for update using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "notifications_delete" on notifications;
create policy "notifications_delete" on notifications
  for delete using (auth.uid() = user_id);

drop policy if exists "push_tokens_select" on push_tokens;
create policy "push_tokens_select" on push_tokens
  for select using (auth.uid() = user_id);

drop policy if exists "push_tokens_insert" on push_tokens;
create policy "push_tokens_insert" on push_tokens
  for insert with check (auth.uid() = user_id);

drop policy if exists "push_tokens_update" on push_tokens;
create policy "push_tokens_update" on push_tokens
  for update using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "push_tokens_delete" on push_tokens;
create policy "push_tokens_delete" on push_tokens
  for delete using (auth.uid() = user_id);