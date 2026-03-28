# Dispatch System — The Tower

Complete technical documentation for The Tower's AI work dispatch system. This system queues, approves, executes, and monitors AI agent work via the Claude Code CLI.

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Database Schema](#database-schema)
4. [Dispatch Lifecycle](#dispatch-lifecycle)
5. [Approval Flow](#approval-flow)
6. [Issue Scanner Integration](#issue-scanner-integration)
7. [Claude CLI Execution](#claude-cli-execution)
8. [WebSocket Real-Time Events](#websocket-real-time-events)
9. [API Endpoints](#api-endpoints)
10. [Frontend Components](#frontend-components)
11. [Configuration](#configuration)
12. [Docker Setup](#docker-setup)
13. [Testing](#testing)
14. [Troubleshooting](#troubleshooting)

---

## Overview

The dispatch system is The Tower's autonomous work execution engine. It accepts natural-language prompts, routes them through an approval gate, and executes them via the Claude Code CLI inside the API Docker container. Results stream back to the frontend in real time over WebSocket.

**Key capabilities:**
- Manual dispatch submission via the UI or API
- Automatic dispatch creation from dev-pipeline issues (IssueScanner)
- Human-in-the-loop approval gate for medium/low severity work
- Real-time execution streaming via WebSocket
- Retry cap (3 per source issue) to prevent infinite loops
- 10-minute execution timeout per dispatch
- Activity logging for all dispatch events

---

## Architecture

```
                    +------------------+
                    |   DispatchPage   |  (React)
                    |   DispatchForm   |
                    |   DispatchCard   |
                    +--------+---------+
                             |
                    HTTP REST + WebSocket
                             |
                    +--------v---------+
                    |   Chi Router     |
                    |  /api/dispatch/* |
                    |  /ws/dispatch    |
                    +--------+---------+
                             |
                    +--------v---------+
                    | DispatchService  |  Queue manager, CRUD, activity logging
                    +--------+---------+
                             |
              +--------------+--------------+
              |                             |
    +---------v----------+       +----------v-----------+
    | DispatchExecutor   |       | IssueScanner         |
    | (Claude CLI runner)|       | (dev-pipeline issues) |
    +----+----------+----+       +----------+-----------+
         |          |                       |
    +----v----+ +---v----+        +---------v---------+
    | Claude  | |  Hub   |        | SiteRecordStore   |
    | Code CLI| | (WS)   |        | DispatchStore     |
    +---------+ +--------+        +-------------------+
                    |
              +-----v------+
              |  Frontend   |
              |  WebSocket  |
              +-------------+
```

### Component Responsibilities

| Component | File | Role |
|-----------|------|------|
| **DispatchService** | `api/internal/services/dispatch.go` | Queue management, CRUD operations, activity logging, background processor loop |
| **DispatchExecutor** | `api/internal/services/dispatch_executor.go` | Claude CLI invocation, stdout streaming, timeout enforcement, retry tracking |
| **IssueScanner** | `api/internal/services/issue_scanner.go` | Scans dev-pipeline issues, creates dispatches with severity-based approval routing |
| **DispatchStore** | `api/internal/models/dispatch_store.go` | SQLite CRUD for the `dispatches` table |
| **Dispatch** | `api/internal/models/dispatch.go` | Data model struct |
| **Handlers** | `api/internal/handlers/dispatch.go` | HTTP handlers for all dispatch endpoints |
| **Hub** | `api/internal/services/ws_hub.go` | Thread-safe WebSocket broadcast manager |
| **DispatchPage** | `web/src/pages/DispatchPage.tsx` | Main dispatch UI page |
| **DispatchForm** | `web/src/components/dispatch/DispatchForm.tsx` | Prompt submission form |
| **DispatchCard** | `web/src/components/dispatch/DispatchCard.tsx` | Expandable dispatch status card |
| **useDispatches** | `web/src/hooks/useDispatches.ts` | React hook for dispatch CRUD + WebSocket sync |
| **useWebSocket** | `web/src/hooks/useWebSocket.ts` | Persistent WebSocket connection with exponential backoff |

---

## Database Schema

### Table: `dispatches`

Created in migration 0, extended in migration 11.

```sql
CREATE TABLE IF NOT EXISTS dispatches (
    id              TEXT PRIMARY KEY,
    prompt          TEXT NOT NULL,
    project         TEXT,
    status          TEXT NOT NULL DEFAULT 'queued',
    output          TEXT,
    source_issue_id TEXT,                          -- added in migration 11
    approval_status TEXT DEFAULT 'auto',           -- added in migration 11
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Indexes (migration 11)
CREATE INDEX idx_dispatches_source_issue ON dispatches(source_issue_id);
CREATE INDEX idx_dispatches_approval ON dispatches(approval_status);
```

### Column Reference

| Column | Type | Default | Description |
|--------|------|---------|-------------|
| `id` | TEXT (UUID) | Generated | Primary key, UUID v4 |
| `prompt` | TEXT | Required | Natural-language instructions for the AI agent |
| `project` | TEXT | NULL | Optional project scope (used as `--add-dir` for Claude) |
| `status` | TEXT | `'queued'` | Execution status: `queued`, `running`, `completed`, `failed` |
| `output` | TEXT | NULL | Agent output after execution (stdout or error message) |
| `source_issue_id` | TEXT | NULL | Links to a dev-pipeline issue that created this dispatch |
| `approval_status` | TEXT | `'auto'` | Gate status: `auto`, `needs_approval`, `approved`, `rejected` |
| `created_at` | DATETIME | CURRENT_TIMESTAMP | When the dispatch was created |
| `updated_at` | DATETIME | CURRENT_TIMESTAMP | Last status change timestamp |

### Go Model

```go
type Dispatch struct {
    ID             string  `json:"id"`
    Prompt         string  `json:"prompt"`
    Project        *string `json:"project,omitempty"`
    Status         string  `json:"status"`
    Output         *string `json:"output,omitempty"`
    SourceIssueID  *string `json:"source_issue_id,omitempty"`
    ApprovalStatus string  `json:"approval_status"`
    CreatedAt      string  `json:"created_at"`
    UpdatedAt      string  `json:"updated_at"`
}
```

### TypeScript Type

```typescript
interface Dispatch {
    readonly id: string;
    readonly prompt: string;
    readonly project?: string;
    readonly status: "queued" | "running" | "completed" | "failed";
    readonly output?: string;
    readonly source_issue_id?: string;
    readonly approval_status: "auto" | "needs_approval" | "approved" | "rejected";
    readonly created_at: string;
    readonly updated_at: string;
}
```

---

## Dispatch Lifecycle

### State Machine

```
                          +-----------+
      Manual submit ----->|  queued   |<----- IssueScanner
                          +-----+-----+
                                |
                    (approval gate check)
                       /                \
            auto/approved          needs_approval
                  |                      |
                  |              +-------v--------+
                  |              | waiting for    |
                  |              | human approval |
                  |              +---+--------+---+
                  |                  |        |
                  |              approved   rejected
                  |                  |        |
                  |                  |    +---v---+
                  |                  |    | failed|
                  |                  |    +-------+
                  v                  v
            +-----+-----+     +-----+-----+
            |  running   |     |  running   |
            +-----+------+     +-----+------+
                  |                   |
           +------+------+    +------+------+
           |             |    |             |
      +----v----+   +----v---++----v----+   +----v----+
      |completed|   | failed ||completed|   | failed  |
      +---------+   +--------++---------+   +---------+
```

### Status Transitions

| From | To | Trigger |
|------|----|---------|
| — | `queued` | `DispatchService.Submit()` or `IssueScanner.Scan()` |
| `queued` | `running` | `DispatchExecutor.execute()` picks it up |
| `running` | `completed` | Claude CLI exits with code 0 |
| `running` | `failed` | Claude CLI exits non-zero, timeout, or pipe error |
| `queued` | `failed` | User rejects the dispatch via `PUT /dispatch/{id}/reject` |

### Processing Loop

`DispatchService.StartProcessor()` spawns a background goroutine that ticks every **5 seconds**:

```
ticker (5s) → DispatchExecutor.ProcessApproved()
    → List all status="queued" dispatches (FIFO order, oldest first)
    → Skip any with approval_status="needs_approval"
    → Skip any exceeding retry cap (3 per source_issue_id)
    → Execute the first eligible dispatch
    → Return (one dispatch at a time)
```

**Important:** Only one dispatch runs at a time. The executor holds a mutex during execution. Subsequent ticks are no-ops while a dispatch is running.

---

## Approval Flow

### Approval Statuses

| Status | Meaning | Can Execute? |
|--------|---------|--------------|
| `auto` | No human review needed | Yes |
| `needs_approval` | Waiting for human decision | No (blocked) |
| `approved` | Human approved execution | Yes |
| `rejected` | Human rejected, dispatch fails | No (terminal) |

### Manual Dispatches

Dispatches created via the UI (`POST /api/dispatch`) always get `approval_status = "auto"` and execute immediately on the next processor tick.

### Issue-Sourced Dispatches

The IssueScanner determines approval based on issue severity:

| Severity | Default Approval | Rationale |
|----------|-----------------|-----------|
| `critical` | `auto` | Urgent, execute immediately |
| `high` | `auto` | Important, execute immediately |
| `medium` | `needs_approval` | Requires human review |
| `low` | `needs_approval` | Requires human review |

These defaults can be overridden via `config/dispatch-rules.json` in the dev-pipeline repo:

```json
{
  "severity_routing": {
    "critical": { "approval": "auto" },
    "high": { "approval": "auto" },
    "medium": { "approval": "needs_approval" },
    "low": { "approval": "needs_approval" }
  }
}
```

### Approving / Rejecting in the UI

On the dispatch page, dispatches with `approval_status = "needs_approval"` show green checkmark (approve) and red X (reject) buttons. Clicking them calls:

- **Approve:** `PUT /api/dispatch/{id}/approve` — sets `approval_status = "approved"`, dispatch becomes eligible for execution on next tick
- **Reject:** `PUT /api/dispatch/{id}/reject` — sets `approval_status = "rejected"` AND `status = "failed"` with output `"Rejected by user"`

---

## Issue Scanner Integration

The `IssueScanner` bridges The Tower's dev-pipeline issue tracking with the dispatch system.

### How It Works

1. Scans all open issues from `SiteRecordStore.ListAllIssues()`
2. For each open issue, checks if a dispatch already exists (deduplication by `source_issue_id`)
3. If no dispatch exists, creates one with:
   - **Prompt:** `"Fix issue in {project}: {title}\n\nSeverity: {severity}\nDomain: {domain}\n\n{body}"`
   - **Project:** issue's `project_id`
   - **Approval:** determined by `approvalForSeverity()`
4. Broadcasts a WebSocket event (`issue_dispatched` or `issue_needs_approval`)
5. Logs activity

### Deduplication

Each dispatch records the `source_issue_id` it was created from. The scanner calls `DispatchStore.GetBySourceIssue(issueID)` before creating a new dispatch to prevent duplicates.

### Configuration

The scanner loads rules from:
```
{dev-pipeline-repo}/config/dispatch-rules.json
```

If the file doesn't exist, hardcoded defaults apply (critical/high = auto, medium/low = needs_approval).

### Initialization

In `main.go`, the scanner is created with the dev-pipeline repo path:
```go
issueScanner := services.NewIssueScanner(
    siteRecordStore, dispatchStore, activityStore, wsHub,
    cfg.DevPipelineRepoPath,  // e.g., "/data/dev-pipeline"
)
```

Returns `nil` if dependencies are missing (graceful degradation).

---

## Claude CLI Execution

### How Dispatches Are Executed

`DispatchExecutor.execute(d)` performs these steps:

1. **Transition to running** — `UpdateStatus(d.ID, "running", "")`
2. **Broadcast** — `dispatch_update` WebSocket event
3. **Build command** — Construct CLI arguments
4. **Start process** — `exec.CommandContext` with 10-minute timeout
5. **Stream stdout** — Line-by-line via `bufio.Scanner`, broadcast as `dispatch_progress` events
6. **Wait for exit** — Check exit code
7. **On success** — `UpdateStatus(d.ID, "completed", output)`, broadcast `dispatch_completed`, log activity
8. **On failure** — `failDispatch()` with error details, broadcast failure event, log activity

### CLI Arguments

```bash
claude \
    --print \                          # Non-interactive, print response and exit
    --dangerously-skip-permissions \   # No interactive permission prompts (container)
    --no-session-persistence \         # Don't persist sessions to disk
    --add-dir /path/to/project \       # Only if dispatch.project is set
    "the prompt text"                  # Final argument
```

### Timeout

Each dispatch has a **10-minute timeout** enforced via `context.WithTimeout`. If exceeded:
- The process is killed
- Status set to `failed`
- Output includes partial stdout and a timeout message

### Retry Cap

Issue-sourced dispatches track retries per `source_issue_id` in an in-memory map:
- Maximum **3 retries** per issue (`maxRetriesPerIssue = 3`)
- Counter increments on both success and failure
- Resets on service restart (in-memory only)

### Stderr Handling

- stdout is the primary output (streamed over WebSocket)
- stderr is captured in a buffer
- If stdout is empty but stderr has content, stderr becomes the output
- If both are empty, output is `"(no output)"`

### Concurrency

The executor holds a `sync.Mutex` during `ProcessApproved()`. Only one dispatch runs at a time. The 5-second poll loop naturally provides a gap between executions.

---

## WebSocket Real-Time Events

### Connection

- **Endpoint:** `GET /ws/dispatch` (upgraded to WebSocket)
- **Frontend hook:** `useWebSocket("/ws/dispatch")`
- **Reconnect:** Exponential backoff from 1s to 30s max

### Message Envelope

```json
{
  "type": "event_type_here",
  "payload": { ... }
}
```

### Event Types

| Type | Source | Payload | Description |
|------|--------|---------|-------------|
| `new_dispatch` | DispatchService.Submit | Full `Dispatch` object | New dispatch created via API |
| `dispatch_update` | DispatchExecutor.execute | `{dispatch_id, status, chunk}` | Dispatch started running |
| `dispatch_progress` | DispatchExecutor.execute | `{dispatch_id, chunk}` | Stdout line from Claude CLI |
| `dispatch_completed` | DispatchExecutor.execute | `{dispatch_id, issue_id, status, completed_at}` | Dispatch finished (success or failure) |
| `issue_dispatched` | IssueScanner.Scan | `{project, id, dispatch_id, severity, title}` | Auto-approved dispatch created from issue |
| `issue_needs_approval` | IssueScanner.Scan | `{project, id, dispatch_id, severity, title}` | Dispatch created from issue, needs human review |

### Frontend Behavior

The `useDispatches` hook listens for `dispatch_update` events and triggers a full refetch of the dispatch list. This keeps the UI in sync without polling.

### Hub Implementation

The `Hub` runs a single goroutine event loop:
- **register** channel — adds connection to client set
- **unregister** channel — removes connection, closes it
- **broadcast** channel — JSON-encodes message, writes to all clients
- **done** channel — graceful shutdown, closes all connections

Buffered broadcast channel (64 slots) prevents slow clients from blocking the event loop.

---

## API Endpoints

All endpoints are prefixed with `/api/`.

### List Dispatches

```
GET /api/dispatch?page=1&limit=20
```

**Response:** Paginated envelope

```json
{
  "data": [
    {
      "id": "uuid",
      "prompt": "Fix the login bug",
      "project": "Dashboard",
      "status": "completed",
      "output": "I've fixed the login bug by...",
      "source_issue_id": null,
      "approval_status": "auto",
      "created_at": "2026-03-27 10:00:00",
      "updated_at": "2026-03-27 10:05:00"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 42,
    "total_pages": 3,
    "has_next": true,
    "has_prev": false
  }
}
```

### Create Dispatch

```
POST /api/dispatch
Content-Type: application/json

{
  "prompt": "Refactor the auth middleware to use JWT validation",
  "project": "Dashboard"
}
```

**Response:** `201 Created` with the dispatch object. The dispatch is immediately queued with `approval_status = "auto"`.

### Get Single Dispatch

```
GET /api/dispatch/{id}
```

**Response:** `200 OK` with full dispatch object, or `404 Not Found`.

### Approve Dispatch

```
PUT /api/dispatch/{id}/approve
```

**Precondition:** `approval_status` must be `"needs_approval"`.

**Response:** `200 OK`
```json
{ "status": "approved", "id": "uuid" }
```

**Error:** `400 Bad Request` if dispatch is not pending approval.

### Reject Dispatch

```
PUT /api/dispatch/{id}/reject
```

**Response:** `200 OK`
```json
{ "status": "rejected", "id": "uuid" }
```

Sets both `approval_status = "rejected"` and `status = "failed"` with output `"Rejected by user"`.

### WebSocket

```
GET /ws/dispatch
```

Upgrades to WebSocket. No authentication required (Tailscale-only network). See [WebSocket Events](#websocket-real-time-events) for message types.

---

## Frontend Components

### DispatchPage (`web/src/pages/DispatchPage.tsx`)

The main dispatch UI. Contains:
- Header with WebSocket connection indicator (green/red dot)
- DispatchForm for submitting new work
- Filter bar: all | pending | queued | running | completed | failed
- List of DispatchCards

**Filter behavior:**
- `all` — shows everything
- `pending` — filters to `approval_status === "needs_approval"`
- Others — filter by `status` field

### DispatchForm (`web/src/components/dispatch/DispatchForm.tsx`)

Form with:
- Multi-line textarea for the prompt (with character count)
- Optional "Project" text input
- Submit button (disabled while submitting or empty prompt)
- Error display on submission failure
- Clears form on successful submission

### DispatchCard (`web/src/components/dispatch/DispatchCard.tsx`)

Expandable card per dispatch:
- **Collapsed:** Truncated prompt (120 chars), project name, relative timestamp, status badge
- **Expanded:** Full prompt text + output in a scrollable `<pre>` block (max-height 256px)
- **Pending approval:** Shows approve (checkmark) and reject (X) buttons
- **Issue link:** Link icon if `source_issue_id` is present

**Status colors:**
- Queued: zinc-500
- Running: accent color (theme variable)
- Completed: green-400
- Failed: red-400

### useDispatches Hook (`web/src/hooks/useDispatches.ts`)

Provides:
- `dispatches` — readonly array of all dispatches
- `loading` / `error` — fetch state
- `refetch()` — manual refresh
- `submitDispatch(prompt, project?)` — create new dispatch
- `submitting` — submission in-flight flag
- `approveDispatch(id)` — approve pending dispatch
- `rejectDispatch(id)` — reject pending dispatch

Auto-refetches when a `dispatch_update` WebSocket message arrives.

### useWebSocket Hook (`web/src/hooks/useWebSocket.ts`)

Persistent WebSocket connection to `/ws/dispatch`:
- Parses incoming JSON as `WSMessage` objects
- Exponential backoff reconnection (1s initial, 30s max)
- Exposes `lastMessage` and `isConnected`
- Cleans up on component unmount

---

## Configuration

### Environment Variables

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `CLAUDE_PATH` | `claude` | No | Path to the Claude Code CLI binary |
| `ANTHROPIC_API_KEY` | — | **Yes** (for dispatch) | Anthropic API key for Claude Code |
| `DEV_PIPELINE_REPO_PATH` | — | No | Path to dev-pipeline repo for IssueScanner |

### Config Loading (`api/internal/config/config.go`)

```go
ClaudePath: getEnv("CLAUDE_PATH", "claude"),
```

The `ClaudePath` is injected into `DispatchExecutor` at construction time in `main.go`:

```go
dispatchExecutor := services.NewDispatchExecutor(
    dispatchStore, activityStore, wsHub, cfg.ClaudePath,
)
```

### Dispatch Rules File

Optional file at `{DEV_PIPELINE_REPO_PATH}/config/dispatch-rules.json`:

```json
{
  "severity_routing": {
    "critical": { "approval": "auto" },
    "high": { "approval": "auto" },
    "medium": { "approval": "needs_approval" },
    "low": { "approval": "needs_approval" }
  }
}
```

---

## Docker Setup

### API Dockerfile

The API container includes Claude Code CLI:

```dockerfile
# Runtime stage
FROM alpine:3.20

RUN apk add --no-cache sqlite-libs wget ca-certificates git nodejs npm \
    && adduser -D -u 1000 tower \
    && mkdir -p /app /data /home/tower/.claude \
    && chown -R tower:tower /app /data /home/tower

# Install Claude Code CLI globally
RUN npm install -g @anthropic-ai/claude-code && npm cache clean --force
```

### Docker Compose Configuration

```yaml
services:
  api:
    volumes:
      - dashboard-data:/data
      - /home/rhude667/.claude:/home/tower/.claude:ro  # Claude config mount
    environment:
      - CLAUDE_PATH=claude
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
```

**Key points:**
- Claude config directory is mounted read-only from the host
- `ANTHROPIC_API_KEY` is loaded from `.env` file
- The `tower` user (UID 1000) runs the process inside the container
- Claude Code is installed globally via npm in the container

### .env File

Add to your `.env` at the project root:

```bash
CLAUDE_PATH=claude
ANTHROPIC_API_KEY=sk-ant-api03-...
```

---

## Testing

### Test Files

| File | Covers |
|------|--------|
| `api/internal/services/dispatch_executor_test.go` | Executor approval gate, CLI invocation, failure handling |
| `api/internal/services/dispatch_test.go` | Service CRUD, submission, processor lifecycle |
| `api/internal/models/dispatch_store_test.go` | Store CRUD, status updates, dedup queries |
| `api/internal/services/ws_hub_test.go` | Hub broadcast, register/unregister |
| `web/src/hooks/__tests__/useDispatches.test.ts` | Hook fetch, submit, approve/reject |
| `web/src/hooks/__tests__/useWebSocket.test.ts` | WebSocket connection, reconnect, message parsing |

### Test Strategy

Tests use `"echo"` as the Claude CLI stand-in:
- `echo` prints its arguments to stdout and exits 0
- This verifies the full execution pipeline without needing a real Claude binary or API key

```go
const testClaudePath = "echo"

executor := services.NewDispatchExecutor(
    dispatchStore, activityStore, hub, testClaudePath,
)
```

### Running Tests

```bash
# All Go tests
cd api && go test -race ./...

# With coverage
cd api && go test -cover ./...

# Frontend tests
cd web && npm test
```

---

## Troubleshooting

### Dispatch stays "queued" forever

1. **Check approval status:** If `approval_status = "needs_approval"`, the dispatch is waiting for human approval. Approve it via the UI or `PUT /api/dispatch/{id}/approve`.
2. **Check processor is running:** API logs should show `dispatch processor started (executor-backed)` at startup.
3. **Check Claude path:** Verify `CLAUDE_PATH` is set and the binary exists in the container (`docker exec <container> which claude`).
4. **Check retry cap:** If `source_issue_id` is set and the issue has been retried 3 times, it will be silently skipped. Check API logs for `max retries exceeded`.

### Dispatch fails immediately

1. **"Credit balance is too low":** Add credits at `console.anthropic.com`. Verify `ANTHROPIC_API_KEY` is set in `.env`.
2. **"Failed to start Claude CLI":** The `claude` binary is not found. Check the Dockerfile installs it and `CLAUDE_PATH` is correct.
3. **Timeout:** Dispatch ran longer than 10 minutes. Check the prompt complexity. Output will include partial results.

### WebSocket shows "disconnected"

1. **Check API is running:** `curl http://100.103.184.98:7070/health`
2. **Check nginx proxy:** The web container's nginx must proxy `/ws/dispatch` to the API with WebSocket upgrade headers.
3. **Browser console:** Look for WebSocket connection errors. The hook auto-reconnects with exponential backoff up to 30s.

### No dispatches created from issues

1. **Check IssueScanner initialization:** If `DEV_PIPELINE_REPO_PATH` is empty or dependencies are nil, the scanner returns nil and is skipped.
2. **Check issue status:** Only `"open"` issues are scanned.
3. **Check dedup:** If a dispatch already exists for that `source_issue_id`, it won't create another.

### Verifying End-to-End

```bash
# Submit a test dispatch
curl -X POST http://100.103.184.98:7070/api/dispatch \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Say hello world"}'

# Wait 10 seconds, then check status
curl http://100.103.184.98:7070/api/dispatch | python3 -m json.tool

# Check API logs
docker logs dashboard-api-1 --tail 50
```
