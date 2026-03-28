# Portfolio — Architecture Overview

## System Type

Static site (SSG). No backend, no database, no authentication. All data lives in code (`src/data/projects.ts`).

## Architecture

```text
Next.js 15 (App Router, SSG)
├── Pages (4)
│   ├── / (Home)           — Hero, Services, FeaturedProjects, TechStack, CTA
│   ├── /projects          — Full gallery with all 7 projects
│   ├── /about             — Bio, values grid, CTA
│   └── /contact           — Contact methods, "what to expect" process
├── Components
│   ├── sections/          — Page-level section components (7)
│   └── ui/                — shadcn/ui + 21st.dev primitives (TBD)
├── Data
│   └── projects.ts        — Single source of truth: projects, services, tech stack
└── Lib
    └── utils.ts           — cn() helper (clsx + tailwind-merge)
```

## Design System

**Theme:** "Terminal Meets Modern" — dark, security-engineer aesthetic.

| Token                | Hex       | Usage                   |
| -------------------- | --------- | ----------------------- |
| `--color-bg`         | `#0f1117` | Page background         |
| `--color-surface`    | `#1a1d27` | Cards, navbar           |
| `--color-surface-2`  | `#232736` | Nested surfaces         |
| `--color-border`     | `#2e3347` | Borders                 |
| `--color-text`       | `#e4e6f0` | Primary text            |
| `--color-text-muted` | `#8b8fa8` | Secondary text          |
| `--color-accent`     | `#6c63ff` | Primary accent (purple) |
| `--color-green`      | `#00d4aa` | Security/success        |

**Fonts:** Inter (headings + body), JetBrains Mono (code/terminal). Currently Google Fonts CDN — self-host before production.

## Key Constraints

* Static site only — no CMS, no backend, no auth

* Data model is `src/data/projects.ts` — all pages consume it; never restructure

* Dark theme only — no light mode toggle

* Vercel deployment target
