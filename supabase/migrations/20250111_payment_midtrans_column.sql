-- ============================================================
-- Area 6: Payment — pastikan kolom midtrans_transaction_id ada
-- (dipakai oleh fungsi midtrans-webhook, bukan menimpa midtrans_id)
-- ============================================================

alter table payments add column if not exists midtrans_transaction_id text;

-- Index lookup webhook berdasarkan midtrans_id (order id dari Midtrans)
create index if not exists payments_midtrans_id_idx on payments (midtrans_id);
