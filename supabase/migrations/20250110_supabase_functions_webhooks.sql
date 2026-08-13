-- ============================================================
-- Provisioning supabase_functions schema (Database Webhooks)
-- ============================================================

create schema if not exists supabase_functions;

-- internal representation of migrations on the supabase_functions schema
create table if not exists supabase_functions.migrations (
  version text primary key,
  inserted_at timestamptz not null default now()
);

-- Initial supabase_functions migration
insert into supabase_functions.migrations (version, inserted_at)
values ('initial', now())
on conflict (version) do nothing;

-- hooks audit table
create table if not exists supabase_functions.hooks (
  id bigserial primary key,
  hook_table_id integer not null,
  hook_name text not null,
  created_at timestamptz not null default now(),
  request_id bigint
);

create index if not exists supabase_functions_hooks_request_id_idx on supabase_functions.hooks using btree (request_id);
create index if not exists supabase_functions_hooks_h_table_id_h_name_idx on supabase_functions.hooks using btree (hook_table_id, hook_name);

comment on table supabase_functions.hooks is 'Supabase Functions Hooks: Audit trail for triggered hooks.';

create or replace function supabase_functions.http_request()
returns trigger
language plpgsql
as $function$
declare
  request_id bigint;
  payload jsonb;
  url text := tg_argv[0]::text;
  method text := tg_argv[1]::text;
  headers jsonb default '{}'::jsonb;
  params jsonb default '{}'::jsonb;
  timeout_ms integer default 1000;
begin

  if tg_argv[1] in ('POST', 'GET') then
    method := tg_argv[1];
  end if;

  if tg_argv[2] is not null then
    headers := tg_argv[2];
  end if;

  if tg_argv[3] is not null then
    params := tg_argv[3];
  end if;

  if tg_argv[4] is not null then
    timeout_ms := tg_argv[4];
  end if;

  payload := jsonb_build_object(
    'type', tg_op,
    'table', tg_table_name,
    'schema', tg_table_schema,
    'record', case when tg_op = 'DELETE' then null else to_jsonb(new) end,
    'old_record', case when tg_op = 'INSERT' then null else to_jsonb(old) end
  );

  select
    net.http_post(
      url,
      payload,
      method,
      headers,
      timeout_ms
    )
  into request_id;

  insert into supabase_functions.hooks
    (hook_table_id, hook_name, request_id, created_at)
  values
    (1, tg_argv[0], request_id, now());

  return coalesce(new, old);
end;
$function$;

set search_path = public;

grant usage on schema supabase_functions to postgres, anon, authenticated, service_role;
revoke all on function supabase_functions.http_request() from public;
grant execute on function supabase_functions.http_request() to postgres, anon, authenticated, service_role;

grant insert, update, delete on supabase_functions.hooks to postgres, anon, authenticated, service_role;
grant select on supabase_functions.hooks to postgres, anon, authenticated, service_role;
grant all on supabase_functions.migrations to postgres, anon, authenticated, service_role;
grant usage on sequence supabase_functions.hooks_id_seq to postgres, anon, authenticated, service_role;
