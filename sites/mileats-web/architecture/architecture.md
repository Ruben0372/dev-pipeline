# mileats-web Architecture

## Overview

Single Next.js 15 application using the App Router. Renders 4 marketing pages, exposes 2 API routes, deploys as a standalone Docker container to AWS ECS Fargate behind CloudFront.

## Component layers

```
┌─────────────────────────────────────────────────────────┐
│  CloudFront (CDN, WAF, edge cache)                      │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│  ALB → ECS Fargate → mileats-web container (port 3000)  │
└────────────────────┬────────────────────────────────────┘
                     │
        ┌────────────┼─────────────┐
        ▼            ▼             ▼
┌──────────────┐ ┌─────────┐ ┌─────────────┐
│  Loops API   │ │ Resend  │ │ next/font   │
│ (waitlist)   │ │(contact)│ │ Google CDN  │
└──────────────┘ └─────────┘ └─────────────┘
```

## Routes

| Route | Type | Notes |
|---|---|---|
| `/` | RSC page | Customer landing — Hero + HowItWorks + BuiltForCommunity + ClosingCta |
| `/drive` | RSC page | Rider landing — Hero + WhyDrive + WhoDrives + ClosingCta |
| `/about` | RSC page | Mission + vision + 5 values |
| `/contact` | RSC page | ContactForm |
| `/api/waitlist` | POST | Zod validation → Loops API |
| `/api/contact` | POST | Zod validation → Resend API |

## Token system

Brand tokens are owned by `mileats-brand/` (sibling folder). Token sync flow:

```
mileats-brand/tokens/tokens.css
        │
        │ scripts/sync-tokens.mjs runs on predev/prebuild
        ▼
mileats-web/src/brand/tokens.css  (gitignored)
        │
        │ imported by src/app/globals.css
        ▼
Tailwind v4 @theme → utility classes (text-brand-ember, bg-neutral-50, etc.)
```

**Critical rule:** never edit `src/brand/tokens.css` directly — it's regenerated on every dev/build. Edit `mileats-brand/tokens/`.

## Persistent launch countdown

- Single source of truth: `src/lib/launch-date.ts` (reads `NEXT_PUBLIC_LAUNCH_DATE` env var, defaults to `2026-06-15T00:00:00-04:00`)
- Component: `src/components/layout/LaunchCountdown.tsx` (server-renders deterministically, upgrades to live on mount)
- Used in: `Header` (compact), `ClosingCta` (full), per-page heroes
- Respects `prefers-reduced-motion`

## Form architecture

Both `WaitlistForm` and `ContactForm` are client components with the same shape:

```
[user fills form] → fetch POST /api/{waitlist|contact}
                          ↓
                  Zod schema validation
                          ↓
              {Loops|Resend} API call
                          ↓
                  JSON response → UI state
```

Error states show user-friendly recovery copy. Success states show on-tone confirmations from `mileats-brand/voice/microcopy-library.md`.

## Deployment pipeline

```
git push to main
  ↓
GitHub Actions (TBD at Setup stage):
  1. npm ci
  2. npm run typecheck
  3. npm run lint
  4. docker build (with mileats-brand mounted as build context)
  5. docker push to AWS ECR
  6. ECS service update with new task definition
  7. CloudFront invalidation
```

## Why these choices

| Decision | Why |
|---|---|
| Next.js 15 App Router | RSC for SEO, static-first rendering, edge-friendly, matches existing skill set |
| Standalone output | Smallest possible Docker image, runs on any container runtime |
| AWS ECS Fargate | Same infra family as MilEats backend BFFs (operational consistency) |
| CloudFront | Edge caching for marketing pages, free TLS, WAF |
| Loops over Postgres for v1 waitlist | No DB to provision, pre-built marketing automation, dual-write deferred to v1.1 |
| Resend for contact | Already in MilEats backend env, single email destination |
| Phosphor Icons over Lucide | Multiple weights enable brand-disciplined icon hierarchy |
| Tailwind v4 over v3 | CSS-first config, native @theme, smaller runtime |
