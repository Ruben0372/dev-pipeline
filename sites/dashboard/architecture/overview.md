# The Tower -- Architecture Overview

## High-Level Architecture

The Tower is a two-container Docker Compose application: a Go API backend and
a React SPA frontend served by nginx. SQLite provides persistence. Both
containers bind exclusively to the Tailscale interface (100.103.184.98). No
traffic touches the public internet.

```
                        Tailscale Network
                              |
               +--------------+--------------+
               |                             |
        :3009 (nginx)                  :7070 (Go API)
               |                             |
     React 19 SPA                   Chi v5 Router
     Vite + Tailwind                     |
               |                  +------+------+
               |                  |             |
          /api/ proxy        Handlers      WebSocket Hub
          /ws/  proxy        (DI struct)        |
               |                  |        gorilla/websocket
               |           +-----+-----+
               |           |     |     |
               |       Services  |  Stores
               |           |     |     |
               |    Notion API   | SQLite (WAL + FTS5)
               |    Google Cal   |     |
               |    Open-Meteo   | /data/dashboard.db
               |    Scheduler    | /data/notes/*.md
               |                 |
               +-----------------+
```

## Backend Structure

### Entrypoint

`api/cmd/server/main.go` -- Wires the entire dependency graph:

```
config.Load()
    -> db.New(path)
    -> CacheStore, TaskStore, DispatchStore, ActivityStore,
       NoteStore, MetricStore, PomodoroStore, CanvasStore,
       PipelineStore, SiteRecordStore
    -> NotionService, CalendarService, WeatherService
    -> TaskSyncService (2-min background poll)
    -> WebSocket Hub (goroutine)
    -> DispatchService + Processor
    -> Scheduler (5-min pipeline audit + 2-min git pull)
    -> handlers.New(...) -- single Handlers struct
    -> chi.NewRouter() -- route registration
    -> http.ListenAndServe()
```

### Handlers Layer (DI Pattern)

All HTTP handlers are methods on a single `Handlers` struct defined in
`handlers/handlers.go`. The struct receives every dependency (stores,
services, hub) via its constructor `New(...)`. Nil dependencies are
allowed -- the corresponding endpoints return 503.

Handler files, one per feature:

| File              | Feature                     |
|-------------------|-----------------------------|
| health.go         | Health check                |
| projects.go       | Notion project proxy        |
| calendar.go       | Google Calendar proxy       |
| tasks.go          | Task CRUD + Notion sync     |
| notes.go          | Notes CRUD + FTS5 search    |
| dispatch.go       | AI dispatch queue + WS      |
| activity.go       | Activity timeline           |
| metrics.go        | API metrics / KPIs          |
| weather.go        | Open-Meteo weather proxy    |
| pomodoro.go       | Pomodoro session tracking   |
| canvases.go       | Freehand canvas CRUD        |
| pipeline.go       | Dev-pipeline stage mgmt     |
| site_records.go   | Site record CRUD (git-backed)|

### Services Layer

| File                | Responsibility                                           |
|---------------------|----------------------------------------------------------|
| notion.go           | Notion API client -- project + task queries, caching     |
| notion_sync.go      | TaskSyncService -- 2-min background Notion task poll     |
| notion_validation.go| Startup schema + connection validation                   |
| gcal.go             | Google Calendar API client, event listing, caching       |
| weather.go          | Open-Meteo HTTP client, response caching                 |
| dispatch.go         | Dispatch queue processor, activity logging               |
| ws_hub.go           | WebSocket hub -- register, unregister, broadcast loop    |
| scheduler.go        | Periodic pipeline audits (5 min) + git-pull (2 min)      |

### Models / Stores Layer

Each store wraps a `*sql.DB` and exposes typed CRUD methods. One store per
database table (or filesystem resource).

| Store            | Backing         | Notes                                      |
|------------------|-----------------|--------------------------------------------|
| CacheStore       | api_cache table | TTL-based key/value for API response cache  |
| TaskStore        | tasks table     | Notion ID tracking for bidirectional sync   |
| DispatchStore    | dispatches table| Prompt queue with status lifecycle          |
| ActivityStore    | activity table  | Append-only event log                       |
| NoteStore        | notes + notes_fts + filesystem | Metadata in SQLite, content as .md files |
| MetricStore      | metrics table   | Per-request method/path/status/duration     |
| PomodoroStore    | pomodoro_sessions table | Work/break session history           |
| CanvasStore      | canvases table  | Stroke data stored as JSON text column      |
| PipelineStore    | pipeline_states + pipeline_history | Stage state + audit log. `site_slug` column maps Notion UUIDs to dev-pipeline folder names |
| SiteRecordStore  | Filesystem      | Reads markdown from dev-pipeline git repo   |

### Middleware

- `chi/middleware.Logger` -- request logging
- `chi/middleware.Recoverer` -- panic recovery
- `chi/middleware.RequestID` -- correlation IDs
- `handlers.MetricsMiddleware` -- records method/path/status/duration to MetricStore
- `go-chi/cors` -- CORS for Tailscale + localhost origins

## Frontend Structure

### Routing

React Router with page-per-route. Each page maps to a top-level feature:

| Page                 | Route              |
|----------------------|--------------------|
| DashboardPage        | /                  |
| ProjectsPage         | /projects          |
| CalendarPage         | /calendar          |
| TasksPage            | /tasks             |
| NotesPage            | /notes             |
| CanvasPage           | /canvas            |
| DispatchPage         | /dispatch          |
| ActivityPage         | /activity          |
| PomodoroPage         | /pomodoro          |
| PipelinePage         | /pipeline          |
| PipelineDetailPage   | /pipeline/:id      |

### State Management

Hooks-only pattern for API data (one custom hook per feature):

| Hook                  | Data Source          |
|-----------------------|----------------------|
| useProjects           | /api/projects        |
| useCalendarEvents     | /api/calendar        |
| useTasks              | /api/tasks           |
| useNotes              | /api/notes           |
| useDispatches         | /api/dispatch        |
| useActivity           | /api/activity        |
| useWebSocket          | /ws/dispatch         |

Zustand stores for client-side state:

| Store            | Purpose                              |
|------------------|--------------------------------------|
| app-store        | Global app state (theme, sidebar)    |
| kpi-store        | Metrics / KPI card data              |
| pipeline-store   | Pipeline visualization state         |
| pomodoro-store   | Timer state, active session          |

### Component Organization

Components grouped by feature under `web/src/components/`:

```
components/
    activity/       Activity timeline components
    calendar/       Calendar event cards
    canvas/         Drawing canvas + toolbar
    dashboard/      KPI cards, overview widgets
    dispatch/       Dispatch form, status cards
    layout/         Shell, sidebar, header
    notes/          BlockNote editor, note list
    pipeline/       Pipeline board, stage cards
    projects/       Project cards, detail views
    tasks/          Task board, task rows
```

### API Client

Single `lib/api.ts` module wraps `fetch()` with base URL configuration
and JSON parsing. All hooks call through this client.

## Database

### Engine

SQLite 3 in WAL (Write-Ahead Logging) mode for concurrent reads during
writes. FTS5 extension enabled at compile time for full-text search.

Database file: `/data/dashboard.db` (volume-mounted from host).

### Migrations

11 sequential migrations (index 0 through 10), tracked in a `schema_version`
table. Append-only -- never edit or reorder existing entries. Applied
automatically on startup inside transactions.

| Index | Tables Created                     | Purpose                          |
|-------|------------------------------------|----------------------------------|
| 0     | api_cache, notes, notes_fts, dispatches, activity | Base schema        |
| 1     | tasks                              | Task board with Notion sync      |
| 2     | (recreate notes_fts)               | Fix FTS5 contentless table       |
| 3     | metrics                            | API observability                |
| 4     | pomodoro_sessions                  | Pomodoro timer history           |
| 5     | canvases                           | Freehand drawing persistence     |
| 6     | pipeline_states                    | Dev-pipeline stage tracking      |
| 7     | site_records, site_records_fts     | Per-project documentation        |
| 8     | scheduled_tasks                    | Cron-like task runner            |
| 9     | pipeline_history                   | Pipeline stage transition audit  |
| 10    | (alter pipeline_states)            | Add `site_slug` column for dev-pipeline folder mapping |

### FTS5 Usage

Two FTS5 virtual tables:

- `notes_fts` -- indexes note title and markdown content for `/api/notes/search?q=`.
- `site_records_fts` -- indexes site record title and content.

Both are contentless (no `content=` table reference) to avoid the v1.0 FTS5
UPDATE crash.

## Real-Time Communication

### WebSocket Hub

`services/ws_hub.go` implements a broadcast hub using gorilla/websocket.
The hub runs as a goroutine with three channels: register, unregister,
broadcast. Thread-safe via channel-based coordination (no mutexes on the
hot path).

Clients connect at `/ws/dispatch`. The nginx config upgrades the connection
via `proxy_http_version 1.1` and `Connection "upgrade"` headers.

Message envelope:

```json
{
  "type": "dispatch_update | pipeline_update",
  "payload": { ... }
}
```

Used by:
- Dispatch processor -- pushes status changes (queued, running, complete, failed).
- Pipeline scheduler -- pushes stage transition notifications.

## External Integrations

| Service          | Client              | Auth                   | Cache    | Sync Interval |
|------------------|----------------------|------------------------|----------|---------------|
| Notion API       | services/notion.go   | NOTION_TOKEN (bearer)  | api_cache| 2 min (tasks) |
| Google Calendar  | services/gcal.go     | GOOGLE_CREDENTIALS (SA)| api_cache| On request    |
| Open-Meteo       | services/weather.go  | None (public API)      | api_cache| On request    |

### Notion Integration

Two databases synced:
- **Projects DB** (collection://325acd44-b460-80fe-9fe1-000b4539045d) -- queried on demand, cached.
- **My Tasks DB** (f7f10e7f-e0d1-41a6-b924-863a8cb80005) -- polled every 2 minutes by TaskSyncService. Tasks stored locally in SQLite with `notion_id` for deduplication.

Startup validation checks connection and schema properties (can be bypassed
with `SKIP_VALIDATION=true`).

### Google Calendar

Service account credentials passed as JSON via `GOOGLE_CREDENTIALS` env var.
Events fetched with a configurable lookahead (default 7 days). Responses
cached in `api_cache` table.

### Open-Meteo Weather

Public API, no authentication. Latitude/longitude configured via
`WEATHER_LAT` / `WEATHER_LON` env vars. Cached responses.

## Dev-Pipeline Integration

The scheduler (`services/scheduler.go`) runs two periodic tasks:

1. **Pipeline audit** (every 5 minutes) -- checks pipeline state consistency.
2. **Git pull** (every 2 minutes) -- pulls latest from the dev-pipeline repo at `DEV_PIPELINE_REPO_PATH` to keep site records current.

Site records are read directly from the filesystem (not from SQLite). The
`SiteRecordStore` walks the directory tree under
`{DEV_PIPELINE_REPO_PATH}/sites/{site_slug}/` and serves markdown files
through the REST API. The `site_slug` column on `pipeline_states` (added in
migration 10) maps a Notion project UUID to the folder name used for lookups.
The frontend reads `state.site_slug` to call `/api/sites/{slug}/records`
instead of using the raw Notion UUID as the path segment.

## Docker

### Compose Services

| Service | Base Image         | Build                                           | Port Binding             |
|---------|--------------------|--------------------------------------------------|--------------------------|
| api     | golang:1.25-alpine | Multi-stage. CGO_ENABLED=1, gcc musl-dev, FTS5   | 100.103.184.98:7070:7070 |
| web     | node -> nginx:alpine | Vite build -> static files served by nginx      | 100.103.184.98:3009:3009 |

### Volume

Single named volume `dashboard-data` bind-mounted from
`/mnt/WaRlOrD/dashboard-data` to `/data` inside the API container.

The Go API validates all file paths against `DATA_ROOT` to prevent path
traversal beyond the mounted volume.

### Health Check

The API container runs `wget -q -O /dev/null http://localhost:7070/health`
every 30 seconds. The web container depends on `api` with
`condition: service_healthy`.

### Port Binding

Both services bind to `100.103.184.98` (Tailscale IP), never `0.0.0.0`.
This ensures zero exposure to the LAN or public internet.

## Data Flow

```
+------------------+          +-------------------+
|   React SPA      |  fetch   |   nginx (:3009)   |
|   (browser)      +--------->|   /api/ proxy     |
|                  |  WS      |   /ws/  proxy     |
+------------------+          +--------+----------+
                                       |
                                       v
                              +--------+----------+
                              |   Go API (:7070)  |
                              |   Chi Router      |
                              |   Middleware       |
                              +---+----+----+-----+
                                  |    |    |
                     +------------+    |    +------------+
                     |                 |                 |
              +------v------+   +------v------+  +------v------+
              |  Services   |   |   Stores    |  |  WebSocket  |
              +------+------+   +------+------+  |    Hub      |
                     |                 |         +------+------+
              +------v------+   +------v------+         |
              | Notion API  |   | SQLite DB   |         |
              | Google Cal  |   | (WAL+FTS5)  |  +------v------+
              | Open-Meteo  |   | /data/*.md  |  |  Browsers   |
              +-------------+   +-------------+  +-------------+
                     |
              +------v------+
              | Scheduler   |
              | - audit 5m  |
              | - git pull  |
              |   2m        |
              +-------------+
```

### Request Lifecycle

1. Browser sends HTTP request to nginx (:3009).
2. Nginx proxies `/api/*` to Go API (:7070). Static assets served directly.
3. Chi router matches route, runs middleware stack (logger, recoverer, request ID, metrics, CORS).
4. Handler method on `Handlers` struct executes. Calls stores for DB access or services for external APIs.
5. Services check `api_cache` before making external HTTP calls. Cache misses fetch from Notion/GCal/Open-Meteo and store the response with a TTL.
6. Handler writes JSON response. MetricsMiddleware records the request.
7. For real-time features, the dispatch processor or scheduler pushes messages through the WebSocket hub to all connected clients.
