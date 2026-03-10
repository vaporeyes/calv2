# Contract: Supabase Event Query

**Type**: Data-fetching interface
**Source**: Supabase JS client against `events` table

## Query

```javascript
supabase
  .from('events')
  .select('event_date, title')
  .gte('event_date', '{year}-01-01')
  .lte('event_date', '{year}-12-31')
```

Equivalent SQL:
```sql
SELECT event_date, title
FROM events
WHERE event_date >= '{year}-01-01'
  AND event_date <= '{year}-12-31'
```

## Response Shape

**Success** (`error` is null):
```json
{
  "data": [
    { "event_date": "2026-03-15", "title": "Team standup" },
    { "event_date": "2026-03-15", "title": "Lunch meeting" },
    { "event_date": "2026-07-04", "title": "Holiday" }
  ],
  "error": null
}
```

**Error** (`data` is null):
```json
{
  "data": null,
  "error": { "message": "...", "code": "..." }
}
```

## Client-Side Transformation

Input: `data` array from Supabase response.
Output: `Record<string, string[]>` keyed by date string.

```javascript
// Result:
{
  "2026-03-15": ["Team standup", "Lunch meeting"],
  "2026-07-04": ["Holiday"]
}
```

## Failure Modes

| Condition                    | Behavior                                    |
|------------------------------|---------------------------------------------|
| CDN fails to load            | `window.supabase` undefined; return `{}`    |
| Credentials empty            | Skip fetch entirely; return `{}`            |
| Network error / timeout      | `error` object populated; log and return `{}` |
| RLS blocks access            | `error` object populated; log and return `{}` |
| Table does not exist         | `error` object populated; log and return `{}` |

All failure modes result in the same outcome: empty event map, calendar
renders without events, error logged to console.
