# Data Model: Supabase-Driven Yearly Calendar

**Date**: 2026-03-10
**Branch**: `001-supabase-yearly-calendar`

## Entities

### Event (Supabase table: `events`)

| Column       | Type   | Constraints            | Description                        |
|-------------|--------|------------------------|------------------------------------|
| id          | uuid   | PK, auto-generated     | Unique event identifier            |
| event_date  | date   | NOT NULL, indexed       | The date the event occurs on       |
| title       | text   | NOT NULL               | Short event title (shown in tooltip) |
| description | text   | nullable               | Extended description (not displayed in v1) |

**RLS Policy**: Anonymous read-only. `SELECT` allowed for `anon` role.
All write operations (`INSERT`, `UPDATE`, `DELETE`) blocked for `anon`.

**Index**: `idx_events_event_date` on `event_date` for range queries.

**Query pattern**: Single batch query per year:
```
SELECT event_date, title
FROM events
WHERE event_date >= '{year}-01-01'
  AND event_date <= '{year}-12-31'
```

### Calendar Configuration (client-side, derived from URL)

| Field     | Type    | Default                   | Source             |
|-----------|---------|---------------------------|--------------------|
| year      | integer | Current year              | `?year=NNNN`       |
| layout    | string  | `"default"`               | `?layout=...`      |
| sofshavua | boolean | `false`                   | `?sofshavua` presence |

Not persisted. Parsed from `URLSearchParams` on page load.

### Events By Date (client-side, derived from query)

In-memory map built from the Supabase query response:

```
Record<string, string[]>
```

Key: `"YYYY-MM-DD"` date string.
Value: Array of event title strings for that date.

Built once per page load. Used for O(1) lookup during cell rendering.

## Relationships

```
Event *--1 Date : occurs on
Date 1--* Event : has many
CalendarConfig 1--1 Render : configures
```

- One date can have many events.
- Calendar configuration is 1:1 with a page render.
- The events-by-date map is a denormalized view of the Event table,
  scoped to the configured year.

## Validation Rules

- `event_date` MUST be a valid date (enforced by PostgreSQL `date` type).
- `title` MUST NOT be empty (enforced by `NOT NULL` constraint).
- `year` URL parameter: parsed as integer; invalid values fall back to
  current year.
- `layout` URL parameter: only `"default"` and `"aligned-weekdays"` are
  recognized; any other value treated as `"default"`.
- `sofshavua` URL parameter: presence-based boolean; value is ignored.
