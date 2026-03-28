# Portfolio — Deployment

## Target

Vercel (static hosting, edge CDN, automatic SSL).

## Deploy Commands

```bash
cd ~/projects/portfolio

# Build
npm run build

# Deploy (first time — links to Vercel project)
npx vercel --prod

# Subsequent deploys
npx vercel --prod
```

## Pre-Deploy Checklist

- [ ] `npm run build` succeeds with zero errors
- [ ] `npm run lint` passes
- [ ] All pages render at 320px, 768px, 1024px, 1440px
- [ ] No console errors or hydration mismatches
- [ ] Mobile nav opens and closes correctly
- [ ] All GitHub links resolve to real repos
- [ ] Email link (`mailto:ru93ben@gmail.com`) works
- [ ] OG image and favicon are present
- [ ] Fonts load without Google Fonts CDN
- [ ] Lighthouse scores meet targets

## Rollback

```bash
vercel rollback
# OR push a revert commit — Vercel auto-deploys from main
```

## Domain

TBD — configure custom domain in Vercel dashboard after initial deploy.
