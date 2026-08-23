-- ============================================================
-- Area 5: Ongkos Kirim & Multi-Alamat
-- Mesin tarif simulasi: tarif disimpan di tabel couriers
-- (bebas biaya, siap ditukar ke Biteship/RajaOngkir nanti).
-- ============================================================

-- Alamat pengiriman: tambah field region + kode pos
alter table shipping_addresses add column if not exists province text;
alter table shipping_addresses add column if not exists city text;
alter table shipping_addresses add column if not exists district text;
alter table shipping_addresses add column if not exists postal_code text;

-- Berat produk (gram) untuk kalkulasi ongkir
alter table products add column if not exists weight_grams int not null default 0;

-- Pesanan: simpan referensi alamat, kurir, dan berat total
alter table orders add column if not exists shipping_address_id uuid references shipping_addresses(id) on delete set null;
alter table orders add column if not exists courier_code text;
alter table orders add column if not exists courier_service text;
alter table orders add column if not exists weight_grams int not null default 0;

-- ============================================================
-- Daftar kurir + tarif simulasi
-- ============================================================
create table if not exists couriers (
  id serial primary key,
  code text not null unique,
  name text not null,
  service text,
  base_cost numeric(12,2) not null default 0,
  per_kg numeric(12,2) not null default 0,
  eta_min int not null default 1,
  eta_max int not null default 3,
  is_active boolean not null default true
);

insert into couriers (code, name, service, base_cost, per_kg, eta_min, eta_max) values
  ('jne_reg',    'JNE',      'REG',    15000, 4000, 2, 4),
  ('jne_oke',    'JNE',      'OKE',    18000, 3000, 3, 6),
  ('jnt_express','J&T',      'Express',20000, 3500, 2, 4),
  ('sicepat_reg','SiCepat',  'REG',    22000, 4000, 2, 5),
  ('anteraja',   'AnterAja', 'Reguler',12000, 3000, 3, 6)
on conflict (code) do nothing;

-- ============================================================
-- Pengaturan toko (asal pengiriman)
-- ============================================================
create table if not exists store_settings (
  key text primary key,
  value text
);

insert into store_settings (key, value) values ('origin_postal_code', '20211')
on conflict (key) do nothing;

-- ============================================================
-- RPC get_shipping_rates: hitung tarif semua kurir aktif
-- Biaya = base_cost + per_kg * berat (dibulatkan ke atas per kg).
-- ============================================================
create or replace function get_shipping_rates(
  p_dest_postal text,
  p_dest_city text,
  p_weight_grams int
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_origin_postal text;
  v_weight_kg int;
  v_rates jsonb;
begin
  select value into v_origin_postal
    from store_settings where key = 'origin_postal_code';
  v_origin_postal := coalesce(v_origin_postal, '20211');

  v_weight_kg := greatest(1, ceil(coalesce(p_weight_grams, 1) / 1000.0));

  v_rates := coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'code',         c.code,
        'name',         c.name,
        'service',      coalesce(c.service, ''),
        'price',        round((c.base_cost + c.per_kg * v_weight_kg)::numeric, 0),
        'eta_min',      c.eta_min,
        'eta_max',      c.eta_max
      )
      order by (c.base_cost + c.per_kg * v_weight_kg)
    )
    from couriers c
    where c.is_active = true
  ), '[]'::jsonb);

  return jsonb_build_object(
    'origin_postal_code', v_origin_postal,
    'weight_grams', coalesce(p_weight_grams, 0),
    'rates', v_rates
  );
end;
$$;

grant execute on function get_shipping_rates(text, text, int) to authenticated;
