# Research: Supabase-Driven Yearly Calendar

**Date**: 2026-03-10
**Branch**: `001-supabase-yearly-calendar`

## R1: CSS Tooltip vs JS Tooltip Approach

**Decision**: Hybrid CSS + minimal JS approach.

**Rationale**: The tooltip needs to support three interaction modes:
hover (desktop), focus (keyboard), and tap-to-toggle (touch). Pure CSS
can handle hover and focus via `:hover` and `:focus` pseudo-classes.
Touch requires a small JS click handler to toggle an `.active` class.
This keeps the implementation minimal while covering all devices.

**Alternatives considered**:
- Pure CSS (`:hover` + `:focus` only): Does not support tap-to-dismiss
  on touch devices. Touch `:hover` is sticky and unreliable across
  browsers.
- JS-only tooltip (Popper.js, Tippy.js): Violates Principle I (Zero
  Dependency). Unnecessary complexity for a simple title list.
- Native `title` attribute: Current approach. Not styled, not visible
  on touch, not print-controllable. Does not meet FR-005.

## R2: CDN Failure Guard Pattern

**Decision**: Check `typeof window.supabase !== 'undefined'` before
calling `createClient`. If undefined, log warning and return empty
event map.

**Rationale**: The Supabase JS script tag loads synchronously (no
`async`/`defer`) in `<head>`, so by the time the inline `<script>`
runs, the CDN script has either loaded or failed. A simple typeof
check is sufficient; no need for dynamic import or retry logic.

**Alternatives considered**:
- `onerror` handler on script tag: More complex; would need to set a
  global flag. The typeof check achieves the same result more simply.
- Dynamic `import()`: Requires module support and changes the loading
  model. Overkill for this use case.
- Retry with backoff: Violates Principle III rationale ("a broken
  calendar is worse than an empty one"). Fast fallback is preferred.

## R3: Event Count Display Approach

**Decision**: Replace `.event-dot` span with `.event-count` span
containing the count as text content. Style with small font size,
subtle color (e.g., muted red or gray), positioned inline.

**Rationale**: A number is more informative than a dot (tells the user
HOW MANY events, not just that events exist). The number must be small
enough to not disrupt the grid's visual rhythm (Principle IV). Using
text content means it naturally appears in print output without extra
CSS (unlike background-image approaches).

**Alternatives considered**:
- Badge with background circle: More visually prominent but clutters
  the compact grid cells. Fails Principle IV ("event indicators MUST
  NOT clutter the visual rhythm").
- CSS `::after` pseudo-element with `content: attr(data-count)`: Works
  but harder to control in print and less semantic.

## R4: Supabase CDN vs Raw Fetch

**Decision**: Keep `@supabase/supabase-js` via CDN (pre-existing).

**Rationale**: The Supabase JS client provides query building (`.from`,
`.select`, `.gte`, `.lte`), automatic auth header injection for RLS,
and structured error responses. Replacing it with raw Fetch would
require:
1. Manually constructing PostgREST URL with query params
2. Adding `apikey` and `Authorization` headers manually
3. Parsing PostgREST error format manually

The CDN approach preserves single-file portability (no npm, no build).
The script is ~40KB gzipped. This is a justified exception to
Principle I, documented in the Complexity Tracking section of the plan.

**Alternatives considered**:
- Raw Fetch API: Simpler dependency-wise but more error-prone code.
  PostgREST URL construction for date range queries is non-trivial.
- Embed event data as inline JSON: Would eliminate all network
  dependencies but requires a build/generation step to produce the
  HTML file. Incompatible with dynamic event updates.

## R5: Touch Tooltip Dismiss Pattern

**Decision**: Toggle `.active` class on click. Document-level click
listener dismisses any active tooltip when clicking outside.

**Rationale**: This is the standard mobile tooltip/popover pattern.
The click handler checks if the target is inside a `.has-events` cell.
If yes, toggle that cell's tooltip. A single document-level listener
handles dismiss-on-outside-click without needing per-cell listeners.

**Alternatives considered**:
- `touchstart`/`touchend` events: More complex, requires tracking
  touch state. Click events work on touch devices and are simpler.
- CSS `:focus-within` on a wrapping button: Would require wrapping
  each cell's content in a `<button>`, changing the DOM structure
  significantly.
