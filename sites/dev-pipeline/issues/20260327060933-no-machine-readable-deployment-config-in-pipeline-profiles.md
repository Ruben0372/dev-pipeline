---
id: "ISS-dev-pipeline-20260327060933"
severity: "high"
domain: "infra"
status: "open"
reporter: "claude-agent"
source_context: "report-issue.sh"
project: "dev-pipeline"
filed_at: "2026-03-27T06:09:33Z"
dispatch_mode: "auto"
assigned_to: ""
resolved_at: ""
dispatch_id: ""
---

# No machine-readable deployment config in pipeline profiles

## Description

profiles/code.yaml defines pipeline stages and `ship_action: make ship` but has zero deployment connection info — no SSH user, no remote host, no deploy path, no remote commands. This means agents cannot programmatically deploy or recover services without relying on prose buried in markdown docs.

Fix: Add a `deploy` block to each profile with host, user, path, and commands. Example:
```yaml
deploy:
  host: 100.103.184.98
  user: rhude667
  path: ~/dashboard-deploy
  commands:
    start: make up
    stop: make down
    health: make health
```
Also create a shared hosts.yaml that profiles reference.

## Environment

- Project: dev-pipeline
- Domain: infra
- Severity: high
- Filed: 2026-03-27T06:09:33Z
