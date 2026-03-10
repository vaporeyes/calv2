# calv2

A single-page printable yearly calendar with Supabase-backed event display.

Based on [Calendar by Neatnik](https://neatnik.net/calendar), converted from PHP to client-side JavaScript with additional features.

## Features

- 12-month year-at-a-glance grid in a single HTML file
- Two layout modes: default (day + weekday letter) and aligned-weekdays (traditional grid)
- Event count indicators on dates with events, with styled hover/tap tooltips
- Light background highlight on days with events
- Chevron navigation to move between years
- Print-first design: clean single-page output via `@media print`
- Configurable via URL parameters (year, layout, weekend convention)
- Graceful degradation when Supabase is unavailable or unconfigured

## Quick Start

Open `index.html` in a browser. That's it -- the calendar works with no setup.

For local development with Supabase credentials:

```bash
export SUPABASE_URL='https://your-project.supabase.co'
export SUPABASE_ANON_KEY='your-anon-key'
bash build.sh
open index.html
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

Run `schema.sql` in your Supabase SQL Editor. It creates the `events`
table, index, and RLS policy (idempotent, safe to run multiple times):

```bash
# Or copy-paste the contents of schema.sql into the Supabase SQL Editor
cat schema.sql
```

### 2. Seed test data

The seed script populates sample events for testing. It requires the
**service_role** key (not the anon key) because RLS blocks anonymous
inserts:

```bash
export SUPABASE_URL='https://your-project.supabase.co'
export SUPABASE_ANON_KEY='your-service-role-key'
bash seed.sh          # seeds current year
bash seed.sh 2025     # seeds a specific year
```

Find both keys in your Supabase dashboard under Settings > API.

The seed inserts 51 events: 14 single-event days, 4 multi-event days,
and 1 stress-test day (Jun 15: 25 events) to verify tooltip scrolling.

### 3. Configure credentials

Credentials are injected at build time via `build.sh`, which replaces
`%%SUPABASE_URL%%` and `%%SUPABASE_ANON_KEY%%` placeholder tokens in
`index.html`. See [Deployment](#deployment) below.

For local testing:

```bash
export SUPABASE_URL='https://your-project.supabase.co'
export SUPABASE_ANON_KEY='your-anon-key'
bash build.sh
```

## Deployment

### Cloudflare Pages

1. Connect your repository in the Cloudflare Pages dashboard.
2. Set the build configuration:
   - **Build command**: `bash build.sh`
   - **Build output directory**: `.`
3. Add environment variables under Settings > Environment Variables:
   - `SUPABASE_URL` -- your Supabase project URL
   - `SUPABASE_ANON_KEY` -- your Supabase anon (public) key

### Any static host

Run `build.sh` with the environment variables set, then deploy the
resulting `index.html`.

## Printing

1. Open the calendar in your browser.
2. File > Print (Cmd+P / Ctrl+P).
3. Navigation chevrons and tooltips are automatically hidden.
4. Event count numbers remain visible.
5. Best results in landscape orientation.

## Project Files

| File         | Purpose                                        |
|--------------|------------------------------------------------|
| `index.html` | The calendar (HTML + CSS + JS, single file)    |
| `schema.sql` | Supabase table, index, and RLS policy          |
| `seed.sh`    | Populates sample events for testing            |
| `build.sh`   | Injects Supabase credentials at build time     |

## License

MIT. See the license header in `index.html` for details.

Original work: Copyright (c) 2025 Neatnik LLC
Modifications: Copyright (c) 2025 Josh Huckabee
