---
id: "ISS-dev-pipeline-20260327060923"
severity: "high"
domain: "infra"
status: "open"
reporter: "claude-agent"
source_context: "report-issue.sh"
project: "dev-pipeline"
filed_at: "2026-03-27T06:09:23Z"
dispatch_mode: "auto"
assigned_to: ""
resolved_at: ""
dispatch_id: ""
---

# SSH user missing from all deployment documentation

## Description

The deployment runbook (sites/dashboard/operations/deployment.md line 206) says `ssh 100.103.184.98` with no username. Defaults to the local OS user, not rhude667 (the actual Arch user). Same omission in CLAUDE.md Deploy Path section and overview.md Host section. Caused a failed recovery attempt when Tower went down — agent tried to SSH as wrong user.

Fix: Add `rhude667@` to all SSH commands in deployment.md. Add SSH user to CLAUDE.md and overview.md host tables.

## Environment

- Project: dev-pipeline
- Domain: infra
- Severity: high
- Filed: 2026-03-27T06:09:23Z
