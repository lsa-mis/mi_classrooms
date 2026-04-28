# API Update Summary View Reference

This document explains the `api_update_logs` summary page so admins and developers can quickly understand what each section shows, where values come from, and how to interpret the results.

## Purpose

The API Update Summary page (`/api_update_logs`) is an operational dashboard for the classroom sync job (`rake api_update_database`).

It answers:

- Did the latest sync run succeed or fail?
- How long did it take?
- What happened in each phase (counts, warnings, errors)?
- How have recent runs looked over time?

## Access and Scope

- Requires authentication (`before_action :authenticate_user!`).
- Restricted to admins by policy (`ApiUpdateLogPolicy#index?` / `show?` return `user.admin`).
- Data is read from `ApiUpdateLog` records.

## Data Lifecycle (How the page is populated)

1. `api_update_database` task runs and calls `ApiUpdateDatabase::Runner`.
2. Runner executes each sync phase and collects per-phase `PhaseResult` data:
   - status
   - timing
   - counters
   - warnings
   - errors
3. Runner creates a `RunResult` and writes an `ApiUpdateLog` row via `TaskResultLog#update_log`.
4. `ApiUpdateLog.result` stores:
   - a human-readable summary text section
   - a JSON section after `Structured report:`
5. The UI calls `ApiUpdateLog#report_for_display` to parse this payload and normalize it for display.

## Summary Page Sections

## 1) Page Header

Shows:

- **Title:** `API Update Summary`
- **Subtitle:** short description of sync status/phase reporting

No calculations happen here; this is informational text.

## 2) Latest Run Section

Shown only when at least one `ApiUpdateLog` exists.

### Header line values

- **Active buildings:** `Building.where(visible: true).count`
- **Active rooms:** `Room.where(visible: true).count`

Important: these are current database visibility counts, not a historical snapshot of the selected run.

### Link

- **View raw report** opens the run detail page for the latest log (`/api_update_logs/:id`).

### Run summary content

Rendered via `_run_summary.html.erb` using `api_update_log.report_for_display`.

## 3) Run Summary Metric Cards

For the selected run, the top cards show:

- **Status** (`success`/`error`) with color badge
- **Started** timestamp
- **Finished** timestamp
- **Wall Time** in minutes

### How values are derived

`ApiUpdateLog#report_for_display`:

- Prefer parsed structured JSON from `result` after `Structured report:`.
- Fallback to parsing legacy text summary if structured JSON is missing.
- If `duration_seconds` is missing, derive in this order:
  1. `finished_at - started_at`
  2. `Total wall time: X minutes` in summary text
  3. sum of phase durations

Timestamp formatting uses `format_api_update_time`:

- Converts to local app timezone output like `Apr 28, 2026 7:12 AM`
- Returns `"Unknown"` for blank/invalid input

## 4) Per-Phase Cards

Each phase from `report["phases"]` renders as a separate card.

A phase card shows:

- **Phase name** (e.g., `Update buildings`)
- **Phase duration** in seconds
- **Phase status** (`success`/`error`)
- **Deactivated badge** if `deactivated > 0`
- **Counter tiles** for positive counters only
- **Warnings** list (yellow)
- **Errors** list (red)

### Counter behavior

The phase object tracks these counters:

- `api_calls`
- `created`
- `updated`
- `deleted`
- `deactivated`
- `skipped`
- `retries`
- `rate_limit_sleeps`
- `would_delete`

Only counters with values greater than zero are shown on the page.

## 5) Recent Runs Table

Shows up to 14 latest logs (`created_at DESC`).

Columns:

- **Run:** run timestamp
- **Status:** record status (`success`/`error`)
- **Wall Time:**
  - computed minutes if available
  - em dash if report exists but no duration
  - `Legacy report` if no structured/legacy parse data available
- **Actions:** `Details` link to run detail page

This section supports quick trend checks without opening each run.

## 6) Empty State

If no logs exist, page displays:

- `No API update runs have been recorded yet.`

## Run Detail Page

The detail page (`/api_update_logs/:id`) includes:

- The same run summary partial used on index
- A **Raw Saved Report** block showing full `ApiUpdateLog.result` exactly as stored

Use this page when troubleshooting and auditing the persisted payload.

## Interpreting Status and Results

- A **success** run means no phase-level errors were recorded in the final result.
- Warnings can still be present in successful runs.
- Some duration values may be derived (not originally stored) when older payloads are missing fields.
- Header active building/room counts reflect current app state, not point-in-time run state.

## Source Map (Code Locations)

- Page: `app/views/api_update_logs/index.html.erb`
- Run summary partial: `app/views/api_update_logs/_run_summary.html.erb`
- Phase partial: `app/views/api_update_logs/_phase.html.erb`
- Detail page: `app/views/api_update_logs/show.html.erb`
- Controller data loading: `app/controllers/api_update_logs_controller.rb`
- Time helper: `app/helpers/api_update_logs_helper.rb`
- Log parsing/normalization: `app/models/api_update_log.rb`
- Sync runner and phase payload: `lib/api_update_database/runner.rb`, `lib/api_update_database/phase_result.rb`, `lib/api_update_database/run_result.rb`
- Log writer: `lib/auth_token_api.rb` (`TaskResultLog#update_log`)

