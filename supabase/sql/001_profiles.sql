-- Profiles: one row per user. Supabase's own `auth.users` table (which you
-- don't create or touch directly) holds email/password/OAuth identity;
-- this table holds the app-specific fields auth.users has no room for —
-- name and role. The two are linked 1:1 by a shared UUID.
--
-- Rows here are created automatically by the trigger in
-- 004_new_user_trigger.sql, whenever someone signs up. Never insert into
-- this table by hand except when promoting someone to admin (006).

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null unique,
  name text,
  role text not null default 'CUSTOMER' check (role in ('CUSTOMER', 'ADMIN')),
  created_at timestamptz not null default now()
);
