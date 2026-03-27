# Pipeline Command Center — Tower Integration

**Date:** 2026-03-26
**Commit:** 72c286c
**Status:** Deployed

## What Was Built

Full frontend integration of all v1.0.1 pipeline features into the Tower UI. All backend APIs existed — this was purely frontend work (15 files changed, 522 lines added).

## New Features

### Dashboard KPIs (2 new cards)
- **Open Issues** — fetches `/api/issues/stats`, shows count with red accent when > 0
- **Pending Approval** — counts dispatches with `approval_status: needs_approval`
- Both poll every 60s alongside existing KPI cards

### Global Issues Page (`/issues`)
- New sidebar entry between Dispatch and Activity
- Cross-project Kanban board (Open | Dispatched | In Progress | Resolved)
- Project filter dropdown + severity filter buttons (all/critical/high/medium/low)
- Stats header showing total, critical, high counts
- WebSocket auto-refresh on issue events

### Dispatch Approval UI
- Approve (green check) and Reject (red X) buttons on DispatchCard
- Only shown when `approval_status === "needs_approval"`
- Linked issue badge (chain icon) when `source_issue_id` is set
- "Pending" filter tab on Dispatch page
- Calls `PUT /api/dispatch/{id}/approve` and `/reject`

### Pipeline Detail Enhancement
- **Issues section** — inline IssueBoard Kanban for the project
- **Dispatches section** — active dispatches with approval buttons
- **Stage timing chart** — horizontal bar chart showing avg duration per stage
- Sections auto-hide when no data (no empty noise)

## Files Created
- `web/src/hooks/useIssues.ts` — useIssues + useIssueStats hooks
- `web/src/hooks/usePipelineMetrics.ts` — usePipelineMetrics hook
- `web/src/components/pipeline/GlobalIssueBoard.tsx` — cross-project Kanban
- `web/src/components/pipeline/StageTimingChart.tsx` — CSS bar chart
- `web/src/pages/IssuesPage.tsx` — global issues page

## Files Modified
- `web/src/types/index.ts` — Dispatch gains approval_status + source_issue_id, PipelineMetric type
- `web/src/stores/kpi-store.ts` — openIssues + pendingDispatches fields
- `web/src/hooks/useDispatches.ts` — approveDispatch/rejectDispatch
- `web/src/components/dashboard/KpiCards.tsx` — 2 new cards + 2 new fetches
- `web/src/components/dispatch/DispatchCard.tsx` — approval buttons + issue link badge
- `web/src/pages/DispatchPage.tsx` — wire approval + pending filter
- `web/src/pages/PipelineDetailPage.tsx` — 3 new sections
- `web/src/App.tsx` — /issues route
- `web/src/components/layout/Sidebar.tsx` — Issues nav item
- `web/src/components/layout/Layout.tsx` — breadcrumb for /issues

## API Endpoints Used (all pre-existing)
| Endpoint | Used By |
|----------|---------|
| GET /api/issues | GlobalIssueBoard, useIssues hook |
| GET /api/issues/stats | IssuesPage, KpiCards |
| GET /api/sites/{slug}/issues | IssueBoard (per-project) |
| PUT /api/dispatch/{id}/approve | DispatchCard |
| PUT /api/dispatch/{id}/reject | DispatchCard |
| GET /api/metrics/pipeline/{project} | StageTimingChart |
| GET /api/dispatch | KpiCards (pending count) |
