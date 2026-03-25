# Dashboard — Product Requirements Document

**Author:** Ruben
**Date:** 2026-03-25
**Status:** Draft
**Repo:** github.com/Ruben0372/dashboard (to be created)

---

## 1. Problem Statement

Ruben is a solopreneur and CS student managing 6+ active projects across Notion, Google Calendar, Obsidian, GitHub, Gmail, and Cowork. Context lives in separate apps. There's no single place to see everything at once, dispatch work, or capture thoughts without switching tools. The cognitive overhead of context-switching across tools is a direct tax on productivity.

## 2. Solution

A self-hosted personal command center running on Ruben's Arch Linux server (24/7, Tailscale-only access). One screen that consolidates projects, tasks, calendar, notes, and AI work dispatch — with a Go backend proxying all external APIs and a React frontend rendering everything in real-time.

## 3. Target User

Ruben. Solo. This is a personal tool, not a SaaS product.

## 4. Goals

- Eliminate context-switching between Notion, Calendar, Obsidian, and Cowork
- Full observability of AI-dispatched work (status, outputs, history)
- Capture thoughts and notes without leaving the dashboard
- Single pane of glass for all active projects and upcoming deadlines
- Accessible from MacBook, iPhone, and Arch desktop via Tailscale

## 5. Non-Goals

- Multi-user / team features (solo tool)
- Public internet exposure (Tailscale only)
- Replacing Obsidian, Notion, or Google Calendar (integrates, doesn't replace)
- Mobile-native app (responsive web is sufficient)

## 6. Success Metrics

- Ruben opens Dashboard as his first tab every morning
- Time to find "what should I work on next" drops to < 10 seconds
- All AI work dispatch happens through Dashboard, not ad-hoc
- Notes captured in Dashboard are searchable and linkable to projects

---

## 7. Architecture

### 7.1 System Overview

```
┌──────────────────────────────────────────────────────────────────┐
│                     Tailscale Network                            │
│                                                                  │
│  ┌─────────────┐    ┌──────────────────────────────────────────┐ │
│  │  MacBook /   │    │        Arch Server (RhudeRuben)         │ │
│  │  iPhone      │───▶│  ┌────────────┐   ┌──────────────────┐ │ │
│  │  Browser     │    │  │  React App │   │    Go API        │ │ │
│  └─────────────┘    │  │  :3009     │──▶│    :7070         │ │ │
│                      │  └────────────┘   │                  │ │ │
│                      │                   │  ┌─────────────┐ │ │ │
│                      │                   │  │  SQLite DB   │ │ │ │
│                      │                   │  │  (WaRlOrD)   │ │ │ │
│                      │                   │  └─────────────┘ │ │ │
│                      │                   │                  │ │ │
│                      │                   │  Proxies:        │ │ │
│                      │                   │  → Notion API    │ │ │
│                      │                   │  → Google Cal    │ │ │
│                      │                   │  → GitHub API    │ │ │
│                      │                   └──────────────────┘ │ │
│                      └──────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
```

### 7.2 Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Frontend | React 19 + Vite | Ruben knows React (Vitalis, AtlasShare). Fast HMR for iteration. |
| Styling | Tailwind CSS | Rapid UI development, consistent design tokens |
| Backend | Go + Chi router | Lightweight, single binary. Ruben writes Go (Atlax). 12-core Arch handles it effortlessly. |
| Database | SQLite 3 | Single-user, no need for PostgreSQL. Lives on 7TB drive. |
| Real-time | WebSocket (gorilla/websocket) | Push updates for work dispatch status, live task changes |
| Deployment | Docker Compose | Already running on Arch. Clean isolation from Samba shares. |
| Auth | Tailscale-only binding | API listens only on Tailscale interface (100.103.184.98). No public exposure. |

### 7.3 Data Storage

**Location:** `/mnt/WaRlOrD/dashboard-data/`

```
/mnt/WaRlOrD/
├── admin-vault/     ← SAMBA (DO NOT TOUCH)
├── shared/          ← SAMBA (DO NOT TOUCH)
├── media/           ← SAMBA (DO NOT TOUCH)
└── dashboard-data/  ← OUR DATA (isolated)
    ├── dashboard.db         (SQLite database)
    ├── notes/               (markdown notes)
    ├── dispatch/            (work dispatch logs & outputs)
    └── backups/             (daily SQLite snapshots)
```

**Guardrails:**
- Go API uses an absolute path constant for the data root (`/data` in container, mapped to `/mnt/WaRlOrD/dashboard-data/`)
- Path traversal protection: all file operations validated against the data root
- Docker volume mount is read-write ONLY for `/mnt/WaRlOrD/dashboard-data/` — no other WaRlOrD subdirectories mounted
- Samba shares are completely invisible to the Dashboard containers

### 7.4 Container Architecture

```yaml
# docker-compose.yml
services:
  api:
    build: ./api
    ports:
      - "100.103.184.98:7070:7070"  # Tailscale-only binding
    volumes:
      - /mnt/WaRlOrD/dashboard-data:/data
    environment:
      - DATA_ROOT=/data
      - NOTION_TOKEN=${NOTION_TOKEN}
      - GOOGLE_CREDENTIALS=${GOOGLE_CREDENTIALS}
    restart: unless-stopped

  web:
    build: ./web
    ports:
      - "100.103.184.98:3009:3009"  # Tailscale-only binding
    depends_on:
      - api
    restart: unless-stopped
```

---

## 8. Features (v1)

### 8.1 Project Overview Panel

**What:** Cards for each active project showing name, status, current phase, priority, next action, and GitHub repo link. Data sourced from Notion Projects DB.

**API:** `GET /api/projects` → proxies Notion query on `collection://325acd44-b460-80fe-9fe1-000b4539045d`

**Cache:** SQLite cache with 5-minute TTL. Manual refresh button.

### 8.2 Calendar Strip

**What:** Rolling 7-day view of upcoming events from Google Calendar. Shows event title, time, and calendar color. Click to expand details.

**API:** `GET /api/calendar?days=7` → proxies Google Calendar API for `rhude667@gmail.com`

**Auth:** Google service account or OAuth refresh token stored as env var.

### 8.3 Task Board

**What:** Kanban-style board with columns: Active, Waiting On, Someday, Done. Drag-and-drop reordering. Tasks synced bidirectionally with Notion My Tasks DB.

**API:**
- `GET /api/tasks` → reads from SQLite (primary) + Notion sync
- `PUT /api/tasks/:id` → updates task, syncs to Notion
- `POST /api/tasks` → creates task in both SQLite and Notion
- `POST /api/tasks/sync` → full Notion sync

**Notion sync:** Background goroutine polls Notion every 5 minutes. Conflict resolution: last-write-wins with Notion as source of truth.

### 8.4 Notes (v1 — standalone, Obsidian integration in v2)

**What:** Markdown note editor built into the dashboard. Create, edit, search notes. Notes stored as `.md` files on disk (in `/data/notes/`). Wiki-style linking (`[[note-name]]`) supported in the renderer. Sidebar shows recent notes and project-linked notes.

**API:**
- `GET /api/notes` → list all notes with metadata
- `GET /api/notes/:slug` → read note content
- `PUT /api/notes/:slug` → save note
- `POST /api/notes` → create note
- `GET /api/notes/search?q=term` → full-text search (SQLite FTS5)

**v2 upgrade path:** Mount Obsidian vault as read-only volume, index existing notes, provide bidirectional sync.

### 8.5 Work Dispatch Queue

**What:** Submit tasks/prompts for Claude to execute. See status (queued, running, completed, failed), outputs, and logs. This is the "dispatch work from the dashboard" feature.

**How it works:**
1. User writes a prompt + selects target project in the Dashboard UI
2. Frontend sends `POST /api/dispatch` with prompt and context
3. Go API creates a Cowork scheduled task via the Cowork API (or writes to a dispatch queue that a Cowork session picks up)
4. WebSocket pushes status updates to the frontend as the task progresses
5. Outputs (files, code, reports) are saved to `/data/dispatch/{task-id}/`

**API:**
- `POST /api/dispatch` → create work item
- `GET /api/dispatch` → list all dispatched work
- `GET /api/dispatch/:id` → get status + outputs
- `WS /ws/dispatch` → real-time status stream

### 8.6 Activity Log

**What:** Timeline of everything Claude has done — session summaries, files created, tasks completed, dispatch results. Searchable and filterable by project.

**Data source:** Cowork session transcripts + dispatch history stored in SQLite.

**API:**
- `GET /api/activity?project=vitalis&limit=20` → filtered activity feed
- `GET /api/activity/:id` → full session detail

---

## 9. Phases & Roadmap

### Phase 1: Foundation (Week 1)
- Go API scaffold with Chi router, SQLite setup, Docker Compose
- React app scaffold with Vite, Tailwind, basic layout shell
- Docker build pipeline (multi-stage for Go, nginx for React)
- Health check endpoints, CORS config, Tailscale-only binding
- CI: Makefile with build, test, up, down commands

**Deliverable:** Empty dashboard shell running on Arch at `100.103.184.98:3009`

### Phase 2: Projects + Calendar (Week 2)
- Notion API proxy with token auth and caching
- Google Calendar API proxy with OAuth
- Project overview cards component
- Calendar strip component (7-day rolling view)
- SQLite cache layer with TTL

**Deliverable:** Dashboard shows live projects and calendar

### Phase 3: Task Board (Week 3)
- Task CRUD API with SQLite storage
- Notion bidirectional sync (My Tasks DB)
- Kanban board UI with drag-and-drop (react-beautiful-dnd or dnd-kit)
- Task creation modal with project linking
- Sync status indicator

**Deliverable:** Full task management with Notion sync

### Phase 4: Notes (Week 4)
- Markdown file storage API
- Note editor with live preview (CodeMirror or Monaco)
- Wiki-link parsing and resolution (`[[note]]` → clickable links)
- Full-text search via SQLite FTS5
- Notes sidebar with recent + project-linked notes

**Deliverable:** Working note-taking system in the dashboard

### Phase 5: Work Dispatch + Activity Log (Week 5)
- Dispatch queue API with SQLite job table
- WebSocket server for real-time status
- Integration with Cowork scheduled tasks API
- Dispatch UI: prompt editor, project selector, status cards
- Activity log: timeline view, search, project filtering

**Deliverable:** Full command center — dispatch work and see results

### Phase 6: Polish + v2 Prep (Week 6)
- Responsive layout for iPhone (Safari via Tailscale)
- Dark/light theme toggle
- Keyboard shortcuts (Cmd+K command palette)
- Dashboard widget layout customization
- Performance optimization (lazy loading, virtual scrolling)
- Obsidian integration research and spike

**Deliverable:** Production-ready personal dashboard

---

## 10. v2 Scope (Future)

- Obsidian vault integration (bidirectional sync)
- GitHub integration (PRs, issues, commit activity)
- Gmail integration (inbox preview, quick actions)
- Habit tracking widget (dogfood Vitalis concepts)
- Mobile PWA with push notifications
- AI auto-triage (Claude suggests priority/order for tasks)
- Dashboard-to-dashboard: embed mini-dashboards per project

---

## 11. Setup Tasks (for Ruben on Arch)

Before development starts, these need to happen on the Arch server:

1. Create data directory: `sudo mkdir -p /mnt/WaRlOrD/dashboard-data/{notes,dispatch,backups}` and set permissions
2. Install Go (for local dev iteration): `sudo pacman -S go`
3. Ensure Docker Compose v2 is available: `docker compose version`
4. Generate Google Calendar OAuth credentials (or service account)
5. Create Notion integration token at https://www.notion.so/my-integrations
6. Create GitHub repo: `gh repo create dashboard --private`
7. Open firewall for ports 3009 and 7070 on Tailscale interface only

---

## 12. Risk & Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Samba data corruption | Critical | Docker volumes mount ONLY dashboard-data. Path traversal guards in Go API. |
| Google Calendar token expiry | Medium | Refresh token with auto-renewal. Alert in activity log on auth failure. |
| Notion API rate limits | Low | 5-min cache TTL. Batch operations. Exponential backoff. |
| SQLite concurrent writes | Low | Single Go process handles all writes. WAL mode enabled. |
| Arch system reboots | Low | Docker `restart: unless-stopped`. Systemd timer for daily SQLite backup. |
