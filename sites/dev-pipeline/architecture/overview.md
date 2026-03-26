# Architecture Overview

## System Identity

Dev Pipeline is a git-based integration layer between Claude Code sessions and The Tower (Dashboard). It uses a plain git repository as a transport mechanism: Claude Code agents write Markdown documentation during sessions, push to GitHub, and The Tower pulls the repo on a schedule to render the content in the frontend.

There is no custom server, no database, and no API specific to Dev Pipeline itself. Git is the protocol. The filesystem is the schema. Markdown is the format.

## Architecture Diagram

```
 MacBook (Dev Machine)                         Arch (RhudeRuben)
 100.65.194.23                                 100.103.184.98
+--------------------------------------+      +--------------------------------------+
|                                      |      |                                      |
|  Claude Code Session                 |      |  /mnt/WaRlOrD/dashboard-data/        |
|  +-----------+                       |      |  dev-pipeline/                        |
|  | Agent     |                       |      |  +------------------+                 |
|  | (writes)  |                       |      |  | sites/           |                 |
|  +-----+-----+                       |      |  |   dashboard/     |                 |
|        |                             |      |  |   dev-pipeline/  |                 |
|        v                             |      |  |   ...            |                 |
|  ~/projects/dev-pipeline/            |      |  +--------+---------+                 |
|  sites/{slug}/                       |      |           |                           |
|  +------------------+                |      |           | filesystem read            |
|  | overview.md      |                |      |           v                           |
|  | architecture/    |                |      |  Tower API (:7070)                    |
|  | plans/           |                |      |  +------------------+                 |
|  | requirements/    |                |      |  | SiteRecordStore  |                 |
|  | handoffs/        |                |      |  | (reads sites/)   |                 |
|  | ...              |                |      |  +--------+---------+                 |
|  +--------+---------+                |      |           |                           |
|           |                          |      |           | JSON API                   |
|           | git commit + push        |      |           v                           |
|           v                          |      |  Tower Frontend (:3009)               |
|  github.com/Ruben0372/dev-pipeline   |      |  +------------------+                 |
|                                      |      |  | SiteRecordTabs   |                 |
+--------------------------------------+      |  | (renders .md)    |                 |
            |                                 |  +------------------+                 |
            |  git pull (every 2 min)         |                                      |
            +-------------------------------->+--------------------------------------+
                   via Tower scheduled task
```

## Data Flow

```
1. WRITE     Claude Code agent writes .md files to ~/projects/dev-pipeline/sites/{slug}/
2. COMMIT    Agent runs git add + commit (or scripts/commit-doc.sh)
3. PUSH      Agent pushes to github.com/Ruben0372/dev-pipeline
4. PULL      Tower API scheduled task runs git pull every 2 minutes on Arch
5. READ      SiteRecordStore reads the sites/ directory from the filesystem
6. SERVE     Tower API serves site record data as JSON over HTTP
7. RENDER    Tower frontend renders Markdown in SiteRecordTabs component
```

## Components

### sites/ Directory

The core data structure. Each subfolder represents one project and follows a standardized layout:

```
sites/
├── dashboard/
│   ├── overview.md
│   ├── architecture/
│   ├── api/
│   ├── plans/
│   ├── requirements/
│   ├── handoffs/
│   ├── retros/
│   ├── operations/
│   ├── reports/
│   ├── reviews/
│   └── security/
├── dev-pipeline/
│   └── (same structure)
└── {new-project}/
    └── (same structure)
```

Each subfolder maps to a tab in the Tower frontend. The folder name is the site slug. Files within each subfolder are plain Markdown, written by Claude Code agents during development sessions.

### scripts/

| Script | Purpose |
|--------|---------|
| `scaffold.sh` | Creates a new site folder from `templates/new-site/`. Takes a project slug as argument, copies the template, and initializes the directory structure. |
| `commit-doc.sh` | Convenience wrapper for git add + commit + push from within a Claude Code session. |
| `notion-sync-tasks.sh` | Advisory script that reminds the operator to update Notion task status after commits. Not automated -- serves as a post-commit checklist. |

### templates/new-site/

A skeleton directory containing `.gitkeep` files for every standard subfolder. Used by `scaffold.sh` to stamp out new project sites with a consistent structure.

### Integration with The Tower

The Tower API contains a `SiteRecordStore` component that:

1. Reads from the filesystem path where the repo is cloned (`/mnt/WaRlOrD/dashboard-data/dev-pipeline/sites/`)
2. Lists available sites by scanning subdirectories
3. Lists available tabs per site by scanning subfolders
4. Reads individual Markdown files and returns their content
5. Exposes this data through REST endpoints consumed by the frontend

The Tower frontend has a `SiteRecordTabs` component that:

1. Fetches the site list and tab structure from the API
2. Renders a tabbed interface per site
3. Converts Markdown to HTML for display

### Integration with Notion

The `pipeline_states` table in The Tower database maps Notion project UUIDs to site slugs via a `site_slug` column. This allows the Tower to link a Notion project entry to its corresponding site record folder.

The Claude Code `Stop` hook reminds agents to update Notion task status after a session ends. This is advisory, not automated -- the agent surfaces a reminder, and the operator decides whether to act on it.

### Integration with Claude Code

Claude Code agents interact with Dev Pipeline through two mechanisms:

1. **CLAUDE.md conventions** -- Project-level CLAUDE.md files instruct agents to write documentation to `dev-pipeline/sites/{slug}/` as part of their post-commit workflow.
2. **Stop hook** -- A hook that fires when a Claude Code session ends, reminding the agent to update Notion tasks and push any pending documentation.

## Design Decisions

### Git as Transport

Git was chosen over a custom sync protocol or API because:

- Zero infrastructure beyond what already exists (GitHub, git CLI)
- Built-in conflict resolution, history, and rollback
- Works offline -- agents can write and commit without network
- Pull-based sync avoids push notification complexity
- Every change is auditable via git log

### Filesystem as Schema

No database is used for site records. The directory structure is the schema:

- Adding a new project = creating a folder
- Adding a new tab = creating a subfolder
- Adding content = writing a Markdown file
- Removing content = deleting a file

This keeps the system simple and makes it possible for any tool (Claude Code, a text editor, a shell script) to interact with it without a client library.

### Markdown as Format

All content is plain Markdown because:

- Claude Code agents produce Markdown natively
- The Tower frontend can render it directly
- It is human-readable without any tooling
- It diffs cleanly in git

### 2-Minute Pull Interval

The Tower pulls every 2 minutes as a balance between freshness and resource usage. A push-based model (webhooks) was considered but rejected because:

- The Arch host is behind Tailscale with no public ingress
- A 2-minute delay is acceptable for documentation that is not time-critical
- Pull is simpler to implement and debug

## Security Considerations

- The repo is private on GitHub. Access requires GitHub authentication.
- The Arch host is only reachable via Tailscale. No public network exposure.
- All content is documentation (Markdown). No executable code is served from the sites/ directory.
- The Tower API reads the filesystem in read-only mode for site records.

## Failure Modes

| Failure | Impact | Recovery |
|---------|--------|----------|
| Git push fails (network) | Docs not synced until next push | Agent retries on next session |
| Git pull fails on Arch | Tower shows stale data | Scheduled task retries in 2 min |
| Corrupt Markdown file | Single tab renders incorrectly | Fix and push; auto-heals on next pull |
| Scaffold creates duplicate slug | Folder already exists, script should error | Manual cleanup or rename |
| Notion UUID not mapped | Tower cannot link project to site | Add `site_slug` to `pipeline_states` row |
