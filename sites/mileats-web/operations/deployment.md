# mileats-web — Deployment Runbook

Target launch: **2026-06-15 00:00 ET**

---

## Stack

| Layer | Tech |
|-------|------|
| Framework | Next.js 15 App Router (standalone output) |
| Runtime | Node 20-alpine |
| Container | Multi-stage Dockerfile, non-root `nextjs` user |
| Hosting | AWS ECS Fargate behind CloudFront |
| DNS | `mileatsdelivery.com` (prod), `staging.mileatsdelivery.com` |
| Secrets | AWS SSM Parameter Store |

---

## Environment Variables

| Key | Purpose |
|-----|---------|
| `NEXT_PUBLIC_LAUNCH_DATE` | `2026-06-15T00:00:00-04:00` — countdown target |
| `LOOPS_API_KEY` | Loops waitlist submission |
| `LOOPS_CUSTOMER_AUDIENCE_ID` | Customer waitlist audience |
| `LOOPS_RIDER_AUDIENCE_ID` | Rider waitlist audience |
| `RESEND_API_KEY` | Contact form email |
| `CONTACT_TO_EMAIL` | Contact form recipient |

---

## Local Dev

```bash
cd ~/projects/mileats-codebase/mileats-web
cp .env.example .env.local  # fill in keys
npm install
npm run dev                 # predev runs sync-tokens.mjs
```

Brand tokens are synced from `../mileats-brand/tokens/tokens.css` into `src/brand/tokens.css` (gitignored) via `scripts/sync-tokens.mjs` on `predev`/`prebuild`.

---

## Build & Ship

```bash
npm run build                           # prebuild syncs tokens
docker build -t mileats-web:latest .
```

CI/CD pipeline TBD — align with existing MilEats BFF GitHub Actions → ECR → ECS pattern.

---

## Pre-Launch Checklist

- [ ] PP Neue Montreal license purchased ($40) and woff2 dropped in `src/app/fonts/`
- [ ] Loops audiences created, IDs in SSM
- [ ] Resend domain verified
- [ ] CloudFront + ACM cert for `mileatsdelivery.com`
- [ ] ECS service + task definition
- [ ] GitHub Actions deploy workflow
- [ ] Staging smoke test (waitlist + contact end-to-end)
- [ ] Lighthouse ≥95 on all 4 pages
- [ ] `prefers-reduced-motion` verified

---

## Rollback

Standard ECS: revert to previous task definition revision.
