# Dev Pipeline — Product Requirements Document

**Version:** 1.0
**Author:** Ruben
**Date:** 2026-03-26
**Status:** Approved

---

## 1. Problem Statement

Ruben manages 6+ active projects (Dashboard, Vitalis, Atlax, MilEats, Mentalist, Adune) as a solo developer using Claude Code as a primary engineering partner. Without a standardized pipeline:

- **Scattered documentation.** PRDs, architecture docs, handoffs, and retros land in random folders or Notion pages with no consistent structure. Finding the right doc for a project means searching across multiple locations.
- **Mental pipeline tracking.** Stage progression (Ideate through Retro) is tracked in Ruben's head. There is no queryable record of which stage a project is in, how long it stayed there, or what triggered the transition.
- **Context loss between sessions.** Claude Code sessions start fresh. Without a canonical handoff doc in a known location, the new session either repeats discovery work or operates on stale assumptions.
- **No audit trail.** Decisions, trade-offs, and rejected alternatives are discussed in ephemeral chat sessions and never persisted. Post-mortems lack source material.
- **No real-time visibility.** The Tower dashboard has no structured data source for project documentation, so it cannot render site records or pipeline status.

## 2. Solution Overview

The Dev Pipeline is a git repository (`dev-pipeline`) that serves as the single integration layer between Claude Code and The Tower (self-hosted dashboard on Arch at 100.103.184.98). It provides:

1. **Standardized site records** — Each project gets a folder under `sites/{slug}/` with 11 fixed documentation categories (overview + 10 subdirectories). Agents and humans always know where to read and write.
2. **Git-backed audit trail** — Every doc change is a commit. History is searchable, diffable, and survives session boundaries.
3. **Automated scaffolding** — `scripts/scaffold.sh` creates a complete site record from a template in one command. Combined with The Tower's onboard API, a new project goes from zero to visible in under a minute.
4. **2-minute sync to The Tower** — The Arch server pulls the repo on a 2-minute schedule. The Tower API reads `sites/` and serves records to the frontend as tabbed markdown views.
5. **Foundation for automation** — The repo structure, config files (`stages.json`, `categories.json`), and `pipeline.json` state file provide the data model for future automated stage transitions.

## 3. The 8 Pipeline Stages

| # | Stage | Purpose | Key Outputs |
|---|-------|---------|-------------|
| 0 | **Ideate** | Define the problem and explore solution space | Problem statement, concept notes, competitive analysis |
| 1 | **Plan** | Produce actionable implementation plan | PRD, architecture doc, phase breakdown, task list |
| 2 | **Setup** | Bootstrap repo, CI, infra, and tooling | Scaffolded repo, Docker config, CI pipeline, CLAUDE.md |
| 3 | **Build** | Implement features per plan | Source code, API specs, handoff docs between sessions |
| 4 | **Test** | Verify correctness, performance, security | Test suites (unit/integration/e2e), coverage reports |
| 5 | **Review** | Code review, architecture review, security audit | Review summaries, security findings, approval records |
| 6 | **Ship** | Deploy to production, announce | Deployment runbook, release notes, ops docs |
| 7 | **Retro** | Reflect on the cycle and extract learnings | Retrospective doc, metrics report, improvement items |

Stages are sequential but projects may loop (e.g., Build-Test-Build cycles are normal). The current stage is tracked in `pipeline.json` at the repo root and in the project's Notion record.

## 4. Site Record Standard

Every project gets a site record at `sites/{slug}/` with the following structure:

| # | Category | Path | Content |
|---|----------|------|---------|
| 0 | Overview | `overview.md` | Project identity: name, version, tech stack, links, current status |
| 1 | Architecture | `architecture/` | System design, C4 diagrams, ADRs, data models |
| 2 | API | `api/` | Endpoint specs, request/response schemas, auth docs |
| 3 | Requirements | `requirements/` | PRDs, feature specs, acceptance criteria |
| 4 | Plans | `plans/` | Phase plans, sprint breakdowns, dependency maps |
| 5 | Handoffs | `handoffs/` | Session handoff docs with context for next Claude Code session |
| 6 | Reviews | `reviews/` | Code review summaries, architecture review notes |
| 7 | Reports | `reports/` | Status reports, metrics, performance benchmarks |
| 8 | Retros | `retros/` | Retrospectives, post-mortems, lessons learned |
| 9 | Security | `security/` | Threat models, compliance checklists, audit findings |
| 10 | Operations | `operations/` | Deployment guides, runbooks, monitoring setup |

Category metadata (labels, ordering, icons) is defined in `config/categories.json`. The Tower reads this file to render tabs in the correct order.

## 5. Repo Structure

```
dev-pipeline/
├── sites/                        # Per-project site records
│   ├── dashboard/                # The Tower
│   ├── dev-pipeline/             # This project (meta/self-hosted)
│   ├── vitalis/                  # (future)
│   ├── atlax/                    # (future)
│   └── ...
├── config/
│   ├── categories.json           # 11 doc categories with labels, order, icons
│   └── stages.json               # 8 pipeline stages with labels, order, icons
├── templates/
│   └── new-site/                 # Folder template used by scaffold.sh
├── scripts/
│   ├── scaffold.sh               # Create new site record from template
│   ├── commit-doc.sh             # Stage, commit, push a single doc
│   └── notion-sync-tasks.sh      # Post-commit reminder to update Notion
├── pipeline.json                 # Per-project stage tracking (future use)
└── README.md
```

## 6. Integration with The Tower

### 6.1 Sync Mechanism

1. Agents write docs to `sites/{slug}/{category}/` during Claude Code sessions.
2. Agent or human pushes to GitHub (`github.com/Ruben0372/dev-pipeline`).
3. The Tower's scheduler runs `git pull` on the Arch server every 2 minutes.
4. The Tower API reads the `sites/` directory tree and serves site records.
5. The Tower frontend renders each site as a tabbed markdown viewer, one tab per category.

### 6.2 Tower API Endpoints (consumed, not owned by this project)

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/sites` | GET | List all site records |
| `/api/sites/:slug` | GET | Get a single site record with all categories |
| `/api/sites/:slug/onboard` | POST | Register a new site after scaffolding |

### 6.3 Data Flow

```
Claude Code session
  ↓ writes docs
sites/{slug}/{category}/*.md
  ↓ git push
GitHub (Ruben0372/dev-pipeline)
  ↓ git pull (every 2 min)
Arch server (/mnt/WaRlOrD/dashboard-data/dev-pipeline/)
  ↓ reads directory
Tower API
  ↓ serves JSON
Tower Frontend (tabbed markdown viewer)
```

## 7. Agent Integration via CLAUDE.md

Each project's `CLAUDE.md` includes conventions that tell Claude Code agents where to write documentation. Example directive:

```
## Dev Pipeline Conventions
- Write handoffs to: ~/projects/dev-pipeline/sites/{slug}/handoffs/
- Write retros to: ~/projects/dev-pipeline/sites/{slug}/retros/
- Write plans to: ~/projects/dev-pipeline/sites/{slug}/plans/
- After writing, run: ./scripts/commit-doc.sh <path-to-file>
```

Agents follow these conventions automatically. No agent-side code changes are required — the integration is entirely convention-based through CLAUDE.md instructions.

## 8. Scaffolding Workflow

Creating a new project site record:

```bash
# 1. Scaffold the site (creates folders + overview.md from template)
./scripts/scaffold.sh myproject "My Project"

# 2. Register with The Tower (optional, Tower auto-discovers on next pull)
curl -X POST http://100.103.184.98:7070/api/sites/myproject/onboard
```

**Target time:** Under 1 minute from decision to visible site record in The Tower.

## 9. Success Criteria

| Criterion | Measurement | Target |
|-----------|-------------|--------|
| Site record coverage | Every active project has a `sites/{slug}/` with populated `overview.md` | 100% of active projects |
| Agent doc placement | Agents write docs to correct `sites/` locations via CLAUDE.md conventions | Zero misplaced docs after convention is added |
| Sync latency | Time from `git push` to visible in The Tower | Under 2 minutes |
| Onboarding speed | Time from `scaffold.sh` to site visible in Tower | Under 1 minute |
| Audit trail completeness | All doc changes traceable via `git log` | 100% of changes committed |

## 10. Non-Goals (v1.0)

| Non-Goal | Rationale |
|----------|-----------|
| Bidirectional sync (Tower writes back to repo) | Adds complexity; docs are authored in Claude Code/editor, Tower is read-only |
| Automated stage transitions | Requires trigger logic and validation rules; manual transitions are sufficient for a solo dev |
| File watching / webhooks | Polling via `git pull` every 2 minutes is simple, reliable, and sufficient at current scale |
| Multi-user support | Solo developer — no access control, conflict resolution, or permission model needed |
| Rich media rendering | Markdown only; diagrams are text-based (Mermaid) or linked images |
| Full-text search across sites | The Tower can add this later; `grep` in the repo works for now |

## 11. Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Agents ignore CLAUDE.md conventions and write docs elsewhere | Docs scatter, defeating the purpose | Keep conventions short and explicit; add Stop hook that reminds agents |
| Git conflicts from concurrent sessions | Push fails, doc is lost | Solo dev makes this unlikely; `commit-doc.sh` does pull-before-push |
| Repo grows large with binary files | Slow clones, bloated disk | Convention: no binaries in site records; images are external links or Mermaid |
| Tower pull fails silently | Stale data displayed | Tower scheduler logs pull results; health check verifies last-pull timestamp |
| Pipeline stage tracking diverges between `pipeline.json` and Notion | Confusing source of truth | v1.0 treats Notion as authoritative; `pipeline.json` is informational only |

## 12. Future Considerations (v2.0+)

- **Automated stage transitions** — Git hooks or Tower API triggers that advance pipeline stage based on doc presence (e.g., PRD exists -> move from Ideate to Plan).
- **Pipeline analytics** — Track time-in-stage, cycle time, and throughput across projects.
- **Template library** — Pre-built doc templates per category (PRD template, retro template, handoff template) that agents can populate.
- **Webhook-based sync** — GitHub webhook replaces polling for near-instant Tower updates.
- **CLI tool** — Replace shell scripts with a Go CLI (`pipe scaffold`, `pipe status`, `pipe advance`) for richer interaction.
- **Cross-project dependency graph** — Visualize dependencies between projects in The Tower.

## 13. Dependencies

| Dependency | Owner | Status |
|------------|-------|--------|
| The Tower API (`/api/sites` endpoints) | Dashboard project | In progress (Phase 2+) |
| GitHub repo (`Ruben0372/dev-pipeline`) | Ruben | Created |
| Arch server git pull scheduler | Dashboard project | Planned |
| CLAUDE.md conventions per project | Per-project | Dashboard done, others pending |

## 14. Glossary

| Term | Definition |
|------|-----------|
| Site record | The complete documentation folder for a project under `sites/{slug}/` |
| Category | One of the 11 documentation types (overview, architecture, api, etc.) |
| Stage | One of the 8 pipeline phases (Ideate through Retro) |
| The Tower | Self-hosted dashboard running on Arch (100.103.184.98:3009) |
| Scaffold | Automated creation of a new site record from template |
| Slug | URL-safe project identifier used as folder name (e.g., `dashboard`, `vitalis`) |
| Handoff | Session context document that bridges two Claude Code sessions |
