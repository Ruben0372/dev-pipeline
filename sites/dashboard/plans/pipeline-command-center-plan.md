# Pipeline Command Center — Plan

**Date:** 2026-03-26
**Status:** Completed + Deployed

## Problem

v1.0.1 added issues, dispatch approval, pipeline metrics, and multi-project profiles as backend APIs. But the Tower frontend didn't surface them — issues were buried in site record tabs, dispatch approval had no UI, metrics had no visualization, and dashboard KPIs were blind to pipeline health.

## Solution

5-phase frontend integration pass. All backend APIs already existed — zero backend changes needed.

## Phases

| Phase | Scope | Files |
|-------|-------|-------|
| 1. Foundation | Dispatch type update, PipelineMetric type, useIssues/usePipelineMetrics hooks, approve/reject on useDispatches | 4 files |
| 2. Dashboard KPIs | "Open Issues" + "Pending Approval" cards on home page | 2 files |
| 3. Global Issues | /issues route, sidebar entry, GlobalIssueBoard with project+severity filters | 5 files |
| 4. Dispatch Approval | Approve/reject buttons on DispatchCard, pending filter, issue link badge | 2 files |
| 5. Pipeline Detail | Inline issues, dispatches section, StageTimingChart on project detail page | 3 files |

## Decision: No new dependencies

Built StageTimingChart as pure CSS horizontal bars. No chart library needed — keeps bundle lean and matches the CLI aesthetic.

## Result

15 files changed, 522 lines added. Deployed to Arch in same session.
