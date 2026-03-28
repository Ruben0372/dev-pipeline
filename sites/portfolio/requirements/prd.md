# Portfolio — Product Requirements

## Goal

Launch a personal portfolio site that positions Ruben as a **security-focused full stack developer** for freelance platforms (Upwork, Fiverr) and professional networks (LinkedIn, GitHub).

## Target Audience

* Hiring managers and CTOs on freelance platforms

* Startups needing DevSecOps + full-stack work

* Recruiters scanning LinkedIn profiles

## Core Requirements

### v1.0 (Current)

| #  | Requirement                                                       | Priority | Status            |
| -- | ----------------------------------------------------------------- | -------- | ----------------- |
| 1  | Home page with hero, services, featured projects, tech stack, CTA | P0       | Done (scaffolded) |
| 2  | Projects page — full gallery of 7 real projects                   | P0       | Done (scaffolded) |
| 3  | About page — bio, values, CTA                                     | P0       | Done (scaffolded) |
| 4  | Contact page — email, GitHub, LinkedIn, Upwork/Fiverr             | P0       | Done (scaffolded) |
| 5  | Dark theme matching security-engineer aesthetic                   | P0       | Done              |
| 6  | Mobile responsive (320px–1440px)                                  | P0       | Not verified      |
| 7  | shadcn/ui + 21st.dev component integration                        | P1       | Not started       |
| 8  | SEO metadata (OG images, favicon, meta tags)                      | P1       | Not started       |
| 9  | Self-hosted fonts (no Google Fonts CDN)                           | P1       | Not started       |
| 10 | Vercel deployment                                                 | P0       | Not started       |
| 11 | GitHub repo creation                                              | P0       | Not started       |

### v1.1 (Future)

* Contact form with Resend/email forwarding

* Blog section (MDX) for security articles

* Google Stitch design polish pass

### v1.2 (Future)

* Case study pages per project

* Testimonials section

## Non-Requirements

* No authentication or user accounts

* No CMS or dynamic backend

* No analytics without explicit approval

* No light mode (dark only for v1.0)

## Success Metrics

* Lighthouse Performance >= 90

* Lighthouse Accessibility >= 95

* Lighthouse SEO >= 95

* Zero console errors / hydration mismatches

* All pages render at 320px, 768px, 1024px, 1440px
