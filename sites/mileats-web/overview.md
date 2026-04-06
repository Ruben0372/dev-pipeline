# mileats-web

User-facing brand, traction, and high-conversion website for MilEats. Veteran-founded on-base food delivery.

**Stage:** Setup (just exited Ideate, 2026-04-06) **Launch:** June 15, 2026 — 00:00 ET **Repo:** `~/projects/mileats-codebase/mileats-web/` **Brand source:** `~/projects/mileats-codebase/mileats-brand/` (v0.1.0) **Domain:** mileatsdelivery.com

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

Next.js 15 App Router · TypeScript · Tailwind v4 · shadcn/ui · Framer Motion · Phosphor Icons · MDX PP Neue Montreal (display, $40 license pending) + Inter + Fraunces + JetBrains Mono Loops (waitlist) + Resend (contact email) Docker → AWS ECS Fargate + CloudFront

## Positioning lane

**Institutional Trust, modernized.** USAA-grade dignity meets Sweetgreen-grade hospitality. Explicitly NOT the Black Rifle Coffee tactical-lifestyle lane.

## Audience priority

1. Service members on base + military spouses/families (customer landing)

2. Veterans + spouses looking for income (rider landing)

3. Brand credibility for press, base admin, investors (about + contact)

## What's intentionally deferred to v1.1

* Postgres analytics mirror for signups (Loops dashboards only in v1)

* Real on-base photography (placeholders tagged for replacement)

* Base list dropdown (free-text input until launch base list confirmed)

* PP Neue Montreal woff2 (system Helvetica Neue fallback until license purchased)

* Founder photo on /about

## Pipeline next moves

1. **Setup stage now:** install dependencies, run dev server, verify scaffold renders

2. **Setup → Build:** wire real Loops + Resend API keys, replace placeholder hero images, refine copy

3. **Build → Test:** Lighthouse audit, a11y review, frontend-audit skill run

4. **Test → Review:** content review pass, brand consistency check via design-system-reviewer agent

5. **Review → Ship:** purchase PP Neue Montreal license, drop woff2 files, deploy to AWS ECS, point Route 53

6. **Ship target:** June 1, 2026 (2 weeks before launch for soft launch + iteration)
