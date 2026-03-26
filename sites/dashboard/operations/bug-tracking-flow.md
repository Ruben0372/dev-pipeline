# Bug Tracking Flow — The Tower

Standardized process for discovering, documenting, and resolving bugs across all Tower projects.

## Pipeline Stage Mapping

Bugs are discovered during **Test** or **Review** stages but can surface at any point. The flow integrates with the 8-stage dev pipeline: Ideate → Plan → Setup → Build → **Test** → **Review** → Ship → Retro.

## Flow

### 1. Discover & Reproduce

- Identify the broken behavior (visual, functional, data)
- Note the exact steps to reproduce
- Capture the affected file(s) and line number(s)
- Determine severity: **Critical** / **High** / **Medium** / **Low**

### 2. Root Cause Analysis

Before filing, trace to the root cause:

- Read the source file(s) involved
- Check the route table (`App.tsx`) for navigation bugs
- Check the component tree for prop/state issues
- Check the API handler for data bugs
- Document the mismatch (expected vs actual behavior)

### 3. File GitHub Issue

Use `gh issue create` with this structure:

```
Title: [BUG/ENHANCEMENT]: <Component> — <one-line description>
Labels: bug | enhancement | critical

Body:
## Bug Description
What is broken and where (file:line).

## Impact
Who is affected and how severely.

## Steps to Reproduce
1. Navigate to...
2. Click...
3. Expected: ...
4. Actual: ...

## Root Cause
Technical explanation of why it's broken.

## Fix Approach
Specific code change with before/after snippets.

## Files
- path/to/file.tsx:line

## Severity
Critical | High | Medium | Low
```

### 4. Severity Definitions

| Level | Definition | Response |
|-------|-----------|----------|
| **Critical** | App crashes, data loss, security hole | Fix immediately, hotfix release |
| **High** | Primary navigation broken, feature unusable | Fix in current sprint |
| **Medium** | Feature works but UX is degraded | Fix in next sprint |
| **Low** | Cosmetic, inconsistency, minor polish | Backlog |

### 5. Fix Workflow

1. Create branch: `fix/<issue-number>-<short-name>`
2. Write failing test that reproduces the bug (TDD red)
3. Apply the fix (TDD green)
4. Run full test suite
5. Commit with `fix: <description> (closes #N)`
6. PR → merge → mark issue closed

### 6. Post-Fix

- Update Notion task if one exists
- If the bug revealed a pattern (e.g., route mismatches), create a lint rule or test to prevent recurrence
- Document in retro if it was Critical/High

## Labels

| Label | Use |
|-------|-----|
| `bug` | Confirmed broken behavior |
| `enhancement` | Improvement to existing feature |
| `critical` | Blocks core functionality |
| `ux` | Visual/interaction inconsistency |
| `navigation` | Routing or navigation issue |

## Notion Integration

For bugs sourced from Notion tasks:
- Reference the Notion task ID in the GitHub issue body
- When fixed, mark both the GitHub issue and Notion task as Done

## Example: Navigation Bugs (2026-03-26)

First batch of bugs tracked using this flow:

| # | Title | Severity | Status |
|---|-------|----------|--------|
| 1 | PipelineDetailPage back arrow → wrong route `/sites` | High | Open |
| 2 | Breadcrumb generic `~/tower` on nested routes | Low | Open |
| 3 | NotesPage mobile back lacks ArrowLeft icon | Low | Open |
| 4 | Breadcrumb not clickable (enhancement) | Enhancement | Open |
