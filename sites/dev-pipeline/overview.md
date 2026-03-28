# Dev Pipeline

## What Is This

An 8-stage development loop (Ideate → Plan → Setup → Build → Test → Review → Ship → Retro) that standardizes how Ruben ships projects with Claude Code. The pipeline is both a methodology and a system — it lives as a git repo, integrates with The Tower for visualization, and uses hooks for automation.

## Version

v1.0.1 — issue reporting, auto-dispatch, multi-project profiles, observability

## Tech

- **Repo**: github.com/Ruben0372/dev-pipeline
- **Integration**: The Tower reads `sites/` directory for site records
- **Sync**: Arch pulls repo every 2 min via scheduled task in The Tower API
- **Hooks**: Claude Code `Stop` hook reminds agents to update Notion tasks
- **Scaffold**: `scripts/scaffold.sh` creates standardized site record folders

## Structure

```
dev-pipeline/
├── sites/                    # Per-project documentation
│   ├── dashboard/            # The Tower
│   ├── dev-pipeline/         # This project (meta)
│   ├── portfolio/            # Portfolio site
│   └── ...
├── scripts/
│   ├── scaffold.sh           # Create new site with profile support
│   ├── report-issue.sh       # File structured issue reports
│   ├── record-metric.sh      # Record pipeline stage timing data
│   ├── commit-doc.sh         # Commit docs with standardized messages
│   ├── cache-warm.sh         # Docker image cache warming
│   └── notion-sync-tasks.sh  # Sync tasks with Notion
├── config/
│   ├── categories.json       # 12 category types with labels, ordering, icons
│   ├── dispatch-rules.json   # Severity -> dispatch routing rules
│   └── stages.json           # Pipeline stage definitions
├── profiles/
│   ├── code.yaml             # Standard Docker deploy (Dashboard, Atlax, MilEats)
│   ├── library.yaml          # Registry publish (Mentalist)
│   ├── content.yaml          # Content export (Adune)
│   └── enterprise.yaml       # CDK deploy + compliance (Vitalis)
├── templates/
│   ├── new-site/             # Folder template for scaffold
│   └── issue-report.md       # YAML frontmatter template for issues
└── README.md
```

## Site Record Standard

Each site has these tabs (subfolders):

| Folder | Purpose |
|--------|---------|
| overview.md | Project identity, tech stack, links |
| architecture/ | System design, diagrams, ADRs |
| api/ | API endpoints, schemas |
| plans/ | Implementation plans, phase breakdowns |
| requirements/ | PRDs, feature specs |
| handoffs/ | Session handoff docs |
| retros/ | Retrospectives, post-mortems |
| operations/ | Deploy guides, runbooks |
| reports/ | Metrics, performance reviews |
| reviews/ | Code review summaries |
| security/ | Security audits, compliance |
| issues/ | Structured issue reports (timestamped, YAML frontmatter with severity/domain/status) |

## Active Sites

| Site | Project | Slug |
|------|---------|------|
| dashboard | The Tower | `dashboard` |
| dev-pipeline | Dev Pipeline | `dev-pipeline` |
| portfolio | Portfolio | `portfolio` |

## Links

- GitHub: github.com/Ruben0372/dev-pipeline
- Notion Projects DB: 325acd44-b460-808e-9462-ee5c4bd60f0a
- The Tower: 100.103.184.98:3009/sites

## Current Status

Stage: Build
