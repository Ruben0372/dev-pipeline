# Portfolio — Architecture Overview

**Revised:** 2026-03-28 (post brand discovery)

## System Type

Static site (SSG) with MDX content layer. No backend, no database, no authentication. Project data in code, blog/case study content in MDX files.

## Architecture

```
Next.js 15 (App Router, SSG + MDX)
├── Single-page scroll (/)
│   ├── Hero               — Name, title ("Security Engineer"), scroll CTA
│   ├── About              — Dense bio, values, what I do
│   ├── Projects            — Featured project cards (links to /projects/{slug})
│   ├── Tech Stack          — Categorized badges, dense grid
│   ├── Blog Preview        — Latest 3 posts (links to /blog/{slug})
│   └── Contact             — Email, GitHub, LinkedIn, Upwork/Fiverr
├── Content Routes
│   ├── /projects/{slug}    — Case study pages (MDX, 500-1000 words each)
│   └── /blog/{slug}        — Long-form posts (MDX, 1500-3000 words each)
├── Components
│   ├── sections/           — Scroll sections for the main page
│   ├── ui/                 — shadcn/ui primitives
│   ├── mdx/                — MDX components (code blocks, callouts, diagrams)
│   └── scroll/             — Scroll effects (parallax, sticky, reveals)
├── Content
│   ├── projects/           — MDX case study files
│   └── blog/               — MDX blog post files
├── Data
│   └── projects.ts         — Project metadata (title, slug, tech, links)
└── Lib
    └── utils.ts            — cn() helper
```

## Design System

See `brand-identity.md` for full spec.

**Summary:** Dark canvas (`#0a0a0b`), warm amber accent (`#f59e0b`), dual-font (geometric sans + serif display), dense layout, scroll-driven interactions.

## Key Technical Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Framework | Next.js 15 App Router | SSG, RSC, file-based routing, Vercel deploy |
| Styling | Tailwind CSS v4 + shadcn/ui | Utility-first, component library, dark mode native |
| Content | MDX (blog + case studies) | Markdown with React components, git-backed |
| Animation | Framer Motion | Scroll-triggered reveals, parallax, spring physics |
| Scroll | Lenis or FM useScroll | Smooth scroll with momentum (TBD after testing) |
| Fonts | Inter/Geist + Serif (TBD) + JetBrains Mono | Self-hosted woff2, no CDN |
| Deploy | Vercel | Edge CDN, automatic SSL, preview deploys |
| Icons | Lucide React | Tree-shakeable, consistent stroke width |

## Content Pipeline

```
MDX files (git-tracked)
  → next-mdx-remote / contentlayer / velite (TBD)
  → Static pages at build time
  → Vercel CDN
```

Blog posts and case studies are `.mdx` files in `content/`. Each has frontmatter (title, date, tags, description). Build step compiles to static HTML with React component hydration.

## Key Constraints

- Static site only — no CMS, no backend, no auth
- Dark theme only (v1.0)
- Self-hosted fonts — no Google Fonts CDN
- All project metadata in `src/data/projects.ts`
- MDX content in `content/` directory (git-tracked, not a CMS)
- Vercel deployment target
- Dense layout — information density over whitespace
