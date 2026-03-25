# dev-pipeline

Integration layer between Claude Code sessions and The Tower dashboard.

Agents write documentation here during work. The Tower pulls every 2 minutes and renders site records as tabbed views.

## Structure

```
sites/{project}/          Per-project documentation
  overview.md             Project summary
  architecture/           System design docs
  api/                    API specs
  plans/                  Phase implementation plans
  handoffs/               Build handoffs
  reviews/                Code/architect reviews
  reports/                Status reports
  retros/                 Retrospectives
  security/               Threat models, compliance
  operations/             Deployment, runbooks
  requirements/           PRDs, specs
```

## Scripts

```bash
# Scaffold a new site
./scripts/scaffold.sh dashboard "Dashboard"

# Commit a doc change
./scripts/commit-doc.sh sites/dashboard/handoffs/v1.1.0-handoff.md
```

## How It Works

1. Claude Code agents write docs to `sites/{project}/{category}/`
2. Push to GitHub
3. Arch server pulls every 2 min via Tower scheduler
4. Tower API reads the directory and serves records
5. Frontend renders as tabbed markdown viewer
