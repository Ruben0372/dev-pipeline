# Portfolio — Product Requirements

**Revised:** 2026-03-28 (post brand discovery)

## Goal

Build a personal brand platform that positions Ruben as a **security engineer who builds things that matter**. Thought leadership through technical writing and project case studies. Conversion path for freelance work is secondary to credibility and depth.

## Target Audience

1. **Technical leaders** evaluating Ruben's depth (CTOs, eng managers, senior engineers)
2. **Content consumers** finding posts via search/social (security-curious developers)
3. **Freelance clients** looking for DevSecOps + full-stack capability (Upwork, Fiverr, LinkedIn)

## Brand Pillars

- **Craft** — every detail is intentional
- **Proof over claims** — architecture decisions > badges and certifications
- **Depth** — long-form content, case studies, not surface-level
- **Dense** — information-rich, dashboard-like, competence through density

## Core Requirements

### v1.0 — Brand Platform Launch

| # | Requirement | Priority | Notes |
|---|-------------|----------|-------|
| 1 | Single continuous scroll home page with section anchors | P0 | Hero → About → Projects → Tech → Blog Preview → Contact |
| 2 | Sophisticated scroll interactions (parallax, sticky, reveals) | P0 | Framer Motion or Lenis — defines the site's feel |
| 3 | Dark theme with warm amber accent | P0 | See brand-identity.md for full palette |
| 4 | Dual-font system (geometric sans + serif display headings) | P0 | Serif TBD — needs preview |
| 5 | Dense, data-rich layout | P0 | Dashboard-like sections, tight spacing |
| 6 | Project case study pages (`/projects/{slug}`, MDX) | P0 | 500-1000 words per project, architecture focus |
| 7 | Blog section (`/blog/{slug}`, MDX) | P0 | Long-form security deep dives, MDX with code blocks |
| 8 | shadcn/ui component integration | P1 | Buttons, cards, badges, tooltips as base primitives |
| 9 | Self-hosted fonts (woff2, no CDN) | P1 | Inter/Geist + Serif + JetBrains Mono |
| 10 | SEO metadata (OG images, favicon, meta tags) | P1 | Per-page and per-post OG images |
| 11 | Mobile responsive (320px–1440px) | P0 | Dense on desktop, stacked on mobile |
| 12 | WCAG AA accessibility | P0 | Contrast, keyboard nav, aria labels |
| 13 | GitHub repo + Vercel deploy | P0 | Live URL with preview deploys |

### v1.1 (Future)

- Contact form with Resend
- RSS feed for blog
- Dynamic OG images (next/og)
- Reading time estimates
- Blog post tags/categories with filtering
- Search across blog + case studies

### v2.0 (Future)

- Light mode toggle
- Notion as CMS for blog (via API)
- Newsletter signup (Buttondown or Resend)
- Analytics (privacy-respecting, self-hosted — Plausible or Umami)

## Non-Requirements

- No authentication or user accounts
- No comments on blog posts (v1.0)
- No analytics without explicit approval
- No CMS — content is git-tracked MDX
- No multi-language support

## Success Metrics

| Metric | v1.0 Target |
|--------|-------------|
| Lighthouse Performance | >= 90 |
| Lighthouse Accessibility | >= 95 |
| Lighthouse SEO | >= 95 |
| Console errors | 0 |
| Hydration mismatches | 0 |
| Mobile responsive | Pass at 320px, 768px, 1024px, 1440px |
| Blog posts at launch | >= 1 |
| Case studies at launch | >= 3 (Atlax, Secure Remote Access, Security Scripts) |
| Scroll interactions | Smooth, no jank at 60fps |
