# Handoff — Ideate → Setup

**Date:** 2026-04-06
**Outgoing stage:** Ideate
**Incoming stage:** Setup
**Author:** Claude session w/ Ruben

## What was decided in Ideate

A complete v1 spec was locked through 4 rounds of ideation:

### Pages (4)
1. `/` Customer landing — Hero → How it works → Built for community → Closing CTA
2. `/drive` Rider landing — Hero → Why drive → Who drives → Closing CTA
3. `/about` — Mission + vision + 5 values (no founder photo)
4. `/contact` — Single form with category dropdown

### Forms
- Customer waitlist: Email + Base (free-text) → Loops
- Rider waitlist: Email + Base (free-text) + Vet/Spouse/Active/Civilian → Loops
- Contact: Name + Email + Category + Message → Resend

### Persistent
- Header on every page (logo + nav + compact countdown)
- Live countdown to **2026-06-15T00:00:00-04:00** (midnight ET on June 15, 2026 — EDT)
- Footer on every page

### Stack
- Next.js 15 App Router, TypeScript, Tailwind v4, shadcn/ui, Framer Motion, Phosphor Icons, MDX
- PP Neue Montreal (display, $40 license pending) + Inter + Fraunces + JetBrains Mono
- Loops for waitlist marketing
- Resend for contact email
- Docker → AWS ECS Fargate + CloudFront

### Brand positioning
**Institutional Trust, modernized.** USAA-grade dignity + Sweetgreen-grade hospitality. NOT the BRCC tactical-lifestyle lane. Audience priority: customers > riders > brand credibility.

## What was deferred to v1.1

- Postgres analytics mirror for waitlist signups (Loops only in v1)
- Real on-base photography (placeholders in v1)
- Base list dropdown (free-text input until launch base list confirmed)
- PP Neue Montreal license (system Helvetica Neue fallback until purchased)
- Founder photo on /about

## What's already done (entering Setup)

1. **Brand evolution package** at `~/projects/mileats-codebase/mileats-brand/` v0.1.0:
   - 18 markdown/json/css files written
   - Token system (colors, type, spacing, radius, shadows, motion + tokens.css)
   - Voice docs (tone-of-voice, messaging-pillars, microcopy-library)
   - Imagery direction
   - Logo usage notes + renaming task
   - Original PDFs preserved in guidelines/source/
   - Helvetica family preserved in typography/source-licensed/ (print only)
   - Original zip + raw _unpacked tree in _archive/

2. **mileats-web scaffold** at `~/projects/mileats-codebase/mileats-web/`:
   - 35 files
   - All 4 pages implemented with real (final-quality draft) copy
   - All shared components: Header, Footer, LaunchCountdown
   - All section components: Hero, HowItWorks, BuiltForCommunity, WhyDrive, WhoDrives, ClosingCta
   - WaitlistForm + ContactForm
   - API routes: /api/waitlist + /api/contact
   - Loops + Resend client libs
   - Token sync script (predev/prebuild hook)
   - Dockerfile (multi-stage standalone)
   - .env.example with all required vars
   - README + infra/README placeholder

## What needs to happen in Setup

See `plans/v1-launch-plan.md` Phase Setup section. Top priorities:

1. `npm install` and verify dev server boots
2. Loops account setup + audience IDs
3. Resend setup or reuse
4. Real env vars in `.env.local`
5. End-to-end form submission tests
6. PP Neue Montreal license purchase + woff2 integration

## Open decisions for Setup stage

- [ ] Loops account: new dedicated MilEats account, or use existing?
- [ ] Resend: dedicated mileats-web account, or share with MilEats backend?
- [ ] Logo asset renaming task (the 7 numbered SVGs need to be sorted into `logo/primary/` and `logo/mark/` by purpose — needs visual inspection in a screen-share session)
- [ ] AWS account: same MilEats backend account, or new isolated account for the marketing site?
- [ ] Base list for v1.1 dropdown — when do we have a confirmed launch base list?

## How to resume cold

```bash
cd ~/projects/mileats-codebase/mileats-web
cat README.md            # full project doc
npm install              # install all deps
cp .env.example .env.local
# fill in LOOPS_API_KEY, RESEND_API_KEY at minimum
npm run dev              # → http://localhost:3000
```

Brand source: `~/projects/mileats-codebase/mileats-brand/README.md`
This site's Tower record: `~/projects/dev-pipeline/sites/mileats-web/`
