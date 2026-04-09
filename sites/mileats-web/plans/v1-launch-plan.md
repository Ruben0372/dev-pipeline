# mileats-web v1 Launch Plan

**Target launch:** June 15, 2026 — 00:00 ET **Soft launch target:** June 1, 2026 (14 days of buffer for iteration) **Scaffold complete:** April 6, 2026 **Setup complete:** April 6, 2026 ✅ **Time to soft launch:** ~8 weeks **Time to hard launch:** ~10 weeks

## Phase Setup ✅ COMPLETE (2026-04-06)

* [x] `npm install` (run from `~/projects/mileats-codebase/mileats-web/`)
* [x] Verify `npm run dev` boots clean and renders all 4 pages
* [x] Verify TypeScript passes: `npm run typecheck`
* [x] Set up Loops account, create customer + rider audiences, capture audience IDs
* [x] Set up Resend (sending via `noreply@mileatsdelivery.com`)
* [x] Set up Zoho Mail receiving on `hello@mileatsdelivery.com` (MX fixed — stray hostedemail record removed, Zoho MX 10/20/50)
* [x] Populate `.env.local` with real API keys
* [x] Test waitlist submission end-to-end (customer + rider via real browser UI → Loops audiences)
* [x] Test contact form end-to-end (Resend → Zoho inbox; cleared stale suppression entry)
* [x] Install display font — **went with General Sans (Fontshare Free License)** instead of PP Neue Montreal due to budget; variable woff2 self-hosted at `src/app/fonts/`
* [x] Wire `next/font/local` declaration in `src/app/layout.tsx`, update `--mileats-font-display` token

### Setup deltas from original plan

* Display font: **General Sans** (free, Fontshare) — PP Neue Montreal deferred, swap is one-line change

* Resend: hard-bounce suppression gotcha documented (clear list after DNS fixes)

* Zoho MX required cleanup of stale `cust.hostedemail.com` record and correct priorities (10/20/50)

## Phase Build (~April 7 → ~May 4)

* [x] Replace placeholder hero images with real photography (or art-directed Unsplash+ stopgaps tagged `placeholder-`)
* [x] Refine copy on all sections — pull from `mileats-brand/voice/`
* [x] Add Framer Motion scroll reveals to section headlines (use `animation-patterns` skill, `variants` on parent only)
* [x] Add subtle hero animation (consider: typography reveal, fork-in-M draw-in, or static for v1)
* [x] Add favicon + OpenGraph image (export from logo source after the renaming task)
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
* [ ] Merge SPF to include both senders: `v=spf1 include:zohomail.com include:amazonses.com ~all`
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
* [ ] Capture v1.1 backlog (Postgres mirror, blog, base dropdown, dark mode, founder profile, PP Neue Montreal upgrade)
* [ ] Schedule v1.1 work
