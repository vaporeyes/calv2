# Quickstart: Supabase-Driven Yearly Calendar

## Prerequisites

- A modern web browser (Chrome, Firefox, Safari, or Edge)
- A Supabase project with an `events` table (optional -- calendar works
  without it)

## Setup

### 1. Supabase (optional)

If you want event data displayed on the calendar:

1. Create a Supabase project at https://supabase.com
2. Create the `events` table:

   ```sql
   CREATE TABLE events (
     id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
     event_date DATE NOT NULL,
     title TEXT NOT NULL,
     description TEXT
   );

   CREATE INDEX idx_events_event_date ON events (event_date);
   ```

3. Enable Row Level Security:

   ```sql
   ALTER TABLE events ENABLE ROW LEVEL SECURITY;

   CREATE POLICY "Public read access"
     ON events FOR SELECT
     TO anon
     USING (true);
   ```

4. Copy your project URL and anon key from the Supabase dashboard
   (Settings > API).

5. Edit `index.html` and fill in the constants:

   ```javascript
   const SUPABASE_URL = 'https://your-project.supabase.co';
   const SUPABASE_ANON_KEY = 'your-anon-key';
   ```

### 2. Run the Calendar

Open `index.html` directly in a browser, or serve it from any static
host:

```bash
# Option A: open directly
open index.html

# Option B: simple local server
python3 -m http.server 8000
# Then visit http://localhost:8000
```

## URL Parameters

| Parameter   | Values                         | Default        |
|-------------|--------------------------------|----------------|
| `year`      | Any valid year (e.g., `2025`)  | Current year   |
| `layout`    | `default`, `aligned-weekdays`  | `default`      |
| `sofshavua` | Present = Fri-Sat weekends     | Sat-Sun weekends |

Examples:
- `index.html?year=2025`
- `index.html?layout=aligned-weekdays`
- `index.html?year=2026&sofshavua`
- `index.html?year=2025&layout=aligned-weekdays&sofshavua`

## Printing

1. Open the calendar in your browser.
2. Use File > Print (or Cmd+P / Ctrl+P).
3. The #info overlay and tooltips are automatically hidden.
4. Event count numbers remain visible in print.
5. The calendar fits on a single page in landscape orientation.

## Verification

1. **Static calendar**: Open with no Supabase credentials. All 12
   months should render correctly with no errors in the console.
2. **With events**: Add test data to Supabase, configure credentials,
   reload. Event counts should appear on dates with events.
3. **Hover/tap**: Hover (desktop) or tap (mobile) a date with events.
   A styled tooltip should appear listing event titles.
4. **Print**: Open print preview. Verify clean layout with no tooltips
   or overlays.
