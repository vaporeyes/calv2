<!--
Sync Impact Report
===================
Version change: N/A (initial) -> 1.0.0
Added principles:
  - I. Zero Dependency
  - II. Print-First Design
  - III. Data Integrity
  - IV. Accessibility
  - V. Performance
Added sections:
  - Technology Constraints
  - Development Workflow
  - Governance
Removed sections: none
Templates requiring updates:
  - .specify/templates/plan-template.md: no update needed (Constitution
    Check section is generic and will reference this file at plan time)
  - .specify/templates/spec-template.md: no update needed (requirements
    and user stories are domain-agnostic)
  - .specify/templates/tasks-template.md: no update needed (task phases
    are generic; principle-driven task types will be applied at task
    generation time)
  - .specify/templates/checklist-template.md: no update needed
  - No commands directory exists yet
Follow-up TODOs: none
-->

# calv2 Constitution

## Core Principles

### I. Zero Dependency

All code MUST favor vanilla JavaScript and standard Web APIs over
external frameworks or libraries. The calendar MUST remain portable
as a single-file (or minimal-file) deliverable that can be served
without a build step or package manager.

- No runtime JS dependencies (no React, Vue, jQuery, etc.).
- Standard Web APIs (DOM, Fetch, CSS custom properties) are the
  primary toolkit.
- Build tooling (bundlers, minifiers) is permitted only if the
  output remains a single distributable artifact.

**Rationale:** A year-view calendar is a bounded UI problem. Adding
a framework would increase payload, complicate deployment, and
contradict the print-first portability goal.

### II. Print-First Design

The calendar MUST remain a single-page printable document. Every UI
enhancement MUST be non-destructive to the `@media print` layout.

- Screen-only interactivity (hover tooltips, modals) MUST be hidden
  or collapsed in print output via `@media print` rules.
- Layout MUST NOT rely on JavaScript for spatial arrangement; CSS
  Grid/Flexbox MUST produce a correct calendar even with JS disabled.
- Color choices MUST degrade gracefully to grayscale printing.

**Rationale:** The primary use case is a printed year calendar.
Digital interactivity is a secondary enhancement that MUST NOT
compromise the physical artifact.

### III. Data Integrity

The application MUST gracefully handle missing data or database
connection failures by falling back to a clean, empty calendar state.

- If the event data source is unavailable, the calendar MUST render
  with zero events rather than showing an error page or blank screen.
- Data fetching errors MUST be logged to the console but MUST NOT
  propagate to the user as visible error UI.
- All date arithmetic MUST use well-tested logic to avoid off-by-one
  errors at month/year boundaries.

**Rationale:** A broken calendar is worse than an empty one. Users
printing a calendar need a usable output regardless of data-layer
health.

### IV. Accessibility

Hover states MUST be discoverable and event indicators MUST NOT
clutter the visual rhythm of the date grid.

- Interactive elements MUST be keyboard-navigable (focusable, with
  visible focus indicators).
- Event dots/badges MUST be small enough to preserve the grid's
  scanability; detailed info appears only on interaction.
- Color MUST NOT be the sole indicator of meaning; pair color with
  shape or text.
- Semantic HTML MUST be used (e.g., `<table>` for the grid,
  `<time>` for dates).

**Rationale:** The calendar is a visual scanning tool. Overloading
cells with content defeats its purpose. Accessibility ensures the
tool works for all users.

### V. Performance

Data fetching MUST be optimized to a single batch request per year
to avoid N+1 query patterns in the browser.

- One fetch call per calendar render (all 12 months of event data
  in a single response).
- No per-month or per-day lazy loading of event metadata.
- Render pipeline MUST complete without blocking the main thread
  for more than 100ms on a mid-range device.

**Rationale:** A year calendar loads all 12 months at once. Fetching
data piecemeal would create waterfall latency and visible pop-in,
degrading both the interactive and print experiences.

## Technology Constraints

- **Language**: Vanilla JavaScript (ES2020+ baseline).
- **Styling**: Plain CSS with `@media print` overrides.
- **Markup**: Single HTML file or minimal HTML + JS/CSS assets.
- **Data source**: Fetch API against a JSON endpoint (or embedded
  inline data). The specific backend is not prescribed.
- **Browser targets**: Modern evergreen browsers (Chrome, Firefox,
  Safari, Edge). No IE11 support required.
- **No build requirement**: The project MUST be runnable by opening
  the HTML file directly or serving it from any static host.

## Development Workflow

- Features MUST be validated against both screen rendering and
  print output before being considered complete.
- Every change to layout or event display MUST include a manual
  print-preview check (or automated screenshot comparison if
  available).
- CSS changes MUST be reviewed for `@media print` side effects.
- New interactive features MUST include keyboard navigation support.

## Governance

This constitution is the authoritative source of project principles
for calv2. All implementation decisions, code reviews, and
specifications MUST be evaluated against these principles.

- **Amendments** require explicit documentation of the change, a
  version bump following semver rules (MAJOR for principle removals
  or redefinitions, MINOR for additions, PATCH for clarifications),
  and an updated Sync Impact Report.
- **Compliance** is verified during specification review
  (`/speckit.plan` Constitution Check) and code review.
- **Conflicts** between principles are resolved by priority order
  (I through V). Print-First Design (II) takes precedence over
  interactive features when they conflict.

**Version**: 1.0.0 | **Ratified**: 2026-03-10 | **Last Amended**: 2026-03-10
