-- Suho sourcing dashboard: run once in Supabase (SQL Editor > New query > Run).
-- Creates the supplier list and quote-request tables, and locks them so only
-- the email addresses listed in public.team can read or change anything.
-- The public quote form may only ADD new requests; it can never read them.

create table if not exists public.team (
  email text primary key
);

-- Team sign-in emails. To add someone later, run:
--   insert into public.team (email) values ('their@email.com');
insert into public.team (email) values
  ('jdwkim0505@gmail.com')
on conflict do nothing;

create table if not exists public.suppliers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  location text,
  status text not null default 'Prospect'
    check (status in ('Prospect','Contacted','Trial job','Approved','Paused')),
  contact text,
  last_contact date,
  processes text[] not null default '{}',
  certs text[] not null default '{}',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.requests (
  id uuid primary key default gen_random_uuid(),
  company text not null,
  contact text,
  email text,
  stage text not null default 'New'
    check (stage in ('New','Quoting','Quoted','Won','In production','Delivered','Lost')),
  parts text,
  qty text,
  supplier_id uuid references public.suppliers(id) on delete set null,
  value numeric,
  due date,
  flags text[] not null default '{}',
  notes text,
  details jsonb,              -- full form submission from the public quote page
  source text not null default 'dashboard',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.touch_updated_at() returns trigger
language plpgsql as $$ begin new.updated_at = now(); return new; end $$;

drop trigger if exists suppliers_touch on public.suppliers;
create trigger suppliers_touch before update on public.suppliers
  for each row execute function public.touch_updated_at();
drop trigger if exists requests_touch on public.requests;
create trigger requests_touch before update on public.requests
  for each row execute function public.touch_updated_at();

-- Is the signed-in user on the team list?
create or replace function public.is_team() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.team where lower(email) = lower(auth.jwt() ->> 'email'));
$$;

alter table public.team      enable row level security;
alter table public.suppliers enable row level security;
alter table public.requests  enable row level security;

drop policy if exists team_read on public.team;
create policy team_read on public.team for select to authenticated using (public.is_team());

drop policy if exists suppliers_team on public.suppliers;
create policy suppliers_team on public.suppliers for all to authenticated
  using (public.is_team()) with check (public.is_team());

drop policy if exists requests_team on public.requests;
create policy requests_team on public.requests for all to authenticated
  using (public.is_team()) with check (public.is_team());

-- Anyone (the public quote form) may insert a new request, nothing else.
drop policy if exists requests_public_insert on public.requests;
create policy requests_public_insert on public.requests for insert to anon
  with check (stage = 'New' and source = 'quote-form' and supplier_id is null and value is null);

grant insert on public.requests to anon;
grant select, insert, update, delete on public.suppliers, public.requests to authenticated;
grant select on public.team to authenticated;
