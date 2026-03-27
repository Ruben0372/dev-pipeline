---
id: "ISS-dev-pipeline-20260327060950"
severity: "medium"
domain: "infra"
status: "open"
reporter: "claude-agent"
source_context: "report-issue.sh"
project: "dev-pipeline"
filed_at: "2026-03-27T06:09:50Z"
dispatch_mode: "needs_approval"
assigned_to: ""
resolved_at: ""
dispatch_id: ""
---

# Scaffold template missing operations/deployment starter doc

## Description

templates/new-site/operations/ is an empty directory. When scaffold.sh creates a new project site, the operations category has no starter content. Each project's deployment doc is written ad-hoc with no consistent structure, leading to gaps like missing SSH users.

Fix: Add a deployment.md template to templates/new-site/operations/ with placeholders for host, user, deploy path, and standard commands. The scaffold script should interpolate profile deploy config into this template.

## Environment

- Project: dev-pipeline
- Domain: infra
- Severity: medium
- Filed: 2026-03-27T06:09:50Z
