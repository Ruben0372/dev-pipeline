---
id: "ISS-dev-pipeline-20260327060943"
severity: "medium"
domain: "infra"
status: "open"
reporter: "claude-agent"
source_context: "report-issue.sh"
project: "dev-pipeline"
filed_at: "2026-03-27T06:09:43Z"
dispatch_mode: "needs_approval"
assigned_to: ""
resolved_at: ""
dispatch_id: ""
---

# pipeline.json is empty — no runtime project state

## Description

pipeline.json contains `{}`. Should track per-project pipeline state including current stage, deploy target, site_slug, and version. Without this, agents have no way to look up which host a project deploys to or what stage it is in without querying the Tower API (which may be down).

Fix: Populate pipeline.json with project entries or replace with a proper state file that the scaffold script initializes.

## Environment

- Project: dev-pipeline
- Domain: infra
- Severity: medium
- Filed: 2026-03-27T06:09:43Z
