-- The one piece of magic that makes "everyone is a CUSTOMER by default"
-- work: whenever Supabase Auth creates a row in auth.users (from email
-- signup OR Google sign-in — both go through the same table), this trigger
-- fires and creates the matching public.profiles row automatically.
--
-- Application code never inserts a Profile directly — this trigger is the
-- only thing that does. To make someone an admin, run 006_promote_to_admin.sql
-- AFTER they've signed up once.

create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, name, role)
  values (
    new.id,
    new.email,
    coalesce(
      new.raw_user_meta_data ->> 'full_name', -- Google sign-in sets this
      new.raw_user_meta_data ->> 'name',       -- our email signup form sets this
      split_part(new.email, '@', 1)            -- fallback: use the email prefix
    ),
    'CUSTOMER'
  );
  return new;
end;
$$ language plpgsql security definer set search_path = public;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
