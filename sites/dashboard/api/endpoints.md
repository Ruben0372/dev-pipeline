# The Tower API -- Endpoint Reference

Base URL: `http://100.103.184.98:7070`

All endpoints return `application/json`. Errors use a consistent envelope:

```json
{ "error": "description of the problem" }
```

When an optional service (Notion, Google Calendar, Weather) is not configured, the corresponding endpoints return `503 Service Unavailable`.

---

## Health

### GET /health

Returns API health status including database connectivity.

**Response (200)**

```json
{
  "status": "ok",
  "service": "the-tower-api",
  "db": "connected"
}
```

**Response (503)** -- database unreachable

```json
{
  "status": "degraded",
  "service": "the-tower-api",
  "db": "error: <details>"
}
```

---

## Projects (Notion Proxy)

Data is proxied from the Notion Projects database and cached locally.

### GET /api/projects

List all projects.

**Response (200)** -- array of Project objects

```json
[
  {
    "id": "string",
    "name": "string",
    "status": "Not started | In progress | Done",
    "priority": "High | Medium | Low",
    "description": "string",
    "github_repo": "string",
    "team": ["string"],
    "assignee": "string",
    "start_date": "string",
    "end_date": "string",
    "budget": 0.0,
    "created_at": "string",
    "updated_at": "string"
  }
]
```

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 502 | Notion API error |
| 503 | Notion service not configured |

### GET /api/projects/{id}

Get a single project by Notion page ID.

**Path params:** `id` -- Notion page UUID

**Response (200)** -- single Project object (same shape as above)

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 400 | Missing project ID |
| 502 | Notion API error |
| 503 | Notion service not configured |

---

## Pipeline

Tracks projects through the 8-stage development pipeline: ideate, plan, setup, build, test, review, ship, retro.

### GET /api/pipeline

List all project pipeline states.

**Response (200)** -- array of PipelineState objects

```json
[
  {
    "id": "string",
    "project_id": "string",
    "project_name": "string",
    "current_stage": "ideate | plan | setup | build | test | review | ship | retro",
    "previous_stage": "string",
    "stage_entered_at": "ISO 8601",
    "notes": "string",
    "created_at": "ISO 8601",
    "updated_at": "ISO 8601"
  }
]
```

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 500 | Internal error |
| 503 | Pipeline store not configured |

### GET /api/pipeline/{projectId}

Get a single project's pipeline state and transition history.

**Path params:** `projectId` -- project identifier

**Response (200)**

```json
{
  "state": { /* PipelineState */ },
  "history": [
    {
      "id": "string",
      "project_id": "string",
      "from_stage": "string",
      "to_stage": "string",
      "action": "onboard | advance | kickback",
      "reason": "string",
      "created_at": "ISO 8601"
    }
  ]
}
```

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 404 | Project not in pipeline |
| 500 | Internal error |
| 503 | Pipeline store not configured |

### POST /api/pipeline/{projectId}/onboard

Add a project to the pipeline. Broadcasts a `pipeline_update` WebSocket event.

**Path params:** `projectId` -- project identifier

**Request body**

```json
{
  "project_name": "string",
  "stage": "ideate"
}
```

Both fields are optional. `stage` defaults to `"ideate"`, `project_name` defaults to `projectId`.

**Response (201)** -- PipelineState object

| Status | Meaning |
|--------|---------|
| 201 | Created |
| 400 | Invalid stage or JSON |
| 500 | Internal error |
| 503 | Pipeline store not configured |

### PUT /api/pipeline/{projectId}/stage

Advance a project to a new stage. Broadcasts a `pipeline_update` WebSocket event.

**Path params:** `projectId` -- project identifier

**Request body**

```json
{
  "stage": "build",
  "notes": "optional notes"
}
```

**Response (200)** -- updated PipelineState object

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 400 | Invalid stage or JSON |
| 500 | Project not found or internal error |
| 503 | Pipeline store not configured |

### PUT /api/pipeline/{projectId}/kickback

Move a project to a previous stage with a reason. Broadcasts a `pipeline_kickback` WebSocket event.

**Path params:** `projectId` -- project identifier

**Request body**

```json
{
  "stage": "plan",
  "reason": "missing acceptance criteria"
}
```

**Response (200)** -- updated PipelineState object

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 400 | Invalid stage or JSON |
| 500 | Project not found or internal error |
| 503 | Pipeline store not configured |

### GET /api/pipeline/{projectId}/history

Get stage transition history for a project (last 50 entries).

**Path params:** `projectId` -- project identifier

**Response (200)** -- array of PipelineHistoryEntry objects

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 500 | Internal error |
| 503 | Pipeline store not configured |

---

## Calendar (Google Calendar Proxy)

### GET /api/calendar

List calendar events for the next N days.

**Query params:**

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| days | int | 7 | Number of days to fetch (1-30, clamped to 30) |

**Response (200)**

```json
{
  "events": [
    {
      "id": "string",
      "summary": "string",
      "description": "string",
      "location": "string",
      "start_time": "ISO 8601",
      "end_time": "ISO 8601",
      "all_day": false,
      "color": "string",
      "html_link": "string"
    }
  ],
  "count": 5,
  "days": 7
}
```

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 400 | Invalid `days` param |
| 502 | Google Calendar API error |
| 503 | Calendar service not configured |

---

## Tasks

Tasks are stored in local SQLite with optional two-way sync to Notion's My Tasks database.

### GET /api/tasks

List tasks, optionally filtered by status.

**Query params:**

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| status | string | (none) | Filter by task status |

**Response (200)** -- array of Task objects

```json
[
  {
    "id": "string",
    "notion_id": "string",
    "title": "string",
    "status": "string",
    "priority": "string",
    "project": "string",
    "due_date": "string",
    "description": "string",
    "source": "local | notion",
    "created_at": "ISO 8601",
    "updated_at": "ISO 8601"
  }
]
```

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 500 | Internal error |
| 503 | Task store not configured |

### POST /api/tasks

Create a new task. If Notion sync is configured, the task is asynchronously pushed to Notion.

**Request body**

```json
{
  "title": "string (required)",
  "status": "string",
  "priority": "string",
  "project": "string",
  "due_date": "string",
  "description": "string"
}
```

**Response (201)** -- the created Task object

| Status | Meaning |
|--------|---------|
| 201 | Created |
| 400 | Missing title or invalid JSON |
| 500 | Internal error |
| 503 | Task store not configured |

### PUT /api/tasks/{id}

Update an existing task. Only provided fields are merged onto the existing record. Asynchronously syncs to Notion if configured.

**Path params:** `id` -- task UUID

**Request body** -- partial Task (only include fields to update)

```json
{
  "title": "string",
  "status": "string",
  "priority": "string",
  "project": "string",
  "due_date": "string",
  "description": "string"
}
```

**Response (200)** -- the updated Task object

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 400 | Missing ID or invalid JSON |
| 404 | Task not found |
| 500 | Internal error |
| 503 | Task store not configured |

### DELETE /api/tasks/{id}

Delete a task by ID.

**Path params:** `id` -- task UUID

**Response:** 204 No Content (empty body)

| Status | Meaning |
|--------|---------|
| 204 | Deleted |
| 400 | Missing ID |
| 500 | Internal error |
| 503 | Task store not configured |

### POST /api/tasks/sync

Trigger a full Notion-to-local task sync.

**Request body:** none

**Response (200)** -- sync result object from the TaskSyncService

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 502 | Notion API error |
| 503 | Notion sync not configured |

---

## Notes

Notes store metadata in SQLite and markdown content as `.md` files on disk. Full-text search is powered by SQLite FTS5.

### GET /api/notes

List all notes (metadata only, no content).

**Response (200)** -- array of Note objects (content field omitted)

```json
[
  {
    "slug": "string",
    "title": "string",
    "project": "string",
    "tags": "string",
    "created_at": "ISO 8601",
    "updated_at": "ISO 8601"
  }
]
```

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 500 | Internal error |
| 503 | Note store not configured |

### GET /api/notes/search

Full-text search over notes using FTS5.

**Query params:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| q | string | yes | Search query |

**Response (200)** -- array of matching Note objects

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 400 | Missing `q` param |
| 500 | Internal error |
| 503 | Note store not configured |

### GET /api/notes/{slug}

Get a single note with content. Wiki-links in content are resolved before response.

**Path params:** `slug` -- note slug (URL-safe identifier)

**Response (200)** -- Note object with `content` field populated

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 400 | Missing slug |
| 404 | Note not found |
| 500 | Internal error |
| 503 | Note store not configured |

### POST /api/notes

Create a new note. Slug is auto-generated from the title.

**Request body**

```json
{
  "title": "string (required)",
  "content": "string (markdown)",
  "project": "string",
  "tags": "string"
}
```

**Response (201)** -- the created Note object

| Status | Meaning |
|--------|---------|
| 201 | Created |
| 400 | Missing title or invalid JSON |
| 409 | Duplicate slug (title collision) |
| 500 | Internal error |
| 503 | Note store not configured |

### PUT /api/notes/{slug}

Update an existing note's title, content, project, and tags.

**Path params:** `slug` -- note slug

**Request body**

```json
{
  "title": "string (required)",
  "content": "string",
  "project": "string",
  "tags": "string"
}
```

**Response (200)** -- the updated Note object

**Known bug (v1.0):** This endpoint can crash due to an FTS5 virtual table SQL issue. Fixed in v1.0.1.

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 400 | Missing slug/title or invalid JSON |
| 404 | Note not found |
| 500 | Internal error (includes FTS5 bug) |
| 503 | Note store not configured |

---

## Canvas

Freehand drawing canvases stored in SQLite.

### GET /api/canvases

List all canvases (strokes omitted for performance).

**Response (200)** -- array of Canvas objects

```json
[
  {
    "id": "string",
    "title": "string",
    "project": "string",
    "strokes": "[]",
    "width": 1920,
    "height": 1080,
    "created_at": "ISO 8601",
    "updated_at": "ISO 8601"
  }
]
```

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 500 | Internal error |
| 503 | Canvas store not configured |

### POST /api/canvases

Create a new canvas.

**Request body**

```json
{
  "title": "string (default: Untitled Canvas)",
  "project": "string",
  "width": 1920,
  "height": 1080
}
```

All fields are optional. Width defaults to 1920, height to 1080.

**Response (201)** -- the created Canvas object (with strokes as `"[]"`)

| Status | Meaning |
|--------|---------|
| 201 | Created |
| 400 | Invalid JSON |
| 500 | Internal error |
| 503 | Canvas store not configured |

### GET /api/canvases/{id}

Get a single canvas with full stroke data.

**Path params:** `id` -- canvas UUID

**Response (200)** -- Canvas object with strokes

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 404 | Canvas not found |
| 500 | Internal error |
| 503 | Canvas store not configured |

### PUT /api/canvases/{id}

Update a canvas title and/or strokes. Only provided fields are updated.

**Path params:** `id` -- canvas UUID

**Request body**

```json
{
  "title": "string",
  "strokes": "JSON string"
}
```

**Response (200)** -- the updated Canvas object

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 400 | Invalid JSON |
| 500 | Internal error |
| 503 | Canvas store not configured |

### DELETE /api/canvases/{id}

Delete a canvas.

**Path params:** `id` -- canvas UUID

**Response:** 204 No Content (empty body)

| Status | Meaning |
|--------|---------|
| 204 | Deleted |
| 404 | Canvas not found |
| 503 | Canvas store not configured |

---

## Pomodoro

### POST /api/pomodoro/sessions

Record a completed pomodoro session.

**Request body**

```json
{
  "type": "work | break (default: work)",
  "duration_seconds": 1500,
  "completed": true,
  "project": "string"
}
```

`duration_seconds` is required and must be positive.

**Response (201)** -- the created PomodoroSession object

```json
{
  "id": "string",
  "type": "work",
  "duration_seconds": 1500,
  "completed": true,
  "project": "string",
  "created_at": "ISO 8601"
}
```

| Status | Meaning |
|--------|---------|
| 201 | Created |
| 400 | Invalid JSON or missing duration |
| 500 | Internal error |
| 503 | Pomodoro store not configured |

### GET /api/pomodoro/sessions

List pomodoro sessions within a time range.

**Query params:**

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| hours | int | 168 (7 days) | Lookback window in hours |

**Response (200)** -- array of PomodoroSession objects

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 500 | Internal error |
| 503 | Pomodoro store not configured |

---

## Weather

### GET /api/weather

Get current weather data from the Open-Meteo API. Requires `WEATHER_LAT` and `WEATHER_LON` environment variables.

**Response (200)** -- weather data object (shape determined by Open-Meteo response)

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 502 | Open-Meteo API error |
| 503 | Weather service not configured |

---

## Metrics

### GET /api/metrics

Get aggregated API request metrics for a time range. All requests are recorded by the metrics middleware.

**Query params:**

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| hours | int | 24 | Lookback window in hours (1-720) |

**Response (200)**

```json
{
  "total_requests": 1234,
  "error_count": 5,
  "avg_duration_ms": 12.5,
  "uptime_percent": 99.6,
  "by_endpoint": [
    {
      "path": "/api/projects",
      "request_count": 100,
      "error_count": 1,
      "avg_duration_ms": 45.2
    }
  ]
}
```

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 500 | Internal error |
| 503 | Metrics not configured |

---

## Dispatch

AI work dispatch queue with real-time status updates over WebSocket.

### GET /api/dispatch

List all dispatches, ordered by most recent first.

**Response (200)** -- array of Dispatch objects

```json
[
  {
    "id": "string",
    "prompt": "string",
    "project": "string",
    "status": "queued | processing | completed | failed",
    "output": "string",
    "created_at": "ISO 8601",
    "updated_at": "ISO 8601"
  }
]
```

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 500 | Internal error |
| 503 | Dispatch service not configured |

### POST /api/dispatch

Queue a new work dispatch.

**Request body**

```json
{
  "prompt": "string (required)",
  "project": "string"
}
```

**Response (201)** -- the created Dispatch object (status will be `"queued"`)

| Status | Meaning |
|--------|---------|
| 201 | Created |
| 400 | Missing prompt or invalid JSON |
| 500 | Internal error |
| 503 | Dispatch service not configured |

### GET /api/dispatch/{id}

Get a single dispatch by ID, including output if completed.

**Path params:** `id` -- dispatch UUID

**Response (200)** -- Dispatch object

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 400 | Missing ID |
| 404 | Dispatch not found |
| 500 | Internal error |
| 503 | Dispatch service not configured |

### WS /ws/dispatch

WebSocket endpoint for real-time dispatch status updates. Upgrades a standard HTTP connection to WebSocket.

The server pushes JSON messages as dispatch jobs change status. The client should maintain the connection and listen for messages. Also receives `pipeline_update` and `pipeline_kickback` events.

**Message format (server to client)**

```json
{
  "type": "pipeline_update | pipeline_kickback | dispatch_status",
  "payload": { /* varies by type */ }
}
```

| Status | Meaning |
|--------|---------|
| 101 | Switching Protocols (upgrade successful) |
| 503 | WebSocket hub not configured |

---

## Activity

Automatic activity log populated by dispatch completions and other system events.

### GET /api/activity

List recent activity entries.

**Query params:**

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| project | string | (none) | Filter by project name |
| limit | int | 50 | Maximum entries to return |

**Response (200)** -- array of Activity objects

```json
[
  {
    "id": "string",
    "type": "string",
    "project": "string",
    "summary": "string",
    "detail": "string",
    "created_at": "ISO 8601"
  }
]
```

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 500 | Internal error |
| 503 | Activity store not configured |

### GET /api/activity/{id}

Get a single activity entry with full detail.

**Path params:** `id` -- activity UUID

**Response (200)** -- Activity object

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 400 | Missing ID |
| 404 | Activity not found |
| 500 | Internal error |
| 503 | Activity store not configured |

---

## Site Records

Read-only access to markdown documents stored in the `dev-pipeline` git repository. Write operations (POST, PUT, DELETE) return 405 -- records are managed by pushing to the git repo, not through the API.

Default categories (in display order): overview, architecture, api, requirements, plans, handoffs, reviews, reports, retros, security, operations. Custom categories are loaded from `config/categories.json` in the repo.

### GET /api/sites/{projectId}/records

List all records for a project.

**Path params:** `projectId` -- project slug matching the folder name under `sites/`

**Query params:**

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| category | string | (none) | Filter by category folder name |

**Response (200)** -- array of SiteRecord objects (content omitted)

```json
[
  {
    "id": "string (sha256 hash)",
    "project_id": "string",
    "slug": "category/filename",
    "title": "string (from first # heading or filename)",
    "category": "string",
    "updated_at": "ISO 8601 (file mtime)"
  }
]
```

| Status | Meaning |
|--------|---------|
| 200 | Success (empty array if project dir missing) |
| 500 | Internal error |
| 503 | Site records not configured (DEV_PIPELINE_REPO_PATH not set) |

### GET /api/sites/{projectId}/categories

List folder categories with document counts.

**Path params:** `projectId` -- project slug

**Response (200)** -- array of SiteCategory objects

```json
[
  {
    "name": "api",
    "label": "API",
    "count": 3,
    "order": 2
  }
]
```

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 500 | Internal error |
| 503 | Site records not configured |

### GET /api/sites/{projectId}/records/{slug}

Get a single record with full markdown content. Slug format: `"overview"` for root overview, or `"category/filename"` for categorized docs.

**Path params:** `projectId` -- project slug, `slug` -- record path (e.g., `api/endpoints`)

**Response (200)** -- SiteRecord object with `content` field populated

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 404 | Record not found |
| 500 | Internal error |
| 503 | Site records not configured |

### POST /api/sites/{projectId}/records

**Always returns 405.** Records are managed via the dev-pipeline git repo.

### PUT /api/sites/{projectId}/records/{slug}

**Always returns 405.** Records are managed via the dev-pipeline git repo.

### DELETE /api/sites/{projectId}/records/{slug}

**Always returns 405.** Records are managed via the dev-pipeline git repo.

---

## Middleware

All requests pass through the following Chi middleware stack:

| Middleware | Purpose |
|------------|---------|
| Logger | Logs method, path, status, and duration for every request |
| Recoverer | Catches panics and returns 500 instead of crashing |
| RequestID | Assigns a unique ID to each request |
| MetricsMiddleware | Records request method, path, status code, and duration to SQLite |
| CORS | Allows requests from `http://100.103.184.98:3009` and `http://localhost:3009` |

---

## Background Services

| Service | Interval | Description |
|---------|----------|-------------|
| TaskSyncService | 2 minutes | Polls Notion tasks DB and syncs to local SQLite |
| Pipeline Audit Scheduler | 5 minutes | Audits pipeline states and broadcasts updates via WebSocket |
| Dispatch Processor | Continuous | Processes queued dispatch jobs |
| WebSocket Hub | Continuous | Manages client connections and broadcasts events |
