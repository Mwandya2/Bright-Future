-- ============================================================================
-- Bright Future Digital Hub — Supabase schema
-- Run this whole file in: Supabase Dashboard → SQL Editor → New query → Run
-- Safe to re-run (uses IF NOT EXISTS / CREATE OR REPLACE / DROP POLICY IF EXISTS).
-- ============================================================================

-- ─── Extensions ────────────────────────────────────────────────────────────
create extension if not exists "pgcrypto";

-- ─── Enums ─────────────────────────────────────────────────────────────────
do $$ begin
  create type user_role as enum ('student', 'instructor', 'admin');
exception when duplicate_object then null; end $$;

do $$ begin
  create type course_level as enum ('beginner', 'intermediate', 'advanced');
exception when duplicate_object then null; end $$;

do $$ begin
  create type booking_status as enum ('pending', 'confirmed', 'completed', 'cancelled');
exception when duplicate_object then null; end $$;

do $$ begin
  create type order_status as enum ('submitted', 'in_progress', 'ready', 'collected', 'cancelled');
exception when duplicate_object then null; end $$;

-- ============================================================================
-- PROFILES  (1:1 with auth.users)
-- ============================================================================
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  full_name   text,
  email       text,
  phone       text,
  role        user_role not null default 'student',
  avatar_url  text,
  created_at  timestamptz not null default now()
);

-- Auto-create a profile whenever a new auth user is created.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    new.email
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Admin check helper. SECURITY DEFINER → runs as owner and bypasses RLS on
-- profiles, so it can be used inside profiles policies without recursion.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- ============================================================================
-- COURSES
-- ============================================================================
create table if not exists public.courses (
  id              uuid primary key default gen_random_uuid(),
  title           text not null,
  slug            text unique not null,
  summary         text,
  description     text,
  category        text default 'ict',
  level           course_level not null default 'beginner',
  price           integer not null default 0,          -- TZS
  duration_weeks  integer default 4,
  instructor_name text,
  cover_gradient  text default 'mint',
  is_published    boolean not null default false,
  created_at      timestamptz not null default now()
);

-- ============================================================================
-- ENROLLMENTS
-- ============================================================================
create table if not exists public.enrollments (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  course_id  uuid not null references public.courses(id) on delete cascade,
  status     text not null default 'active',   -- active | completed | cancelled
  progress   integer not null default 0,
  created_at timestamptz not null default now(),
  unique (user_id, course_id)
);

-- ============================================================================
-- LAB BOOKINGS
-- ============================================================================
create table if not exists public.lab_bookings (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references auth.users(id) on delete cascade,
  workstation_type text not null default 'computer',
  booking_date     date not null,
  start_time       time not null,
  duration_hours   integer not null default 1,
  status           booking_status not null default 'pending',
  notes            text,
  created_at       timestamptz not null default now()
);

-- ============================================================================
-- PRINT ORDERS
-- ============================================================================
create table if not exists public.print_orders (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references auth.users(id) on delete cascade,
  service_type    text not null default 'document',
  description     text,
  copies          integer not null default 1,
  color           boolean not null default false,
  status          order_status not null default 'submitted',
  estimated_price integer,
  created_at      timestamptz not null default now()
);

-- Helpful indexes
create index if not exists idx_enrollments_user on public.enrollments(user_id);
create index if not exists idx_bookings_user on public.lab_bookings(user_id);
create index if not exists idx_orders_user on public.print_orders(user_id);
create index if not exists idx_courses_published on public.courses(is_published);

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================
alter table public.profiles     enable row level security;
alter table public.courses      enable row level security;
alter table public.enrollments  enable row level security;
alter table public.lab_bookings enable row level security;
alter table public.print_orders enable row level security;

-- ─── Profiles ──────────────────────────────────────────────────────────────
drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = id or public.is_admin());

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id or public.is_admin());

-- ─── Courses (public read of published; admins manage) ─────────────────────
drop policy if exists "courses_select_published" on public.courses;
create policy "courses_select_published" on public.courses
  for select using (is_published or public.is_admin());

drop policy if exists "courses_admin_all" on public.courses;
create policy "courses_admin_all" on public.courses
  for all using (public.is_admin()) with check (public.is_admin());

-- ─── Enrollments ───────────────────────────────────────────────────────────
drop policy if exists "enrollments_own" on public.enrollments;
create policy "enrollments_own" on public.enrollments
  for all using (auth.uid() = user_id or public.is_admin())
  with check (auth.uid() = user_id or public.is_admin());

-- ─── Lab bookings ──────────────────────────────────────────────────────────
drop policy if exists "bookings_own" on public.lab_bookings;
create policy "bookings_own" on public.lab_bookings
  for all using (auth.uid() = user_id or public.is_admin())
  with check (auth.uid() = user_id or public.is_admin());

-- ─── Print orders ──────────────────────────────────────────────────────────
drop policy if exists "orders_own" on public.print_orders;
create policy "orders_own" on public.print_orders
  for all using (auth.uid() = user_id or public.is_admin())
  with check (auth.uid() = user_id or public.is_admin());

-- ============================================================================
-- SEED — starter course catalog (published)
-- ============================================================================
insert into public.courses (title, slug, summary, category, level, price, duration_weeks, instructor_name, cover_gradient, is_published)
values
  ('Computer Literacy Essentials', 'computer-literacy-essentials', 'Master the fundamentals of computers, files, and the internet.', 'ict', 'beginner', 0, 4, 'Grace M.', 'mint', true),
  ('Web Development with HTML, CSS & JS', 'web-development-basics', 'Build responsive websites from scratch with modern web standards.', 'web', 'beginner', 45000, 8, 'Daniel K.', 'sky', true),
  ('Graphic Design with Canva & Photoshop', 'graphic-design-fundamentals', 'Create logos, posters, and social media graphics like a pro.', 'design', 'beginner', 35000, 6, 'Fatma N.', 'peach', true),
  ('Data Analysis with Excel & Python', 'data-analysis-excel-python', 'Turn raw data into insights with spreadsheets and Python.', 'data', 'intermediate', 60000, 8, 'Joseph T.', 'lavender', true),
  ('Networking & IT Support Foundations', 'networking-it-support', 'Understand networks, hardware, and everyday IT support.', 'networking', 'intermediate', 50000, 6, 'Amina S.', 'rose', true),
  ('Digital Marketing & Social Media', 'digital-marketing-social', 'Grow brands online with content, ads, and analytics.', 'office', 'beginner', 40000, 5, 'Neema P.', 'sky', true)
on conflict (slug) do nothing;

-- ============================================================================
-- MAKE YOURSELF AN ADMIN
-- After signing up in the app, run ONE of these with your email:
-- ----------------------------------------------------------------------------
-- update public.profiles set role = 'admin' where email = 'you@example.com';
-- ============================================================================
