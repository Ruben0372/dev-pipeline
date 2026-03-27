---
id: "ISS-dashboard-20260327163334"
severity: "high"
domain: "infra"
status: "open"
reporter: "claude-agent"
source_context: "report-issue.sh"
project: "dashboard"
filed_at: "2026-03-27T16:33:34Z"
dispatch_mode: "auto"
assigned_to: ""
resolved_at: ""
dispatch_id: ""
---

# Deploy server left on feature branch caused blank page

## Description

The deploy server (~/dashboard-deploy on Arch) was on branch audit/test-coverage which had the new paginated API envelope but the old frontend JS bundle. The frontend tried to .map() on a {data:[],pagination:{}} object instead of a raw array, causing a React runtime crash and blank page. Fix: pulled main and rebuilt both containers. Prevention: deploy workflow must always checkout main before building. Consider adding a branch check to make deploy.

## Environment

- Project: dashboard
- Domain: infra
- Severity: high
- Filed: 2026-03-27T16:33:34Z
