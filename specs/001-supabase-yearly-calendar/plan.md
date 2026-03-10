# Implementation Plan: Supabase-Driven Yearly Calendar

**Branch**: `001-supabase-yearly-calendar` | **Date**: 2026-03-10 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-supabase-yearly-calendar/spec.md`

## Summary

Enhance the existing single-file HTML/JS yearly calendar with: (1) event
count numbers replacing the current red dot indicator, (2) a CSS-styled
hover tooltip showing event title snippets (with tap-to-toggle on touch),
(3) graceful degradation when the Supabase CDN or data source is
unavailable, and (4) preservation of print-first layout with event counts
visible in print output.

The existing `index.html` already has the calendar grid, both layout
modes, URL parameter parsing, Supabase integration, and basic event
display. This plan covers the delta between current state and spec.

## Technical Context

**Language/Version**: Vanilla JavaScript (ES2020+), inline in single HTML file
**Primary Dependencies**: `@supabase/supabase-js@2` via CDN (pre-existing)
**Storage**: Supabase (PostgreSQL) -- `events` table with RLS read-only
**Testing**: Manual browser testing + print-preview validation
**Target Platform**: Modern evergreen browsers (Chrome, Firefox, Safari, Edge), desktop + mobile
**Project Type**: Single-file static web page
**Performance Goals**: Full render within 500ms of data receipt; no per-hover fetching
**Constraints**: Single HTML file; no build step; no npm; print-first
**Scale/Scope**: Single page, ~400 lines, 1 Supabase table

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Zero Dependency | VIOLATION (justified) | Supabase JS client is a pre-existing CDN dependency. Not a framework -- it's a thin data-access client. Single-file portability preserved (no npm/build). See Complexity Tracking. |
| II. Print-First Design | PASS | Tooltips hidden in `@media print`. Event count numbers visible in print. #info overlay already hidden. Layout is CSS-driven, not JS-dependent. |
| III. Data Integrity | PASS | Graceful fallback to empty calendar on data errors, empty credentials, and CDN load failure. Errors logged to console only. |
| IV. Accessibility | PASS (with addition) | Constitution requires keyboard-navigable interactive elements. Spec must add `tabindex` to event cells and tooltip display on focus. Touch interaction already specified. |
| V. Performance | PASS | Single batch fetch per year. All event data pre-loaded; no per-hover requests. |

**Post-design re-check**: All gates pass with the Supabase CDN
justification and the keyboard accessibility addition noted below.

**Accessibility addition required**: The constitution mandates keyboard
navigation for interactive elements. The implementation MUST add
`tabindex="0"` to date cells that have events and show the tooltip on
`focus`/hide on `blur`, mirroring the hover behavior. This was omitted
from the initial spec but is constitutionally required.

## Project Structure

### Documentation (this feature)

```text
specs/001-supabase-yearly-calendar/
+-- plan.md              # This file
+-- research.md          # Phase 0 output
+-- data-model.md        # Phase 1 output
+-- quickstart.md        # Phase 1 output
+-- contracts/           # Phase 1 output (URL params + Supabase query)
+-- checklists/          # Quality checklist
+-- spec.md              # Feature specification
```

### Source Code (repository root)

```text
index.html               # Single-file calendar (HTML + CSS + JS inline)
```

**Structure Decision**: Single-file architecture. All CSS and JS remain
inline in `index.html`. No separate source directories needed. This
matches the existing project structure and Constitution Principle I
(Zero Dependency / single-file portability).

## Implementation Phases

### Phase 1: CDN Resilience & Data Layer Hardening

1. Wrap `fetchEvents()` to guard against `window.supabase` being
   undefined (CDN load failure). If undefined, log to console and
   return empty object.
2. Ensure `renderCalendar()` works correctly when `fetchEvents()`
   returns `{}` (already works, but verify after refactoring).

### Phase 2: Event Count Indicator (replaces red dot)

1. Replace `.event-dot` span with an `.event-count` span showing the
   number of events (e.g., "3").
2. Style `.event-count` to be compact and non-intrusive: small font,
   subtle color, positioned inline after the day/weekday text.
3. Update `.event-count` to remain visible in `@media print` (unlike
   tooltips which are hidden).
4. Remove `.event-dot` CSS class (no longer used).

### Phase 3: CSS-Styled Tooltip (replaces native title)

1. Remove `td.title = ...` usage.
2. Add a `.tooltip` element (hidden by default) as a child of each
   `.has-events` cell, containing the event titles as a list.
3. Show tooltip on `:hover` and `:focus` via CSS (`opacity`/`visibility`
   transition).
4. Add tap-to-toggle behavior for touch: listen for `click` on
   `.has-events` cells, toggle an `.active` class that shows the
   tooltip. Clicking elsewhere dismisses via a document-level listener.
5. Hide `.tooltip` in `@media print`.
6. Handle edge case: many events (20+) -- add `max-height` + `overflow-y: auto`
   on the tooltip.

### Phase 4: Keyboard Accessibility

1. Add `tabindex="0"` to date cells with events.
2. Show tooltip on `focus`, hide on `blur` (mirrors hover behavior).
3. Ensure visible focus indicator on `.has-events` cells.

### Phase 5: Polish & Print Validation

1. Verify `@media print` output: event counts visible, tooltips hidden,
   #info hidden, clean single-page layout.
2. Test both layouts (default 31-row, aligned-weekdays 42-row).
3. Test with empty credentials, CDN failure (block script in DevTools),
   and valid Supabase data.
4. Test touch interaction on mobile/tablet (or via DevTools touch
   emulation).
5. Verify color degrades to grayscale for printing.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Supabase JS CDN dependency (Principle I) | Pre-existing architecture choice. Supabase client is needed for query building, RLS auth, and error handling against the PostgreSQL backend. | Raw Fetch API against Supabase REST endpoint was considered. Rejected because: (1) would require manually constructing PostgREST query strings with date range filters, (2) would need manual auth header management, (3) Supabase JS is a single CDN script (~40KB) that does not require npm or a build step, preserving single-file portability. |
