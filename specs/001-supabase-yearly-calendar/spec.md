# Feature Specification: Supabase-Driven Yearly Calendar

**Feature Branch**: `001-supabase-yearly-calendar`
**Created**: 2026-03-10
**Status**: Draft
**Input**: User description: "Single-page 12-month calendar grid with event count indicators, hover snippets, URL-configurable layout, and Supabase-backed event storage."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Yearly Calendar Grid (Priority: P1)

A user opens the calendar page and sees a complete 12-month grid for
the current year. Each month is a column in a single `<table>`. In the
default layout, each row shows a day number and weekday letter (e.g.,
"15 W"). In the aligned-weekdays layout, days are positioned by their
weekday slot across a 6-week (42-row) grid. The calendar is immediately
useful as a printable year-at-a-glance reference, even with no event
data.

**Why this priority**: The static calendar grid is the foundation that
all other features build upon. It also delivers standalone value as a
printable year planner.

**Independent Test**: Open the HTML file in a browser and verify all 12
months render correctly for the current year. Print-preview confirms a
clean single-page layout.

**Acceptance Scenarios**:

1. **Given** the page loads with no URL parameters, **When** the user
   views the page, **Then** a 12-column table for the current year is
   displayed with correct dates, weekday letters, and month headers.
2. **Given** a month starts on a Wednesday, **When** that month renders
   in the default layout, **Then** day 1 shows "1 W" in the first row
   of its column.
3. **Given** a month starts on a Wednesday in aligned-weekdays layout,
   **When** that month renders, **Then** day 1 appears in the
   Wednesday slot (row 3 of the first week) with empty cells before it.
4. **Given** the user opens print preview, **When** the print layout
   renders, **Then** the calendar fits on a single page with the #info
   overlay hidden and no interactive controls visible.

---

### User Story 2 - View Event Count and Hover Snippets (Priority: P2)

A user opens the calendar and sees a small number on dates that have
events, indicating how many events exist on that day. Dates with no
events show no number. Hovering over a date with events reveals a
tooltip snippet listing event titles for that date.

**Why this priority**: Event display is the core data-driven feature
that differentiates this from a plain calendar. It depends on the grid
(P1) being in place.

**Independent Test**: Load the calendar with a data source containing
known events. Verify count numbers appear on the correct dates and
hovering reveals the expected title snippets.

**Acceptance Scenarios**:

1. **Given** the data source contains 3 events on March 15, **When**
   the calendar renders, **Then** March 15 shows the number "3" as an
   event count indicator alongside the date.
2. **Given** a date has no events, **When** the calendar renders,
   **Then** no event count number is shown on that date cell.
3. **Given** March 15 has 3 events, **When** the user hovers over
   March 15, **Then** a tooltip snippet appears listing the event
   titles for that date.
4. **Given** a date has no events, **When** the user hovers over it,
   **Then** no tooltip appears.
5. **Given** the data source is unavailable, **When** the calendar
   renders, **Then** the grid displays with no event counts and no
   error message visible to the user (errors logged to console only).
6. **Given** a date has events, **When** the user prints the calendar,
   **Then** the event count number is visible in print but the hover
   tooltip is not rendered.
7. **Given** a touch device, **When** the user taps a date with events,
   **Then** the tooltip snippet appears. Tapping again or tapping
   elsewhere dismisses it.

---

### User Story 3 - Configure Calendar via URL Parameters (Priority: P3)

A user customizes the calendar by appending URL parameters: selecting a
specific year, choosing a layout variant, and toggling the weekend
convention. This allows bookmarking or sharing specific calendar
configurations.

**Why this priority**: Configuration adds flexibility but is not
required for the core viewing experience. The calendar is fully
functional with defaults.

**Independent Test**: Open the calendar with
`?year=2025&layout=aligned-weekdays&sofshavua` and verify the year,
layout, and weekend highlighting change accordingly.

**Acceptance Scenarios**:

1. **Given** the URL contains `?year=2025`, **When** the page loads,
   **Then** the calendar displays all 12 months of 2025.
2. **Given** the URL contains `?layout=aligned-weekdays`, **When** the
   page loads, **Then** months use the aligned-weekdays layout (42-row
   grid with days positioned by weekday slot).
3. **Given** no `layout` parameter is present, **When** the page loads,
   **Then** the default 31-row layout is used (day number + weekday
   letter per cell).
4. **Given** the URL contains `?sofshavua`, **When** the page loads,
   **Then** weekend highlighting shifts from Saturday-Sunday to
   Friday-Saturday.
5. **Given** an invalid year like `?year=abc`, **When** the page loads,
   **Then** the calendar falls back to the current year.
6. **Given** no parameters at all, **When** the page loads, **Then**
   the calendar renders the current year in default layout with
   Saturday-Sunday weekends.

---

### Edge Cases

- What happens when February 29 exists (leap year)? The grid MUST
  correctly display 29 days for leap years.
- What happens when the data source returns events for dates outside
  the displayed year? They MUST be silently ignored.
- What happens when a single date has many events (e.g., 20+)? The
  tooltip MUST remain usable -- either scrollable or truncated with
  an indication that more events exist.
- What happens when the browser window is very narrow? The grid MUST
  remain readable or degrade gracefully.
- What happens when Supabase credentials are empty? The calendar MUST
  render with no event data and no errors (current behavior: returns
  empty object when URL/key are blank).
- What happens when the data-fetching client library fails to load
  (CDN down)? The calendar MUST still render a complete static grid
  with no events and no user-visible errors.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST render a 12-column table grid (one column per
  month) for a given year with correct date placement per the Gregorian
  calendar.
- **FR-002**: System MUST display weekday column headers (abbreviated
  month names) in the `<thead>`.
- **FR-003**: System MUST fetch all event data for the displayed year in
  a single batch request on page load.
- **FR-004**: System MUST display an event count number on each date
  cell that has one or more associated events. Dates with no events
  MUST NOT show any count indicator.
- **FR-005**: System MUST display a tooltip snippet listing event titles
  when the user hovers over a date cell that has events. On touch
  devices, tapping a date cell MUST show/toggle the tooltip; tapping
  again or elsewhere MUST dismiss it. The tooltip MUST be richer than
  the native browser `title` attribute (e.g., a CSS-styled tooltip or
  popover).
- **FR-006**: System MUST hide tooltips, the #info overlay, and the
  "next year" link in `@media print` output. Event count numbers
  MUST remain visible in print.
- **FR-007**: System MUST accept `year` (integer), `layout` (string:
  "default" or "aligned-weekdays"), and `sofshavua` (boolean flag
  presence) as URL query parameters.
- **FR-008**: System MUST fall back to sensible defaults when URL
  parameters are missing or invalid (current year, default layout,
  Saturday-Sunday weekends).
- **FR-009**: System MUST render a clean, empty calendar grid when the
  data source is unavailable or returns an error. This includes the
  case where the data-fetching client library itself fails to load
  (e.g., CDN unreachable). Errors MUST be logged to the console but
  MUST NOT block calendar rendering or produce user-visible errors.
- **FR-010**: In the default layout, each cell MUST show the day number
  and a single weekday letter (e.g., "15 W").
- **FR-011**: In the aligned-weekdays layout, months MUST use a 42-slot
  grid (6 weeks x 7 days) where each day is positioned according to
  its weekday, with empty cells for padding before and after the
  month's actual days.
- **FR-012**: The `sofshavua` flag MUST toggle weekend highlighting
  from Saturday-Sunday (default) to Friday-Saturday (Israeli
  convention).
- **FR-013**: Date cells with events MUST be keyboard-focusable (via
  `tabindex`) and MUST display the tooltip on focus, matching the
  hover behavior. This is required by Constitution Principle IV
  (Accessibility).

### Key Entities

- **Event**: A named occurrence on a specific date. Attributes: unique
  identifier, date, title, description. One date may have many events.
- **Calendar Configuration**: The set of display parameters for a
  calendar render. Attributes: year, layout mode, weekend convention.

## Clarifications

### Session 2026-03-10

- Q: How should events be revealed on touch devices where hover is unavailable? → A: Tap to show/toggle tooltip (tap again or tap elsewhere to dismiss).
- Q: If the Supabase JS CDN fails to load, how should the calendar behave? → A: Degrade gracefully: render calendar with no events, log error to console.
- Q: What is the security posture for event data access? → A: Public read-only via RLS. Anon key is intentionally public; write operations blocked by policy.

## Assumptions

- The existing single-file HTML architecture is preserved. Supabase JS
  client is loaded via CDN, not as a bundled dependency.
- The "default" layout is a 31-row grid where each row = a day of the
  month (1-31), and each cell shows day number + weekday letter.
- The "aligned-weekdays" layout is a 42-row grid (6 weeks) where days
  are slotted by their weekday position, with no weekday letter.
- `sofshavua` (Hebrew for "week") is a boolean toggle, not a numeric
  day selector. Its presence shifts weekends to Fri-Sat.
- The tooltip "snippet" shows event titles only (not descriptions).
  Full event details may be a future enhancement.
- The calendar is read-only. No event creation, editing, or deletion
  from the UI.
- The Supabase anon key is intentionally public (client-side embedded).
  The events table is protected by Row Level Security with a read-only
  policy for anonymous access. Write operations are blocked by RLS.
- The #info overlay (with "next year" link and attribution) is the
  only navigation control; it is hidden in print.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Calendar grid for any valid year renders completely within
  500ms of receiving event data.
- **SC-002**: Hovering over a date with events displays a styled tooltip
  snippet listing event titles for that date. No additional data
  fetching is required on hover (all data is pre-fetched).
- **SC-003**: Print preview produces a clean single-page calendar with
  no tooltips, no #info overlay, and no interactive controls visible.
  Event count numbers remain visible in print.
- **SC-004**: When the data source is unreachable or credentials are
  empty, the calendar still renders a complete, correct, empty grid
  with no user-visible errors.
- **SC-005**: URL parameters are parsed and applied on page load; an
  invalid parameter never causes a broken or blank page.
