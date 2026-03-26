# The Tower -- Deployment Runbook

---

## Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| Docker | 29.3.0+ | With Docker Compose v2 |
| Tailscale | Latest | Machine must be on the tailnet |
| SSH access | -- | To RhudeRuben (100.103.184.98) |
| Git | Latest | For pulling updates |

---

## Host Information

| Property | Value |
|----------|-------|
| Hostname | RhudeRuben |
| OS | Arch Linux 6.19.9 |
| Tailscale IP | 100.103.184.98 |
| CPU | 12 cores |
| RAM | 16GB |
| API port | 7070 |
| Web port | 3009 |
| Deploy path | `~/dashboard-deploy/` |

---

## Data Directories

All persistent data lives on the 7.3TB drive mounted at `/mnt/WaRlOrD`:

| Path | Purpose | Mount in Container |
|------|---------|--------------------|
| `/mnt/WaRlOrD/dashboard-data/` | Root data directory | `/data` |
| `/mnt/WaRlOrD/dashboard-data/dashboard.db` | SQLite database (WAL mode) | `/data/dashboard.db` |
| `/mnt/WaRlOrD/dashboard-data/notes/` | Markdown note files | `/data/notes/` |
| `/mnt/WaRlOrD/dashboard-data/dispatch/` | Dispatch job outputs | `/data/dispatch/` |
| `/mnt/WaRlOrD/dashboard-data/backups/` | Database snapshots | `/data/backups/` |
| `/mnt/WaRlOrD/dashboard-data/sites/` | Site record cache | `/data/sites/` |
| `/mnt/WaRlOrD/dashboard-data/dev-pipeline/` | Dev-pipeline repo clone | `/data/dev-pipeline` |

**CRITICAL:** Do not expand the volume mount beyond `dashboard-data/`. The parent directory contains Samba shares (`admin-vault`, `shared`, `media`) that must not be accessed.

---

## Environment Configuration

Create a `.env` file in the deploy directory. Copy from `.env.example` and fill in real values.

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `NOTION_TOKEN` | Notion integration token from notion.so/my-integrations | `secret_abc123...` |
| `NOTION_PROJECTS_DB` | Notion data source ID for the Projects database (the collection:// UUID, not the database page ID) | `325acd44-b460-80fe-9fe1-000b4539045d` |
| `NOTION_TASKS_DB` | Notion database ID for My Tasks | `f7f10e7f-e0d1-41a6-b924-863a8cb80005` |
| `GOOGLE_CREDENTIALS` | Google service account JSON (single-line, entire JSON object) | `{"type":"service_account",...}` |
| `GOOGLE_CALENDAR_ID` | Google Calendar ID | `rhude667@gmail.com` |

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `7070` | API server port |
| `DATA_ROOT` | `/data` | Root directory for all persistent data inside the container |
| `WEATHER_LAT` | (none) | Latitude for weather service (Open-Meteo) |
| `WEATHER_LON` | (none) | Longitude for weather service (Open-Meteo) |
| `DEV_PIPELINE_REPO_PATH` | (none) | Path to the dev-pipeline git repo inside the container. Set to `/data/dev-pipeline` in Docker. |
| `SKIP_VALIDATION` | `false` | Set to `true` to skip Notion connection and schema validation at startup |

### Degraded Mode

If optional credentials are missing, the API starts in degraded mode. Affected endpoints return 503 with a descriptive error. The rest of the API functions normally.

| Missing Variable | Affected Feature |
|-----------------|-----------------|
| `NOTION_TOKEN` or `NOTION_PROJECTS_DB` | Projects endpoints return 503 |
| `NOTION_TASKS_DB` | Task sync disabled (local tasks still work) |
| `GOOGLE_CREDENTIALS` | Calendar endpoints return 503 |
| `WEATHER_LAT` or `WEATHER_LON` | Weather endpoint returns 503 |
| `DEV_PIPELINE_REPO_PATH` | Site records endpoints return 503 |

---

## Docker Compose Architecture

Two services defined in `docker-compose.yml`:

### api

- **Image:** Go 1.25-alpine multi-stage build
- **Build flags:** `CGO_ENABLED=1 CGO_CFLAGS="-DSQLITE_ENABLE_FTS5"` (required for SQLite FTS5)
- **Runtime packages:** `sqlite-libs`, `wget`, `ca-certificates`, `git`
- **Port binding:** `100.103.184.98:7070:7070` (Tailscale only)
- **Volume:** `dashboard-data:/data` (bind mount to `/mnt/WaRlOrD/dashboard-data`)
- **Health check:** `wget -q -O /dev/null http://localhost:7070/health` every 30s
- **Restart policy:** `unless-stopped`

### web

- **Image:** Node 22-alpine build, nginx:alpine runtime
- **Port binding:** `100.103.184.98:3009:3009` (Tailscale only)
- **Depends on:** `api` (condition: `service_healthy`)
- **Nginx:** SPA routing, `/api/` proxy to Go backend, `/ws/` WebSocket proxy
- **Restart policy:** `unless-stopped`
- **Environment:** `VITE_API_URL=http://100.103.184.98:7070`

---

## Deploy Commands

All commands run from the deploy directory (`~/dashboard-deploy/`).

### Build and start

```bash
docker compose up -d --build
```

Or using the Makefile:

```bash
make up
```

### Stop

```bash
docker compose down
```

Or:

```bash
make down
```

### Build without starting

```bash
docker compose build
```

Or:

```bash
make build
```

### View logs

```bash
# All services
docker compose logs -f

# API only
docker compose logs -f api

# Web only
docker compose logs -f web
```

Or:

```bash
make logs       # all
make api-logs   # api only
make web-logs   # web only
```

### Health check

```bash
curl -s http://100.103.184.98:7070/health | jq .
```

Or:

```bash
make health
```

### Full cleanup (removes volumes and images)

```bash
docker compose down -v --rmi local
```

Or:

```bash
make clean
```

---

## Deploy Checklist

Run through these steps for every deployment.

1. **SSH into RhudeRuben**
   ```bash
   ssh 100.103.184.98
   ```

2. **Navigate to deploy directory**
   ```bash
   cd ~/dashboard-deploy
   ```

3. **Pull latest code**
   ```bash
   git pull origin main
   ```

4. **Verify .env is present and correct**
   ```bash
   cat .env | head -5
   ```

5. **Build and start containers**
   ```bash
   make up
   ```

6. **Watch build output for errors**
   ```bash
   docker compose logs -f --tail=50
   ```

7. **Health check**
   ```bash
   make health
   ```
   Expected response:
   ```json
   {
     "status": "ok",
     "service": "the-tower-api",
     "db": "connected"
   }
   ```

8. **Verify frontend is accessible**
   Open `http://100.103.184.98:3009` from any device on the tailnet.

9. **Check API logs for startup warnings**
   ```bash
   make api-logs
   ```
   Look for `WARNING:` lines indicating unconfigured services. These are acceptable if the corresponding features are intentionally disabled.

---

## Rollback Procedure

If a deployment causes issues:

1. **Stop the broken deployment**
   ```bash
   make down
   ```

2. **Check out the previous working commit**
   ```bash
   git log --oneline -5          # find the last known-good commit
   git checkout <commit-hash>
   ```

3. **Rebuild and restart**
   ```bash
   make up
   ```

4. **Verify health**
   ```bash
   make health
   ```

5. **If the database is corrupted, restore from backup**
   ```bash
   cp /mnt/WaRlOrD/dashboard-data/backups/dashboard-YYYYMMDD.db \
      /mnt/WaRlOrD/dashboard-data/dashboard.db
   make down && make up
   ```

6. **Return to main branch when the fix is ready**
   ```bash
   git checkout main
   ```

---

## Backup

### Manual backup

```bash
make backup
```

This copies `dashboard.db` to `/mnt/WaRlOrD/dashboard-data/backups/dashboard-YYYYMMDD.db`.

### Recommended schedule

Run `make backup` daily via cron:

```cron
0 3 * * * cd ~/dashboard-deploy && make backup
```

### Restore

```bash
make down
cp /mnt/WaRlOrD/dashboard-data/backups/dashboard-YYYYMMDD.db \
   /mnt/WaRlOrD/dashboard-data/dashboard.db
make up
```

SQLite uses WAL mode, so the backup captures a consistent snapshot even during reads.

---

## Monitoring

### Health endpoint

```bash
curl -s http://100.103.184.98:7070/health | jq .
```

Returns `"status": "ok"` when healthy, `"status": "degraded"` with `"db": "error: ..."` when the database is unreachable.

The Docker health check polls this endpoint every 30 seconds with 3 retries before marking the container as unhealthy. The web container depends on the API being healthy before starting.

### API metrics

```bash
curl -s http://100.103.184.98:7070/api/metrics | jq .
curl -s "http://100.103.184.98:7070/api/metrics?hours=168" | jq .
```

Returns total requests, error counts, average latency, uptime percentage, and per-endpoint breakdowns.

### Container status

```bash
docker compose ps
```

### API logs

```bash
make api-logs
```

Key log lines to watch for:

| Pattern | Meaning |
|---------|---------|
| `The Tower API starting on :7070` | Successful startup |
| `Database initialized:` | SQLite connected |
| `Notion service initialized` | Notion integration active |
| `Google Calendar service initialized` | Calendar integration active |
| `Pipeline audit scheduler started (interval: 5m)` | Background scheduler running |
| `Task sync service initialized (tasks DB: ..., interval: 2m)` | Notion task sync active |
| `WARNING:` | Non-fatal -- a service is not configured |
| `FATAL:` | Startup failure -- container will exit |
| `ERROR:` | Runtime error -- investigate |

### Scheduler logs

The pipeline audit scheduler runs every 5 minutes. The task sync service polls Notion every 2 minutes. Both log to the API container's stdout.

### WebSocket

The WebSocket hub at `/ws/dispatch` broadcasts `pipeline_update`, `pipeline_kickback`, and dispatch status events. Connection count is not currently exposed via the API.

---

## Network

All ports are bound to the Tailscale IP (`100.103.184.98`), never to `0.0.0.0`. The API and frontend are only accessible from devices on the tailnet.

| Service | URL |
|---------|-----|
| API | `http://100.103.184.98:7070` |
| Frontend | `http://100.103.184.98:3009` |
| Health | `http://100.103.184.98:7070/health` |
| WebSocket | `ws://100.103.184.98:7070/ws/dispatch` |

CORS is configured to allow requests from `http://100.103.184.98:3009` and `http://localhost:3009`.

---

## Running Tests

### API tests (Go)

```bash
cd api && CGO_CFLAGS="-DSQLITE_ENABLE_FTS5" go test ./... -v -cover
```

Or:

```bash
make test-api
```

### Frontend tests (Vitest)

```bash
cd web && npx vitest run
```

Or:

```bash
make test-web
```

### All tests

```bash
make test
```
