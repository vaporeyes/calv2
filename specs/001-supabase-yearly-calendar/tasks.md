# Tasks: Supabase-Driven Yearly Calendar

**Input**: Design documents from `/specs/001-supabase-yearly-calendar/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Note**: The existing `index.html` already implements the calendar grid
(US1) and URL parameter configuration (US3). These stories require no
new tasks. All new work is in the Foundational phase (CDN resilience)
and User Story 2 (event count + tooltip).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files or code sections, no dependencies)
- **[Story]**: Which user story this task belongs to (US2)
- Exact file paths included in descriptions

---

## Phase 1: Setup

**Purpose**: Verify existing project state before making changes.

- [x] T001 Verify current `index.html` renders correctly in browser for both `?layout=default` and `?layout=aligned-weekdays` in index.html
- [x] T002 Verify print preview hides #info overlay and produces single-page output for index.html

**Checkpoint**: Existing functionality confirmed working.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: CDN resilience guard. MUST complete before US2 work begins.

- [x] T003 Add `typeof window.supabase` guard in `fetchEvents()` to return `{}` when CDN fails to load, with `console.warn` message, in index.html
- [x] T004 Verify calendar renders correctly when Supabase CDN script is blocked (DevTools Network tab) in index.html

**Checkpoint**: Calendar renders a complete static grid even when CDN is unreachable.

---

## Phase 3: User Story 2 - Event Count and Hover Snippets (Priority: P2)

**Goal**: Replace the red dot event indicator with an event count number.
Replace the native `title` tooltip with a CSS-styled tooltip showing
event titles. Support hover (desktop), tap (touch), and focus (keyboard).

**Independent Test**: Load calendar with Supabase credentials pointing
to a table with known events. Verify count numbers appear, hover shows
styled tooltip, tap toggles on mobile, Tab key focuses cells and shows
tooltip.

### Implementation for User Story 2

**Event count indicator (replaces red dot):**

- [x] T005 [US2] Replace `.event-dot` span creation with `.event-count` span containing `dayEvents.length` as text content in the cell builder section of `renderCalendar()` in index.html
- [x] T006 [US2] Replace `.event-dot` CSS class with `.event-count` styling: small font size (~0.6em), muted color (#c0392b), inline display, margin-left for spacing, in index.html `<style>` block
- [x] T007 [US2] Add `@media print` rule to keep `.event-count` visible (ensure no `display:none` applies to it) in index.html `<style>` block

**CSS-styled tooltip (replaces native title):**

- [x] T008 [US2] Remove `td.title = dayEvents.join('\n')` from the cell builder in `renderCalendar()` in index.html
- [x] T009 [US2] Create a `.tooltip` child element inside each `.has-events` cell containing event titles as a `<ul>` list, appended after the event count span, in `renderCalendar()` in index.html
- [x] T010 [US2] Add `.tooltip` CSS: `position: absolute`, hidden by default (`opacity: 0; visibility: hidden`), styled container (background, border-radius, padding, shadow, z-index), positioned below or above the cell, max-height with `overflow-y: auto` for many events, in index.html `<style>` block
- [x] T011 [US2] Add `.has-events:hover .tooltip` and `.has-events:focus .tooltip` CSS rules to show the tooltip (`opacity: 1; visibility: visible`) with a short transition, in index.html `<style>` block
- [x] T012 [US2] Add `@media print` rule to hide `.tooltip` (`display: none`) in index.html `<style>` block

**Touch tap-to-toggle:**

- [x] T013 [US2] Add click event listener on `.has-events` cells to toggle an `.active` class that shows the tooltip (same visibility rules as hover), in index.html `<script>` block
- [x] T014 [US2] Add document-level click listener to dismiss any active tooltip when clicking outside a `.has-events` cell, in index.html `<script>` block
- [x] T015 [US2] Add `.has-events.active .tooltip` CSS rule matching the hover/focus visibility rules in index.html `<style>` block

**Keyboard accessibility (FR-013, Constitution Principle IV):**

- [x] T016 [US2] Add `tabindex="0"` attribute to each `.has-events` `<td>` element in the cell builder in `renderCalendar()` in index.html
- [x] T017 [US2] Add visible focus indicator CSS for `.has-events:focus` (e.g., outline or box-shadow) in index.html `<style>` block

**Checkpoint**: Event count numbers appear on dates with events. Hover,
tap, and keyboard focus all reveal styled tooltip with event titles.
Dates without events show no indicator and no tooltip.

---

## Phase 4: Polish & Cross-Cutting Concerns

**Purpose**: Validate all acceptance scenarios across layouts, devices,
and failure modes.

- [ ] T018 Test default layout (31-row) with event data: verify counts and tooltips render correctly in index.html (MANUAL)
- [ ] T019 Test aligned-weekdays layout (42-row) with event data: verify counts and tooltips render correctly in index.html (MANUAL)
- [ ] T020 Test print preview: verify event counts visible, tooltips hidden, #info hidden, single-page layout in index.html (MANUAL)
- [ ] T021 Test with empty Supabase credentials: verify clean empty calendar, no console errors beyond the expected warn in index.html (MANUAL)
- [ ] T022 Test with CDN blocked (DevTools): verify clean empty calendar with console warn in index.html (MANUAL)
- [ ] T023 Test touch interaction (DevTools touch emulation): verify tap shows tooltip, tap elsewhere dismisses in index.html (MANUAL)
- [ ] T024 Test keyboard navigation: verify Tab reaches event cells, tooltip appears on focus, disappears on blur in index.html (MANUAL)
- [ ] T025 Test edge case: date with 20+ events, verify tooltip is scrollable and does not overflow viewport in index.html (MANUAL)
- [ ] T026 Test URL parameter edge cases: `?year=abc`, `?layout=invalid`, `?sofshavua` with various values, verify graceful defaults in index.html (MANUAL)
- [ ] T027 Run quickstart.md validation: follow setup steps from scratch and verify all steps work as documented (MANUAL)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies -- verification only
- **Foundational (Phase 2)**: Depends on Setup confirmation
- **User Story 2 (Phase 3)**: Depends on Foundational (CDN guard must be in place)
- **Polish (Phase 4)**: Depends on User Story 2 completion

### Within User Story 2

```text
T005 (event count span) ──┐
T006 (event count CSS)  ──┼── can run in parallel (different code sections)
T007 (print CSS)        ──┘
         │
         v
T008 (remove title) ─────── must come before T009
T009 (tooltip element) ───── depends on T008
T010 (tooltip CSS)     ───── can parallel with T009 (CSS vs JS)
T011 (hover/focus CSS) ───── depends on T010
T012 (print hide CSS)  ───── depends on T010
T015 (active CSS)      ───── depends on T010
         │
         v
T013 (tap handler)     ──┐
T014 (dismiss handler) ──┼── can run in parallel
T016 (tabindex)        ──┤
T017 (focus indicator) ──┘
```

### Parallel Opportunities

Within Phase 3, these groups can execute in parallel:

```text
# Group A: Event count (T005, T006, T007)
# Group B: Tooltip structure (T008 -> T009, T010 -> T011, T012, T015)
# Group C: Interaction handlers (T013, T014, T016, T017)
# Groups A and B.css can overlap. Group C depends on tooltip existing.
```

---

## Implementation Strategy

### MVP (Phases 1-3)

1. Complete Phase 1: Verify existing calendar
2. Complete Phase 2: CDN guard
3. Complete Phase 3: Event count + tooltip + touch + keyboard
4. **STOP and VALIDATE**: Test all US2 acceptance scenarios

### Full Delivery

1. MVP above
2. Complete Phase 4: Polish and validation across all edge cases
3. Run quickstart.md end-to-end

---

## Notes

- All tasks modify the single file `index.html` (inline CSS + JS)
- [P] markers are omitted since all work is in one file; parallelism
  is at the code-section level (CSS block vs JS block), not file level
- US1 (calendar grid) and US3 (URL params) are already implemented
  and require no new tasks
- The dependency graph above shows logical ordering within US2
