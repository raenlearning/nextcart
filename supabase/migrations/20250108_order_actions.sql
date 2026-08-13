-- ============================================================
-- Area 5: Konfirmasi Terima Pesanan & Auto-Cancel
-- ============================================================

-- Waktu pesanan dikonfirmasi selesai oleh pembeli
alter table orders add column if not exists completed_at timestamptz;

-- ============================================================
-- RPC confirm_order_received: pembeli mengonfirmasi pesanan
-- delivered -> completed (hanya pemilik pesanan).
-- ============================================================
create or replace function confirm_order_received(p_order_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_order orders%rowtype;
begin
  select * into v_order from orders where id = p_order_id;

  if not found then
    return jsonb_build_object('ok', false, 'error', 'Pesanan tidak ditemukan.');
  end if;

  if v_order.user_id <> auth.uid() then
    return jsonb_build_object('ok', false, 'error', 'Anda tidak berhak mengubah pesanan ini.');
  end if;

  if v_order.status <> 'delivered' then
    return jsonb_build_object('ok', false, 'error', 'Pesanan belum berstatus dikirim.');
  end if;

  update orders
    set status = 'completed',
        completed_at = now()
    where id = p_order_id;

  return jsonb_build_object('ok', true);
end;
$$;

grant execute on function confirm_order_received(uuid) to authenticated;

-- ============================================================
-- RPC cancel_expired_orders: auto-cancel pesanan yang belum
-- dibayar melewati batas waktu (default 2 jam).
-- Stok TIDAK dikembalikan karena pemotongan stok terjadi
-- saat pembayaran sukses (settlement).
-- ============================================================
create or replace function cancel_expired_orders()
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count int;
begin
  with updated as (
    update orders
      set status = 'cancelled'
      where status = 'waiting_payment'
        and created_at < now() - interval '2 hours'
      returning id
  )
  select count(*) into v_count from updated;

  -- Tandai payment terkait yang masih pending menjadi expired
  update payments p
    set status = 'expired'
    where p.status = 'pending'
      and exists (
        select 1 from orders o
        where o.id = p.order_id and o.status = 'cancelled'
      );

  return v_count;
end;
$$;

grant execute on function cancel_expired_orders() to service_role;

-- ============================================================
-- Jadwal otomatis: jalankan tiap 5 menit via pg_cron
-- (aktif otomatis di Supabase; di lokal perlu pg_cron diaktifkan).
-- ============================================================
create extension if not exists pg_cron;

select cron.unschedule(jobid)
  from cron.job
  where jobname = 'cancel-expired-orders';

select cron.schedule(
  'cancel-expired-orders',
  '*/5 * * * *',
  'select cancel_expired_orders();'
);
