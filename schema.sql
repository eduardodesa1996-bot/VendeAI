-- VendeAI starter schema for Supabase. Apply in Supabase SQL Editor.
-- Enable RLS and use policies; never expose service-role credentials in client code.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now()
);
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(), user_id uuid references auth.users(id) on delete cascade,
  title text not null, source text, product_url text, affiliate_url text,
  price numeric(12,2), commission_estimate numeric(12,2), status text not null default 'research',
  created_at timestamptz not null default now()
);
create table if not exists public.campaigns (
  id uuid primary key default gen_random_uuid(), user_id uuid references auth.users(id) on delete cascade,
  product_title text, channel text, content text, status text not null default 'draft',
  created_at timestamptz not null default now()
);
create table if not exists public.agent_runs (
  id uuid primary key default gen_random_uuid(), user_id uuid references auth.users(id) on delete cascade,
  category text, objective text, status text not null default 'queued', log jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);
create table if not exists public.commission_events (
  id uuid primary key default gen_random_uuid(), user_id uuid references auth.users(id) on delete cascade,
  external_reference text, source text, amount numeric(12,2) not null default 0,
  status text not null default 'pending', occurred_at timestamptz, created_at timestamptz not null default now()
);
create table if not exists public.withdrawals (
  id uuid primary key default gen_random_uuid(), user_id uuid references auth.users(id) on delete cascade,
  amount numeric(12,2) not null check(amount >= 10), pix_key text,
  status text not null default 'requested', created_at timestamptz not null default now()
);
create table if not exists public.subscriptions (
  id uuid primary key default gen_random_uuid(), user_id uuid references auth.users(id) on delete cascade,
  plan_code text not null, status text not null default 'pending', provider_reference text,
  created_at timestamptz not null default now()
);
-- Enable row-level security
alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.campaigns enable row level security;
alter table public.agent_runs enable row level security;
alter table public.commission_events enable row level security;
alter table public.withdrawals enable row level security;
alter table public.subscriptions enable row level security;
-- Remove named policies first so this script can be rerun safely.
drop policy if exists "profile own select" on public.profiles;
drop policy if exists "profile own insert" on public.profiles;
drop policy if exists "profile own update" on public.profiles;
drop policy if exists "products own rows" on public.products;
drop policy if exists "campaigns own rows" on public.campaigns;
drop policy if exists "agent_runs own rows" on public.agent_runs;
drop policy if exists "commission own read" on public.commission_events;
drop policy if exists "withdrawals own read" on public.withdrawals;
drop policy if exists "subscriptions own read" on public.subscriptions;
-- User can read/update their own profile
create policy "profile own select" on public.profiles for select using (auth.uid()=id);
create policy "profile own insert" on public.profiles for insert with check (auth.uid()=id);
create policy "profile own update" on public.profiles for update using (auth.uid()=id) with check (auth.uid()=id);
-- Own rows for other tables
create policy "products own rows" on public.products for all using (auth.uid()=user_id) with check (auth.uid()=user_id);
create policy "campaigns own rows" on public.campaigns for all using (auth.uid()=user_id) with check (auth.uid()=user_id);
create policy "agent_runs own rows" on public.agent_runs for all using (auth.uid()=user_id) with check (auth.uid()=user_id);
create policy "commission own read" on public.commission_events for select using (auth.uid()=user_id);
create policy "withdrawals own read" on public.withdrawals for select using (auth.uid()=user_id);
create policy "subscriptions own read" on public.subscriptions for select using (auth.uid()=user_id);
-- IMPORTANT: payout records, commissions, subscriptions and ledger mutations should be created
-- by trusted server functions/webhooks, not by the browser. Policies intentionally don't allow
-- client INSERT/UPDATE for these financial tables.

-- Automatically create a profile when a user signs up (safe to rerun).
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path=public as $$
begin
  insert into public.profiles(id,display_name) values (new.id, coalesce(new.raw_user_meta_data->>'display_name',''))
  on conflict (id) do nothing;
  return new;
end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();
