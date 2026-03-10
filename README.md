# calv2

A single-page printable yearly calendar with Supabase-backed event display.

Based on [Calendar by Neatnik](https://neatnik.net/calendar), converted from PHP to client-side JavaScript with additional features.

## Features

- 12-month year-at-a-glance grid in a single HTML file
- Two layout modes: default (day + weekday letter) and aligned-weekdays (traditional grid)
- Event count indicators on dates with events, with styled hover/tap tooltips
- Print-first design: clean single-page output via `@media print`
- Configurable via URL parameters (year, layout, weekend convention)
- Graceful degradation when Supabase is unavailable or unconfigured

## Quick Start

Open `index.html` in a browser. That's it -- the calendar works with no setup.

To add event data, see [Supabase Setup](#supabase-setup) below.

```bash
# Serve locally (optional, direct file open also works)
python3 -m http.server 8000
# Visit http://localhost:8000
```

## URL Parameters

| Parameter   | Values                        | Default          |
|-------------|-------------------------------|------------------|
| `year`      | Any valid year (e.g., `2025`) | Current year     |
| `layout`    | `default`, `aligned-weekdays` | `default`        |
| `sofshavua` | Present = Fri-Sat weekends    | Sat-Sun weekends |

Examples:
- `index.html?year=2025`
- `index.html?layout=aligned-weekdays`
- `index.html?year=2026&sofshavua`

## Supabase Setup

The calendar optionally fetches events from a Supabase PostgreSQL database.

### 1. Create the table

Run the schema in your Supabase SQL Editor (or use the seed script):

```sql
CREATE TABLE events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  event_date DATE NOT NULL,
  title TEXT NOT NULL,
  description TEXT
);

CREATE INDEX idx_events_event_date ON events (event_date);
```

### 2. Enable Row Level Security

```sql
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read access"
  ON events FOR SELECT
  TO anon
  USING (true);
```

### 3. Seed test data

A seed script is provided to populate sample events for testing:

```bash
# Set your Supabase credentials
export SUPABASE_URL='https://your-project.supabase.co'
export SUPABASE_ANON_KEY='your-anon-key'

# Run the seed script (requires curl)
bash seed.sh
```

The seed script inserts events across the current year so you can
verify event counts and tooltips in both layout modes.

### 4. Configure the calendar

Edit `index.html` and fill in the constants near the top of the
`<script>` block:

```javascript
const SUPABASE_URL = 'https://your-project.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key';
```

## Printing

1. Open the calendar in your browser.
2. File > Print (Cmd+P / Ctrl+P).
3. The info overlay and tooltips are automatically hidden.
4. Event count numbers remain visible.
5. Best results in landscape orientation.

## License

MIT. See the license header in `index.html` for details.

Original work: Copyright (c) 2025 Neatnik LLC
Modifications: Copyright (c) 2025 Josh Huckabee
