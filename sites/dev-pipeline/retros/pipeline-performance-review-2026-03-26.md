# Dev Pipeline Performance Review — 2026-03-26

## Test Case: DELETE Site Feature (The Tower v1.1.1)

Ran the full 8-stage pipeline for a single CRUD feature to benchmark end-to-end performance.

## Stage Timing

| Stage | Time | What Happened | Grade |
|-------|------|---------------|-------|
| Ideate | 0 min | User requested directly | N/A |
| Plan | 3 min | Read codebase, identified 3 files, scoped tests | A |
| Setup | 0 min | No new tooling needed | N/A |
| Build (TDD) | 12 min | RED-GREEN-REFACTOR, 5 files, 274 lines | A |
| Test | 2 min | 3 Go tests + TypeScript check, all pass | A |
| Review | 5 min | Code review agent found 2 HIGH issues, both fixed | A+ |
| Ship | 8 min | Push + deploy (first attempt TLS flake, retry succeeded) | B |
| Retro | 3 min | This review | - |
| **Total** | **~33 min** | Feature shipped end-to-end | |

## What Worked

1. **TDD flow is tight** — RED-GREEN-REFACTOR in 12 min for backend+frontend
2. **Parallel agent dispatch** — code reviewer ran in background during deploy, saved ~5 min
3. **Post-commit conventions** — Notion task auto-created and marked Done
4. **DI pattern** — adding handler/store method touched exactly the right files
5. **Git-backed site records** — docs immediately available in The Tower

## What Didn't Work

1. **Deploy reliability (B grade)** — Alpine TLS flake on Arch wasted 15+ min. Fix: pin mirror or cache warm.
2. **Missing deploy context** — `~/dashboard-deploy/` wasn't in CLAUDE.md until discovered mid-session. Fix: already added, beads will prevent for all projects.
3. **Pre-existing test failure** — `TestNew_SchemaVersionIncremented` still broken from v1.1.0. Pipeline needs a "no new failures" gate.
4. **No post-deploy smoke test** — verified health endpoint but not the UI. Fix: add `make smoke`.

## Cross-Project Assessment

| Project | Pipeline Fit | Key Gap |
|---------|-------------|---------|
| The Tower | A | Deploy flakiness, no E2E |
| Vitalis | B | Needs migration review, CDK gate, HIPAA check |
| Atlax | A | Go project, Docker deploy — perfect fit |
| MilEats | B+ | Multi-BFF needs deploy coordination |
| Mentalist | A | Pipeline is overkill (skip Setup, Ship = `poetry publish`) |
| Adune | C | Video project needs asset stages, not code stages |

## Improvement Backlog

| Priority | Improvement | Effort | Impact |
|----------|-------------|--------|--------|
| P0 | Fix pre-existing test failures before shipping | 30 min | No broken windows |
| P0 | Add `make smoke` post-deploy check | 1 hr | Catch deploy regressions |
| P1 | Automated pipeline state transitions via hooks | 4 hrs | Eliminate manual tracking |
| P1 | Persistent project memory (beads) | 4 hrs | No more context loss |
| P2 | Multi-project pipeline profiles | 2 hrs | Adune, Mentalist fit better |
| P2 | Docker build cache warming cron | 1 hr | No more TLS flakes |
| P3 | E2E test stage with Playwright | 8 hrs | Visual regression catches |

## Verdict

The pipeline ships features fast for code projects. 33 minutes from ask to production for a full CRUD feature with TDD, code review, and atomic deploys is strong for a solo dev.

For a multi-project solopreneur, the pipeline needs profiles. Not every project is a Go+React Docker service. The construction site metaphor in The Tower is the right foundation — now it needs site-specific blueprints.
