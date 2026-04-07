# Handoff: Setup → Build

**Date:** 2026-04-06
**From stage:** Setup
**To stage:** Build
**Duration in Setup:** ~1 day (same-day scaffold + wiring)

## What was done

### Dependencies + dev loop
- `npm install` clean (upgraded Next from 15.1.0 → 15.x latest to patch CVE-2025-29927)
- `npm run dev` boots, all 4 routes render: `/`, `/drive`, `/about`, `/contact`
- `npm run typecheck` green
- `predev` hook successfully syncs tokens from `mileats-brand/tokens/tokens.css`

### Integrations
- **Loops** (waitlist):
  - Account active, domain `hey.mileatsdelivery.com` verified for sending
  - Two mailing lists created: Customer Waitlist + Rider Waitlist (IDs in `.env.local`)
  - API key scoped for contact creation
  - Tested via curl → both audiences received contacts
  - Tested via real browser UI → confirmed end-to-end with custom properties (`base`, `status`)
- **Resend** (contact form):
  - Account active, sends from `noreply@mileatsdelivery.com` (same root domain as Loops, verified)
  - API key in `.env.local`
  - Tested via curl → 200 OK, delivered
  - Gotcha encountered + resolved: broken MX records caused earlier hard bounces, which Resend auto-suppressed. Cleared suppression list after fixing DNS.
- **Zoho Mail** (receiving `hello@mileatsdelivery.com`):
  - Domain verified, alias `hello@` active
  - MX cleanup: removed stray `cust.hostedemail.com` record, set Zoho priorities correctly (10/20/50)
  - End-to-end verified: Resend → `hello@mileatsdelivery.com` lands in Zoho inbox

### Typography
- **Decision change:** swapped PP Neue Montreal ($40) → **General Sans** (Fontshare Free License) due to budget
- Variable woff2 (normal + italic) self-hosted at `src/app/fonts/GeneralSans-Variable*.woff2`
- Wired via `next/font/local` in `src/app/layout.tsx`, exposes `--font-general-sans` CSS var
- `--mileats-font-display` token updated in both brand source and synced copy to point at General Sans first
- Upgrade path to PP Neue Montreal is a single-file swap; no architectural lock-in

### Tower / infra
- `sites/mileats-web/` committed to dev-pipeline repo with 6 record folders (overview, architecture, plans, handoffs, api, operations)
- Notion project created: `33aacd44-b460-8179-98a2-cf1562542a0f`
- Pipeline onboarded via Tower API → site visible in sidebar at Setup stage

## Open items moving to Build

1. Display font is General Sans — looks close to PP Neue Montreal direction but not identical; validate with eye test during Build stage
2. SPF will need merging to include Amazon SES (Resend) once SSG production sender is finalized: `v=spf1 include:zohomail.com include:amazonses.com ~all`
3. Hero placeholder images still in place — first Build task
4. Logo SVG renaming (the 10-minute visual sort) still outstanding — non-blocking but needed before favicon/OG export

## Known gotchas (so we don't re-learn them)

- **Resend suppression list:** any hard bounce auto-suppresses the recipient. Always clear after DNS fixes.
- **Zoho MX priorities:** must be 10/20/50 (mx/mx2/mx3), not all 10. Wrong priorities = random routing.
- **Gmail → custom domain:** Gmail can silently block outbound to new domains with no diagnostic code. Production path is Resend, not Gmail, so it's irrelevant — but worth noting for debugging.
- **Token sync:** `src/brand/tokens.css` is gitignored and auto-generated from `mileats-brand/tokens/tokens.css` via `scripts/sync-tokens.mjs` on `predev`/`prebuild`. Always edit the source, not the synced copy.

## Ready for Build stage ✅

Site is now functional end-to-end on localhost. All external services wired. Ready to focus on content, animation, visual polish, and accessibility.
