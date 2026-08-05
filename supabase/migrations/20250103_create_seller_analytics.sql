-- ============================================================
-- Area 2 (lanjutan): RPC get_seller_analytics untuk dashboard admin
-- ============================================================

-- RPC yang dipanggil admin_analytic_bloc. Mengembalikan ringkasan penjualan
-- untuk semua pesanan (full) yang dibuat sejak p_from.
create or replace function get_seller_analytics(p_from timestamptz)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_from timestamptz := coalesce(p_from, now() - interval '30 days');
  v_result jsonb;
begin
  select jsonb_build_object(
    'gross_revenue',
      coalesce(sum(o.total_amount) filter (where o.status in ('completed', 'delivered')), 0),
    'completed_orders',
      count(*) filter (where o.status in ('completed', 'delivered')),
    'total_products',
      (select count(*) from products where is_active = true),
    'revenue_chart',
      coalesce((
        select jsonb_agg(jsonb_build_object('date', day, 'amount', amount) order by day)
        from (
          select date_trunc('day', o.created_at)::date as day,
                 sum(o.total_amount) as amount
          from orders o
          where o.created_at >= v_from
            and o.status in ('completed', 'delivered')
          group by date_trunc('day', o.created_at)::date
        ) rc
      ), '[]'::jsonb),
    'order_status_breakdown',
      coalesce((
        select jsonb_object_agg(status, c)
        from (select status, count(*) c from orders group by status) s
      ), '{}'::jsonb),
    'top_products',
      coalesce((
        select jsonb_agg(x order by x.qty_sold desc)
        from (
          select p.id,
                 p.name,
                 p.images[1] as image,
                 coalesce(sum(oi.quantity), 0) as qty_sold
          from order_items oi
          join orders o on o.id = oi.order_id
          join products p on p.id = oi.product_id
          where o.created_at >= v_from
            and o.status in ('completed', 'delivered')
          group by p.id, p.name, p.images
          limit 5
        ) x
      ), '[]'::jsonb)
  ) into v_result;

  return v_result;
end;
$$;