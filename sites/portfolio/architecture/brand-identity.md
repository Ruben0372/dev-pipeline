# Portfolio — Brand Identity

**Date:** 2026-03-28 **Status:** Locked (brand discovery complete)

***

## Positioning

**Name:** Ruben **Title:** Security Engineer **One-liner:** "Security Engineer" — short, declarative, let the work prove the rest.

**Brand promise:** "This person builds things that matter." Craft, depth, substance over flash.

***

## Visual Identity

### Palette

Dark canvas with warm amber accent. Premium, uncommon in dev portfolios. Stands out from the blue/purple/teal crowd.

| Token         | Hex                       | Role                           |
| ------------- | ------------------------- | ------------------------------ |
| Background    | `#0a0a0b`                 | True dark, near-black          |
| Surface       | `#141417`                 | Cards, elevated sections       |
| Surface-2     | `#1c1c21`                 | Nested containers, code blocks |
| Border        | `#27272a`                 | Subtle dividers                |
| Text          | `#fafafa`                 | Primary text (zinc-50)         |
| Text-muted    | `#a1a1aa`                 | Secondary text (zinc-400)      |
| Accent        | `#f59e0b`                 | Warm amber — primary accent    |
| Accent-hover  | `#d97706`                 | Amber darker for hover states  |
| Accent-subtle | `rgba(245, 158, 11, 0.1)` | Amber glow backgrounds         |
| Success       | `#10b981`                 | Positive indicators            |
| Error         | `#ef4444`                 | Error states                   |

### Typography

**Dual-font system:**

* **Geometric sans** (Geist Sans via `next/font`) — UI elements, body text, navigation, labels

* **Serif** (Playfair Display via `next/font`) — display headings, blog titles, case study headers

The serif signals "thinker and writer" on top of the engineer identity. Used sparingly at large display sizes only. Playfair's high-contrast strokes pair well with the warm amber accent — both signal sophistication and depth.

**Monospace** (Geist Mono via `next/font`) — code blocks, terminal references, tech stack labels.

**Scale:** Dense. Tight line-heights. Information-rich, not editorial-spacious.

### Layout

* **Single continuous scroll** with sophisticated scroll effects (parallax, sticky headers, scroll-triggered reveals)

* **Dense / data-rich** — dashboard-like sections. Information density signals competence.

* **Section anchors** in nav for jumping to content areas

* **Dedicated routes** only for blog posts and case study pages (content that needs its own URL for SEO)

### Design Effects

* Scroll-triggered animations (Framer Motion `useScroll`, `useTransform`)

* Subtle parallax on hero section

* Sticky section headers as you scroll through content areas

* Amber glow on hover states and focus rings

* No heavy glassmorphism — flat surfaces with subtle borders

* Code blocks and terminal references feel native, not decorative

***

## Security Tone

**Proof over claims.** Never say "I'm a security expert." Instead:

* Show architecture decisions in case studies

* Display threat models alongside project descriptions

* Let GitHub repos, commit history, and technical depth speak

* If security is mentioned, it's in the context of a specific decision: "chose mTLS over API keys because..."

***

## Content Strategy

Two content engines:

### 1. Blog (long-form, `/blog/{slug}`)

* Security deep dives (1500-3000 words)

* Architecture breakdowns

* DevSecOps walkthroughs

* MDX-powered with code blocks, diagrams

* Publish cadence: 2-4x per month target

### 2. Case Studies (per-project, `/projects/{slug}`)

* "Here's what I built and why" (500-1000 words)

* Architecture diagrams

* Key technical decisions with rationale

* GitHub links, live demos where available

* Stack breakdown with role-per-technology

***

## Anti-Patterns (What This Site Is NOT)

* NOT a generic "developer portfolio" with card grids and gradient text

* NOT flashy — no bouncing animations, no neon colors, no particle backgrounds

* NOT sparse — every section earns its space with real content

* NOT self-aggrandizing — the work speaks, not the claims

* NOT a template — distinctive enough that it couldn't be anyone else's site

* NOT light mode — dark only for v1.0 (revisit in v2.0)

***

## Inspiration References

* Linear.app marketing site (density, dark, clean)

* Vercel.com (engineering polish, restrained design)

* Leerob.io (Lee Robinson's personal site — engineer who writes)

* Rauno.me (Rauno Freiberg — craft-focused, scroll interactions)

* Stripe documentation (information-rich, readable, structured)

***

## Open Decisions

* [x] Serif typeface — **Playfair Display** (chosen via side-by-side preview, 2026-03-28)
* [ ] Scroll library — Framer Motion `useScroll` vs Lenis for smooth scrolling
* [ ] MDX setup — next-mdx-remote vs contentlayer vs velite
* [ ] OG image generation — static vs dynamic (next/og)
