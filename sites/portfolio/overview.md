# Portfolio

## Summary

Security-focused full stack developer portfolio and freelance platform hub. Personal brand site for Upwork/Fiverr/LinkedIn that showcases Ruben's security engineering and full-stack work. Warm-dark theme inspired by obsidianos.com with monument photography, glass morphism effects, and scroll-driven animations.

## Tech Stack

* **Framework:** Next.js 15 (App Router, standalone output)
* **Language:** TypeScript 5.7, React 19
* **Styling:** Tailwind CSS v4 (PostCSS plugin, CSS variables), shadcn/ui base
* **Animation:** Framer Motion 12 (variants pattern, whileInView reveals)
* **Content:** MDX via next-mdx-remote + gray-matter
* **Syntax:** Shiki + rehype-pretty-code
* **Icons:** Lucide React
* **Fonts:** Geist Sans, Geist Mono, Playfair Display (self-hosted via next/font)
* **Deploy:** Vercel (TBD)

## Links

* Local: `~/projects/portfolio/`
* CLAUDE.md: `~/projects/portfolio/CLAUDE.md` (full architecture + gotchas)
* GitHub: TBD (create repo — `Ruben0372/portfolio`)
* Live: TBD (deploy to Vercel)
* Freelance strategy: `~/projects/full stack devs with devsec op freelance profile settup/Freelance_GamePlan_Ruben.html`

## Current Status

Stage: Build → Test (v1.0 — site functional, all sections built, navigation working, blog with 2 posts, 1 case study. Remaining: responsive pass, SEO, GitHub deploy)

## Component Inventory

* **Sections (8):** Hero, About, FeaturedProjects, TechStack, BlogPreview, Contact, Navbar, Footer
* **UI (14):** CursorGlow, BackToTop, TiltCard, FocusCard, SectionReveal, BGPattern, GridGlow, ImageBackground, Typewriter, Badge, Button, Card, Separator, Tooltip
* **Content (3 MDX):** 2 blog posts (mTLS, Atlax tunnel), 1 project case study (Atlax)

## Frontend Power Tools

Quality gates for this project are enforced via the frontend agent suite:
* Agents: `frontend-reviewer`, `frontend-perf`, `frontend-a11y`, `design-system-reviewer`
* Skills: `/frontend-audit`, `/component-gen`, `/animation-patterns`
* Rules: `~/.claude/rules/frontend-pipeline.md`
