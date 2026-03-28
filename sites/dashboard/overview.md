# The Tower

Self-hosted personal command center for a solopreneur managing multiple
concurrent projects. Consolidates projects, tasks, calendar, notes, AI work
dispatch, and dev-pipeline visualization into a single screen.

Formerly known as "Dashboard." Renamed to "The Tower" during v1.1.

Single-user tool. No multi-user auth, no public internet exposure. Runs on
Docker behind Tailscale on a 24/7 Arch Linux server.

## Current Version

v1.1.1

## Tech Stack

| Layer      | Technology                            | Notes                                                                 |
|------------|---------------------------------------|-----------------------------------------------------------------------|
| Backend    | Go 1.25 + Chi v5                      | Module: `github.com/Ruben0372/dashboard/api`. CGO required for SQLite |
| Frontend   | React 19 + Vite + TypeScript + Tailwind CSS | IBM Plex Mono font, Lucide icons, dark/light via prefers-color-scheme |
| Database   | SQLite 3 (WAL mode + FTS5)            | `mattn/go-sqlite3`. File at `/data/dashboard.db`                      |
| Real-time  | WebSocket (gorilla/websocket)         | Dispatch status + pipeline updates                                    |
| Deploy     | Docker Compose                        | Multi-stage builds. CGO + FTS5 build flags                            |
| Network    | Tailscale only                        | No public internet exposure                                           |

## Host

| Property   | Value                        |
|------------|------------------------------|
| Machine    | RhudeRuben (Arch Linux 6.19) |
| Tailscale  | 100.103.184.98               |
| CPU / RAM  | 12 cores / 16 GB             |
| API port   | 7070                         |
| Web port   | 3009                         |

## Features

- **Dev-pipeline visualization** -- 8-stage construction pipeline (Ideate, Plan, Setup, Build, Test, Review, Ship, Retro) with onboarding, stage advancement, kickback, and audit history.
- **KPI cards** -- API metrics dashboard (request count, p50/p95 latency, error rate, uptime).
- **Calendar** -- Google Calendar integration with 7-day lookahead.
- **Tasks** -- Local + Notion-synced task board with status, priority, due dates. Background sync every 2 minutes.
- **Notes** -- Markdown notes with BlockNote rich-text editor. FTS5 full-text search. File-backed content (`.md` on disk, metadata in SQLite).
- **Canvas** -- Freehand drawing canvas with stroke persistence.
- **Pomodoro** -- Work/break session timer with history tracking.
- **Weather** -- Current conditions and forecast via Open-Meteo API.
- **Dispatch** -- AI work queue backed by Claude Code CLI. Supports manual and issue-sourced dispatches, human-in-the-loop approval gate (auto/needs_approval/approved/rejected), real-time execution streaming over WebSocket, 10-minute timeout, and retry cap (3 per issue). See `architecture/dispatch.md` for full details.
- **Activity** -- Chronological activity timeline across all features.
- **Site records** -- Per-project documentation served from the dev-pipeline git repo (filesystem-backed, git-synced every 2 minutes). Each pipeline project maps to a folder via `site_slug` (e.g., a Notion UUID maps to `"dashboard"`) so the frontend resolves records at `/api/sites/{site_slug}/records`.

## Links

| Resource       | URL / ID                                                     |
|----------------|--------------------------------------------------------------|
| GitHub repo    | github.com/Ruben0372/dashboard                               |
| Notion project | 325acd44-b460-808e-9462-ee5c4bd60f0a (Projects DB)           |
| Notion tasks   | f7f10e7f-e0d1-41a6-b924-863a8cb80005 (My Tasks DB)           |

## Data

All persistent data lives at `/mnt/WaRlOrD/dashboard-data/` on the host,
volume-mounted as `/data` inside the API container. 1 TB allocated maximum.

```
/mnt/WaRlOrD/dashboard-data/
    dashboard.db        SQLite database (WAL mode)
    notes/              Markdown note files
    dispatch/           Dispatch output artifacts
    backups/            SQLite snapshots (make backup)
    dev-pipeline/       Cloned dev-pipeline repo (git-pulled every 2m)
```

Samba shares on the same drive (`admin-vault`, `shared`, `media`) are
off-limits. Only `dashboard-data/` is mounted into Docker.
