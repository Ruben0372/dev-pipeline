# mileats-web — API Endpoints

Marketing site with two internal Next.js route handlers. No public API.

Base URL (prod): `https://mileatsdelivery.com`

All endpoints return `application/json`. Errors use a consistent envelope:

```json
{ "error": "description of the problem" }
```

---

## POST /api/waitlist

Submit email to Loops waitlist (customer or rider audience).

**Body:**
```json
{
  "audience": "customer" | "rider",
  "email": "string",
  "base": "string (optional)",
  "status": "string (rider only, optional)"
}
```

**Validation:** Zod schema in `src/app/api/waitlist/route.ts`.

**Backing service:** Loops API (`LOOPS_API_KEY`, audience IDs in env).

**Responses:**
- `200` — `{ ok: true }`
- `400` — validation error
- `502` — Loops upstream failure

---

## POST /api/contact

Submit contact form. Routes email via Resend based on category.

**Body:**
```json
{
  "name": "string",
  "email": "string",
  "category": "partner" | "press" | "support" | "other",
  "message": "string"
}
```

**Backing service:** Resend API (`RESEND_API_KEY`, `CONTACT_TO_EMAIL`).

**Responses:**
- `200` — `{ ok: true }`
- `400` — validation error
- `502` — Resend upstream failure

---

## Notes

- No auth — public forms, rate-limited at CloudFront/WAF layer.
- No database in v1. Postgres mirror deferred to v1.1.
- Both routes run in the Node runtime (not Edge) because the Resend SDK needs it.
