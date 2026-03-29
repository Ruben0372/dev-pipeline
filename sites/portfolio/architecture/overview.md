# Portfolio — Architecture Overview

**Revised:** 2026-03-28 (post UI build, all sections functional)

## System Type

Static site (SSG) with MDX content layer. No backend, no database, no authentication. Project data in code, blog/case study content in MDX files.

## Architecture

```
Next.js 15 (App Router, SSG + MDX, standalone output)
├── Single-page scroll (/)
│   ├── Navbar              — Fixed, scroll spy, smooth scroll nav, glass morphism
│   ├── CursorGlow          — Ambient mouse-following radial gradient
│   ├── BackToTop           — Fixed button, appears after scrolling past hero
│   ├── Hero                — Monument photo bg, Playfair heading, typewriter, scroll CTA
│   ├── About               — Photo collage + bio + 4 value pillars (glass cards)
│   ├── FeaturedProjects    — FocusCard grid (expand-on-hover), links to /projects/{slug}
│   ├── TechStack           — Categorized badges (7 categories), glass cards
│   ├── BlogPreview         — Latest 2 posts (glass cards), links to /blog/{slug}
│   └── Contact             — CTA section with city background
├── Content Routes
│   ├── /blog               — Blog index (getAllPosts)
│   ├── /blog/{slug}        — Individual blog post (MDXRemote, generateStaticParams)
│   ├── /projects           — Projects index
│   └── /projects/{slug}    — Project case study (MDXRemote, generateStaticParams)
├── Components
│   ├── sections/ (8)       — Hero, About, FeaturedProjects, TechStack, BlogPreview, Contact, Navbar, Footer
│   ├── ui/ (14)            — CursorGlow, BackToTop, TiltCard, FocusCard, SectionReveal, BGPattern, GridGlow, ImageBackground, Typewriter, Badge, Button, Card, Separator, Tooltip
│   └── providers/          — LenisProvider (disabled, kept for future use)
├── Content
│   ├── blog/               — 2 MDX posts (mTLS, reverse TLS tunnel)
│   └── projects/           — 1 MDX case study (Atlax)
├── Data
│   └── projects.ts         — Project metadata (7 projects)
├── Lib
│   ├── utils.ts            — cn() helper (clsx + tailwind-merge)
│   └── mdx.ts              — MDX parsing (getPostBySlug, getAllPosts, etc.)
└── Types
    └── mdx.ts              — BlogFrontmatter, ProjectFrontmatter interfaces
```

## Design System

See `brand-identity.md` for full spec.

**Summary:** Dark canvas (`#0a0a0b`), warm amber accent (`#f59e0b`), dual-font (Geist Sans + Playfair Display), glass morphism effects, scroll-driven reveals.

**CSS Utilities:** `.glass` (backdrop-blur + border), `.glass-hover`, `.glow-amber`, `.gradient-text`, `.bg-grid`, `.noise`, `.prose-custom` (MDX styling).

## Key Technical Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Framework | Next.js 15 App Router | SSG, RSC, file-based routing, Vercel deploy |
| Styling | Tailwind CSS v4 (CSS variables) | Utility-first, design tokens via custom properties |
| Components | shadcn/ui base + custom glass UI | Glass morphism, tilt cards, focus cards |
| Content | MDX via next-mdx-remote + gray-matter | Simple, no build dependency, git-backed |
| Animation | Framer Motion (variants pattern) | Parent orchestrates children, prevents re-render replays |
| Scroll | Native `window.scrollTo` | Lenis removed — conflicted with programmatic scroll |
| Nav indicator | CSS opacity transition | Framer Motion `layoutId` caused FLIP scroll resets |
| Scroll spy | IntersectionObserver + `isScrolling` guard | Prevents re-render during programmatic scroll |
| Fonts | Geist Sans + Playfair Display + Geist Mono | Self-hosted via next/font, no CDN |
| Syntax | Shiki + rehype-pretty-code | Code highlighting in MDX blog posts |
| Deploy | Vercel (standalone output) | Edge CDN, automatic SSL, preview deploys |
| Icons | Lucide React | Tree-shakeable, consistent stroke width |

## Content Pipeline

```
content/blog/*.mdx + content/projects/*.mdx (git-tracked)
  → gray-matter (frontmatter parsing)
  → next-mdx-remote/rsc (MDX → React)
  → generateStaticParams (SSG)
  → Static HTML at build time
  → Vercel CDN
```

## Animation Architecture

- **Hero**: Variants on parent `motion.div` (`initial="hidden" animate="visible"`), children inherit via `variants` prop. Prevents re-render animation replay.
- **Sections**: `whileInView` with `once: true, amount: 0.1` for viewport-triggered stagger reveals.
- **Navigation**: Module-level `scrollToSection()` with `isScrolling` flag that pauses IntersectionObserver during programmatic scroll.
- **Cursor glow**: CSS custom properties (`--glow-x`, `--glow-y`) set via mousemove listener. Radial gradient with amber tint.

## Known Gotchas (IMPORTANT)

1. **Do NOT use `scroll-behavior: smooth` CSS** — breaks all programmatic scrolling
2. **Do NOT use Framer Motion `layoutId` in navbar** — FLIP resets scroll position
3. **Do NOT use individual `initial`/`animate` on hero children** — re-renders replay animations and fight scroll
4. **Do NOT use Lenis** — conflicts with `scrollIntoView` and `window.scrollTo`
5. **Guard IntersectionObserver** — always check `!isScrolling` before `setActiveSection`

## Key Constraints

- Static site only — no CMS, no backend, no auth
- Dark theme only (v1.0)
- Self-hosted fonts — no Google Fonts CDN
- MDX content in `content/` directory (git-tracked, not a CMS)
- Vercel deployment target
- Dense layout — information density over whitespace
- Full CLAUDE.md at `~/projects/portfolio/CLAUDE.md`
