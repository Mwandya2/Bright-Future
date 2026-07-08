-- ============================================================================
-- Bright Future — contact_messages table (public contact form)
-- Run in Supabase → SQL Editor. Safe to re-run.
-- ============================================================================

create table if not exists public.contact_messages (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  email      text not null,
  subject    text,
  message    text not null,
  created_at timestamptz not null default now()
);

alter table public.contact_messages enable row level security;

-- Anyone (including anonymous visitors) may submit the contact form.
drop policy if exists "contact_insert_any" on public.contact_messages;
create policy "contact_insert_any" on public.contact_messages
  for insert with check (true);

-- Only admins may read submissions (the admin dashboard also uses the
-- service-role key, which bypasses RLS).
drop policy if exists "contact_select_admin" on public.contact_messages;
create policy "contact_select_admin" on public.contact_messages
  for select using (public.is_admin());
