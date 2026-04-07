# mileats-web

User-facing brand, traction, and high-conversion website for MilEats. Veteran-founded on-base food delivery.

**Stage:** Build (exited Setup 2026-04-06)
**Launch:** June 15, 2026 — 00:00 ET
**Repo:** `~/projects/mileats-codebase/mileats-web/`
**Brand source:** `~/projects/mileats-codebase/mileats-brand/` (v0.1.0)
**Domain:** mileatsdelivery.com

## Purpose

Two distinct landing pages — one for customers, one for drivers — with persistent launch countdown across all pages. Conversion goal: waitlist signups, segmented by audience.

## Pages (4)

| Route      | Purpose                                                                    | Form                                              |
| ---------- | -------------------------------------------------------------------------- | ------------------------------------------------- |
| `/`        | Customer landing                                                           | Email + Base → Loops                              |
| `/drive`   | Rider landing                                                              | Email + Base + Vet/Spouse/Active/Civilian → Loops |
| `/about`   | Mission + vision + 5 values (no founder photo in v1)                       | —                                                 |
| `/contact` | Single form, category dropdown (Press / Restaurant / Base Admin / General) | → Resend                                          |

## Stack

Next.js 15 App Router · TypeScript · Tailwind v4 · shadcn/ui · Framer Motion · Phosphor Icons · MDX
General Sans (display, Fontshare Free License, self-hosted variable) + Inter + Fraunces + JetBrains Mono
  ↳ PP Neue Montreal upgrade deferred — single-line swap when budget allows
Loops (waitlist) + Resend (contact email) + Zoho Mail (receiving `hello@`)
Docker → AWS ECS Fargate + CloudFront

## Positioning lane

**Institutional Trust, modernized.** USAA-grade dignity meets Sweetgreen-grade hospitality. Explicitly NOT the Black Rifle Coffee tactical-lifestyle lane.

## Audience priority

1. Service members on base + military spouses/families (customer landing)
2. Veterans + spouses looking for income (rider landing)
3. Brand credibility for press, base admin, investors (about + contact)

## What's intentionally deferred to v1.1

- Postgres analytics mirror for signups (Loops dashboards only in v1)
- Real on-base photography (placeholders tagged for replacement)
- Base list dropdown (free-text input until launch base list confirmed)
- PP Neue Montreal woff2 (General Sans stand-in in v1; upgrade later)
- Founder photo on /about

## Pipeline next moves

1. **Build stage now:** replace placeholders, refine copy, animations, a11y + perf passes
2. **Build → Test:** Lighthouse audit, cross-browser QA, frontend-audit skill run
3. **Test → Review:** content + brand consistency review, veteran readthroughs
4. **Review → Ship:** AWS infra, GitHub Actions deploy, staging smoke, DNS cut
5. **Ship target:** June 1, 2026 (soft launch, 14-day buffer before hard launch)
6. **Hard launch:** June 15, 2026 — countdown hits zero
