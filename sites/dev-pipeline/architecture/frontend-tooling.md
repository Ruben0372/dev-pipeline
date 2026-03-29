# Frontend Tooling — Dev Pipeline Capability

**Added:** 2026-03-28
**Status:** Active
**Scope:** All frontend projects (portfolio, dashboard, any future React/Next.js sites)

---

## Overview

A suite of specialized agents, skills, hooks, and MCP integrations that establish a quality baseline for frontend development across all projects. Built from lessons learned during the portfolio site build (scroll bugs, animation gotchas, design system drift).

## Components

### Agents (4)

Located at `~/.claude/agents/`

| Agent | Model | File | Purpose |
|-------|-------|------|---------|
| **frontend-reviewer** | Sonnet | `frontend-reviewer.md` | React/Next.js code review — component architecture, Framer Motion correctness, Tailwind patterns, client/server boundary violations |
| **frontend-perf** | Sonnet | `frontend-perf.md` | Core Web Vitals (LCP <2.5s, CLS <0.1, INP <200ms), bundle size analysis, image optimization, rendering performance |
| **frontend-a11y** | Sonnet | `frontend-a11y.md` | WCAG 2.1 AA compliance — semantic HTML, ARIA patterns, keyboard navigation, color contrast (4.5:1), focus management, touch targets (44x44px) |
| **design-system-reviewer** | Sonnet | `design-system-reviewer.md` | Design token compliance, component reuse detection, spacing/color/typography consistency, Figma drift detection (when MCP configured) |

### Skills (3)

Located at `~/.claude/skills/`

| Skill | Directory | Command | Purpose |
|-------|-----------|---------|---------|
| **frontend-audit** | `frontend-audit/` | `/frontend-audit` | Full quality gate — launches all 4 agents in parallel, produces unified scorecard (10-point scale per domain), pass/warn/fail verdict |
| **component-gen** | `component-gen/` | `/component-gen` | Scaffolds new React components following project design system — UI atoms, full-page sections, or animated components with correct file placement and token usage |
| **animation-patterns** | `animation-patterns/` | `/animation-patterns` | Pattern library for Framer Motion and CSS animations — scroll reveals, hero entries, enter/exit, hover effects, cursor glow, plus documented anti-patterns and gotchas |

### Hooks (3 PostToolUse)

Configured in `~/.claude/settings.json` under `hooks.PostToolUse`:

| Trigger | What It Catches |
|---------|----------------|
| Edit `.tsx`/`.jsx` | **A11y lint**: `<img>` without `alt`, click handlers on `<div>`/`<span>` (should be `<button>`), removed focus outlines (`outline: none`) |
| Edit `.tsx`/`.jsx` | **CSS anti-pattern**: Hardcoded hex colors in components (should use CSS variables), arbitrary pixel values off the Tailwind spacing scale |
| `npm install` / `pnpm add` | **Bundle guard**: Reminder to run `npm run build` and check bundle size impact after adding packages |

### Rules

Located at `~/.claude/rules/frontend-pipeline.md`

Contains:
- Agent/skill/hook quick reference table
- Frontend PR checklist (10-point gate)
- Animation guidelines (key rules and forbidden patterns)
- Component generation conventions
- Figma integration instructions

### Figma MCP (Placeholder)

Template at `~/.claude/mcp-configs/figma-mcp-template.json`

**Status:** Template ready, awaiting Figma Personal Access Token from Ruben.

**Setup:**
1. Get token from https://www.figma.com/developers/api#access-tokens
2. Copy template to project `.mcp.json`
3. Replace `FIGMA_PERSONAL_ACCESS_TOKEN_HERE` with actual token
4. `design-system-reviewer` agent auto-detects and pulls live design tokens

**When configured, enables:**
- Live design token extraction from Figma files
- Code-vs-Figma token drift detection
- Component spec comparison
- Spacing audit (Figma measurements vs implementation)

## How It Integrates

```
Developer writes/edits .tsx file
        │
        ├──> [AUTOMATIC] PostToolUse hooks fire
        │    ├── a11y lint (missing alt, non-semantic elements)
        │    ├── CSS anti-pattern (hardcoded colors, arbitrary px)
        │    └── bundle guard (on npm install)
        │
        ├──> [ON DEMAND] /frontend-audit
        │    ├── frontend-reviewer agent
        │    ├── frontend-perf agent
        │    ├── frontend-a11y agent
        │    └── design-system-reviewer agent
        │    └── Unified scorecard (pass/warn/fail)
        │
        ├──> [ON DEMAND] /component-gen
        │    └── Scaffolds component with correct tokens + patterns
        │
        └──> [ON DEMAND] /animation-patterns
             └── Reference for correct Framer Motion usage
```

## Existing Complementary Tools

These pre-existing pipeline tools also apply to frontend work:

| Tool | Type | Frontend Use |
|------|------|-------------|
| `code-reviewer` agent | Agent | General code quality (already covers React patterns) |
| `frontend-patterns` skill | Skill | React/Next.js patterns reference (composition, hooks, state, perf) |
| `tdd-workflow` skill | Skill | Test-first approach for components |
| `e2e-runner` agent | Agent | Playwright E2E tests for UI flows |
| `build-error-resolver` agent | Agent | TypeScript/Next.js build error fixes |
| PostToolUse `post-edit-format.js` | Hook (ECC) | Auto-format with Biome/Prettier |
| PostToolUse `post-edit-typecheck.js` | Hook (ECC) | TypeScript check after edits |
| PostToolUse `post-edit-console-warn.js` | Hook (ECC) | Warn about console.log |

## Origin: Portfolio Build Lessons

These tools encode hard-won lessons from building ruben.dev:

1. **Framer Motion `layoutId` resets scroll** — `design-system-reviewer` and `animation-patterns` warn against this
2. **Individual `initial`/`animate` replay on re-render** — `frontend-reviewer` flags this pattern
3. **IntersectionObserver fights programmatic scroll** — documented in `animation-patterns` anti-patterns
4. **Lenis conflicts with native scroll APIs** — documented in gotchas
5. **`scroll-behavior: smooth` CSS breaks everything** — documented in gotchas
6. **Hardcoded colors drift from design tokens** — `design-system-reviewer` + PostToolUse hook catches this
7. **Missing alt text and non-semantic click handlers** — `frontend-a11y` + PostToolUse hook catches this
