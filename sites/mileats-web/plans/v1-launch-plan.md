# mileats-web v1 Launch Plan

**Target launch:** June 15, 2026 — 00:00 ET **Soft launch target:** June 1, 2026 (14 days of buffer for iteration) **Scaffold complete:** April 6, 2026 (today) **Time to soft launch:** ~8 weeks **Time to hard launch:** ~10 weeks

## Phase Setup (now → ~April 13)

* [x] `npm install` (run from `~/projects/mileats-codebase/mileats-web/`)
* [x] Verify `npm run dev` boots clean and renders all 4 pages
* [ ] Verify TypeScript passes: `npm run typecheck`
* [ ] Set up Loops account, create customer + rider audiences, capture audience IDs
* [ ] Set up Resend (or reuse MilEats backend Resend account), create dedicated `noreply@mileatsdelivery.com` sender
* [ ] Populate `.env.local` with real API keys
* [ ] Test waitlist submission end-to-end (both customer and rider variants)
* [ ] Test contact form end-to-end (all 4 categories)
* [ ] Buy PP Neue Montreal license ($40) and drop woff2 into `mileats-brand/typography/web/`
* [ ] Wire `next/font/local` declaration in `src/app/layout.tsx`

## Phase Build (~April 13 → ~May 4)

* [ ] Replace placeholder hero images with real photography (or art-directed Unsplash+ stopgaps tagged `placeholder-`)
* [ ] Refine copy on all sections — pull from `mileats-brand/voice/`
* [ ] Add Framer Motion scroll reveals to section headlines (use `animation-patterns` skill, `variants` on parent only)
* [ ] Add subtle hero animation (consider: typography reveal, fork-in-M draw-in, or static for v1)
* [ ] Add favicon + OpenGraph image (export from logo source after the renaming task)
* [ ] Add JSON-LD structured data for organization + website
* [ ] Run `frontend-a11y` agent — fix all CRITICAL/HIGH
* [ ] Run `frontend-perf` agent — ensure LCP < 2.5s, CLS < 0.1, INP < 200ms
* [ ] Run `design-system-reviewer` agent — verify zero hardcoded values

## Phase Test (~May 4 → ~May 18)

* [ ] Cross-browser test: Chrome, Safari, Firefox, mobile Safari, mobile Chrome
* [ ] Lighthouse: aim for 95+ Performance, 100 Accessibility, 100 Best Practices, 100 SEO
* [ ] Manual QA on all forms in all browsers
* [ ] Verify countdown displays correctly across timezones
* [ ] Verify deep links (`/drive`, `/about`, `/contact`) all work standalone
* [ ] Test 404 page rendering
* [ ] Pen-test the API routes (rate limiting, input validation)

## Phase Review (~May 18 → ~May 25)

* [ ] Brand consistency review against `mileats-brand/`
* [ ] Voice review against `mileats-brand/voice/tone-of-voice.md`
* [ ] Get 3 veterans / military spouses to read the site cold and react
* [ ] Get 1 marketing professional to react to the conversion path
* [ ] Fix all feedback flagged HIGH or above

## Phase Ship (~May 25 → June 1)

* [ ] Provision AWS resources via CloudFormation (`infra/cloudformation/`)
* [ ] Set up GitHub Actions deploy workflow (`.github/workflows/deploy.yml`)
* [ ] Push secrets to AWS Secrets Manager
* [ ] Deploy to staging URL first (`staging.mileatsdelivery.com`)
* [ ] Smoke test staging
* [ ] Cut DNS to production
* [ ] **Soft launch June 1**

## Phase Iterate (June 1 → June 15)

* [ ] Watch Loops signup volume daily
* [ ] Iterate copy based on conversion data
* [ ] Replace remaining placeholder photography
* [ ] Prepare June 15 launch broadcast email via Loops
* [ ] **Hard launch June 15 — countdown hits zero**

## Phase Retro (June 16+)

* [ ] Document what worked
* [ ] Capture v1.1 backlog (Postgres mirror, blog, base dropdown, dark mode, founder profile)
* [ ] Schedule v1.1 work
