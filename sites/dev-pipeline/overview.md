# Dev Pipeline

## What Is This

An 8-stage development loop (Ideate → Plan → Setup → Build → Test → Review → Ship → Retro) that standardizes how Ruben ships projects with Claude Code. The pipeline is both a methodology and a system — it lives as a git repo, integrates with The Tower for visualization, and uses hooks for automation.

## Version

v1.0 — initial implementation

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
│   └── ...
├── scripts/
│   ├── scaffold.sh           # Create new site record
│   └── notion-sync-tasks.sh  # Post-commit reminder
├── templates/
│   └── new-site/             # Folder template for scaffold
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

## Active Sites

| Site | Project | Slug |
|------|---------|------|
| dashboard | The Tower | `dashboard` |
| dev-pipeline | Dev Pipeline | `dev-pipeline` |

## Links

- GitHub: github.com/Ruben0372/dev-pipeline
- Notion Projects DB: 325acd44-b460-808e-9462-ee5c4bd60f0a
- The Tower: 100.103.184.98:3009/sites

## Current Status

Stage: Build
