-- ABOUTME: Supabase schema for the calv2 events table.
-- ABOUTME: Run in Supabase SQL Editor or via psql to create the table and RLS policy.

CREATE TABLE IF NOT EXISTS events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  event_date DATE NOT NULL,
  title TEXT NOT NULL,
  description TEXT
);

CREATE INDEX IF NOT EXISTS idx_events_event_date ON events (event_date);

ALTER TABLE events ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'events' AND policyname = 'Public read access'
  ) THEN
    CREATE POLICY "Public read access"
      ON events FOR SELECT
      TO anon
      USING (true);
  END IF;
END
$$;
