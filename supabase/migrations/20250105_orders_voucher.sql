-- ============================================================
-- Area 1: Terapkan voucher ke order / checkout
-- ============================================================

alter table orders add column if not exists voucher_id uuid references vouchers(id);
alter table orders add column if not exists voucher_code text;
alter table orders add column if not exists discount_amount numeric(12,2) not null default 0;
alter table orders add column if not exists delivery_fee numeric(12,2) not null default 0;
alter table orders add column if not exists tax_amount numeric(12,2) not null default 0;

-- ============================================================
-- RPC redeem_voucher: validasi + klaim voucher dalam satu transaksi
-- Mengunci baris voucher (SELECT ... FOR UPDATE) agar aman dari
-- pemakaian ganda secara bersamaan (anti race condition).
-- ============================================================
create or replace function redeem_voucher(p_code text, p_order_total numeric)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_voucher vouchers%rowtype;
  v_discount numeric;
  v_max_discount numeric;
  v_error text;
begin
  select *
    into v_voucher
    from vouchers
    where code = trim(p_code)
      and is_active = true
    for update;

  if not found then
    return jsonb_build_object('valid', false, 'error', 'Kode voucher tidak valid.');
  end if;

  if v_voucher.valid_from > now() then
    v_error := 'Voucher belum aktif.';
  elsif v_voucher.valid_until is not null and v_voucher.valid_until < now() then
    v_error := 'Voucher sudah kedaluwarsa.';
  elsif p_order_total < v_voucher.min_purchase then
    v_error := format('Minimal belanja Rp %s untuk voucher ini.', round(v_voucher.min_purchase)::text);
  elsif v_voucher.usage_limit > 0 and v_voucher.used_count >= v_voucher.usage_limit then
    v_error := 'Voucher sudah habis digunakan.';
  end if;

  if v_error is not null then
    return jsonb_build_object('valid', false, 'error', v_error);
  end if;

  -- Hitung diskon
  if v_voucher.discount_type = 'percent' then
    v_discount := p_order_total * v_voucher.discount_value / 100;
    v_max_discount := coalesce(v_voucher.max_discount, 0);
    if v_max_discount > 0 and v_discount > v_max_discount then
      v_discount := v_max_discount;
    end if;
  else
    v_discount := v_voucher.discount_value;
    if v_discount > p_order_total then
      v_discount := p_order_total;
    end if;
  end if;

  -- Tandai voucher sudah terpakai
  update vouchers
    set used_count = used_count + 1
    where id = v_voucher.id;

  return jsonb_build_object(
    'valid', true,
    'voucher_id', v_voucher.id,
    'code', v_voucher.code,
    'discount_type', v_voucher.discount_type,
    'discount_value', v_voucher.discount_value,
    'discount_amount', v_discount
  );
end;
$$;