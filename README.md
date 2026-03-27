# dev-pipeline

Integration layer between Claude Code sessions and The Tower dashboard. Self-managing pipeline with issue reporting, auto-dispatch, multi-project profiles, and observability.

**Version:** v1.0.1

## Structure

```
sites/{project}/          Per-project documentation
  overview.md             Project summary
  architecture/           System design docs
  api/                    API specs
  plans/                  Phase plans
  handoffs/               Build handoffs
  reviews/                Code/architect reviews
  reports/                Status reports
  retros/                 Retrospectives
  security/               Threat models, compliance
  operations/             Deployment, runbooks
  requirements/           PRDs, specs
  issues/                 Structured issue reports (v1.0.1)

config/                   Pipeline configuration
  categories.json         Tower tab definitions
  dispatch-rules.json     Severity → dispatch routing

profiles/                 Pipeline profile definitions
  code.yaml               Standard Docker deploy (Dashboard, Atlax, MilEats)
  library.yaml            Registry publish (Mentalist)
  content.yaml            Content export (Adune)
  enterprise.yaml         CDK deploy + compliance (Vitalis)

hooks/                    Claude Code hook scripts
  load-beads.sh           PreToolUse: inject .beads context
  suggest-stage.sh        Stop: suggest pipeline stage advancement

scripts/
  scaffold.sh             Create a new site (--profile support)
  report-issue.sh         File a structured issue report
  cache-warm.sh           Docker image cache warming
  record-metric.sh        Record pipeline stage timing

templates/
  issue-report.md         Issue report YAML frontmatter template
  new-site/               New site scaffold template

metrics/
  pipeline-metrics.jsonl  Pipeline stage timing data (JSON lines)
```

## Issue Reporting

Agents file issues without context-switching:

```bash
./scripts/report-issue.sh <project> \
  --severity <critical|high|medium|low> \
  --domain <frontend|backend|infra|data|devops> \
  --title "Short description" \
  --body "Detailed description"
```

Critical/high issues auto-dispatch. Medium/low need human approval in the Tower.

## Scripts

```bash
# Scaffold a new site with profile
./scripts/scaffold.sh dashboard "Dashboard" --profile code

# File an issue report
./scripts/report-issue.sh dashboard --severity high --domain backend --title "Bug" --body "Details"

# Record a pipeline metric
./scripts/record-metric.sh dashboard v1.0.1 build "2026-03-26T10:00:00Z"

# Warm Docker build cache
./scripts/cache-warm.sh

# Commit a doc change
./scripts/commit-doc.sh sites/dashboard/handoffs/v1.0.1-handoff.md
```

## How It Works

1. Claude Code agents write docs to `sites/{project}/{category}/`
2. Post-commit hook auto-pushes to GitHub
3. Arch server pulls every 2 min via Tower scheduler
4. IssueScanner detects new issues and creates dispatches
5. Tower API serves site records, issues (Kanban), and metrics
6. Frontend renders as tabbed markdown viewer with issue Kanban board

## Profiles

| Profile | Stages | Target |
|---------|--------|--------|
| code | Ideate-Plan-Setup-Build-Test-Review-Ship-Retro | Dashboard, Atlax, MilEats |
| library | Ideate-Plan-Build-Test-Review-Publish-Retro | Mentalist |
| content | Ideate-Plan-Shoot-Edit-Render-Review-Ship-Retro | Adune |
| enterprise | Ideate-Plan-Setup-Build-Test-Review-Compliance-Ship-Retro | Vitalis |
