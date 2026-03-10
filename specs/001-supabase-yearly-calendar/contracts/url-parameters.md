# Contract: URL Parameters

**Type**: User-facing configuration interface
**Source**: Browser URL query string (`window.location.search`)

## Parameters

| Name       | Type    | Required | Valid Values                    | Default          | Behavior on Invalid |
|------------|---------|----------|---------------------------------|------------------|---------------------|
| `year`     | integer | No       | Any parseable integer           | Current year     | Falls back to default |
| `layout`   | string  | No       | `"default"`, `"aligned-weekdays"` | `"default"`      | Treated as `"default"` |
| `sofshavua`| flag    | No       | Presence-based (no value needed) | Absent (false)   | N/A                 |

## Parsing Logic

```
params = new URLSearchParams(window.location.search)
year     = parseInt(params.get('year')) || new Date().getFullYear()
layout   = params.get('layout') || 'default'
sofshavua = params.has('sofshavua')
```

## Examples

| URL                                          | year | layout           | sofshavua |
|----------------------------------------------|------|------------------|-----------|
| `index.html`                                 | 2026 | default          | false     |
| `index.html?year=2025`                       | 2025 | default          | false     |
| `index.html?layout=aligned-weekdays`         | 2026 | aligned-weekdays | false     |
| `index.html?year=2025&sofshavua`             | 2025 | default          | true      |
| `index.html?year=abc`                        | 2026 | default          | false     |
| `index.html?layout=invalid`                  | 2026 | default          | false     |
