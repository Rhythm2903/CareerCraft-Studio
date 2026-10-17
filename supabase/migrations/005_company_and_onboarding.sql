-- =============================================================================
-- Migration 005 — Company role + Onboarding state
-- Run this in the Supabase SQL Editor (Dashboard > SQL Editor > New query)
-- =============================================================================

-- 1. Add new columns to the profiles table
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS needs_onboarding BOOLEAN NOT NULL DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS profile_json     TEXT;

-- 2. Existing users are already onboarded — don't send them through the wizard.
UPDATE public.profiles SET needs_onboarding = FALSE;

-- 3. Allow the COMPANY role (update the CHECK constraint).
--    Find the current constraint name with:
--      SELECT conname FROM pg_constraint WHERE conrelid = 'public.profiles'::regclass AND contype = 'c';
--    Then replace profiles_role_check below with the actual name.
ALTER TABLE public.profiles
  DROP CONSTRAINT IF EXISTS profiles_role_check;

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_role_check
  CHECK (role IN ('CUSTOMER', 'COMPANY', 'ADMIN'));

-- 4. Update the new-user trigger so it reads `account_type` from OAuth/signup
--    metadata and assigns the correct role automatically.
--
--    IMPORTANT: This assumes your trigger function is named handle_new_user().
--    Run the query below to confirm:
--      SELECT tgname, proname FROM pg_trigger t JOIN pg_proc p ON t.tgfoid = p.oid
--      WHERE t.tgrelid = 'auth.users'::regclass;
--    If the function has a different name, replace handle_new_user below.

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_account_type TEXT;
  v_role         TEXT;
BEGIN
  v_account_type := new.raw_user_meta_data->>'account_type';

  -- 'employer' → COMPANY, anything else (including Google users) → CUSTOMER
  IF v_account_type = 'employer' THEN
    v_role := 'COMPANY';
  ELSE
    v_role := 'CUSTOMER';
  END IF;

  INSERT INTO public.profiles (id, email, name, role, needs_onboarding)
  VALUES (
    new.id,
    new.email,
    COALESCE(
      new.raw_user_meta_data->>'name',
      new.raw_user_meta_data->>'full_name'   -- Google sets full_name
    ),
    v_role,
    TRUE   -- every new user goes through onboarding
  )
  ON CONFLICT DO NOTHING;  -- handles both id and email unique conflicts

  RETURN new;
END;
$$;

-- If the trigger itself doesn't exist yet, create it.
-- (If it already exists pointing to this function, this is a no-op.)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'on_auth_user_created'
  ) THEN
    CREATE TRIGGER on_auth_user_created
      AFTER INSERT ON auth.users
      FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
  END IF;
END $$;
