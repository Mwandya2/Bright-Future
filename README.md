# Bright Future Digital Hub

A complete digital-empowerment platform — ICT training, computer-lab bookings,
digital printing, freelance services, and business support — with a full
administrator dashboard.

Built with **Next.js 16 (App Router) · TypeScript · Tailwind v4 · Supabase · Resend**.
UI follows an editorial, ElevenLabs-inspired design system (see `DESIGN.md`).

## Features

**Public app**
- Editorial landing page showcasing all 9 ecosystem modules
- Email/password auth (Supabase) with branded confirmation emails (Resend)
- ICT course catalogue
- Member dashboard: courses, lab bookings, print orders

**Admin dashboard** (`/admin`, admin role only)
- Platform stats & revenue overview
- Create / publish / delete courses
- Manage lab bookings & print orders (status workflow)
- Manage users & roles

## Getting started

```bash
npm install
cp .env.example .env.local   # fill in your keys
npm run dev
```

### 1. Database
Open **Supabase → SQL Editor** and run [`supabase/schema.sql`](supabase/schema.sql).
It creates all tables, RLS policies, the new-user trigger, and seeds a starter
course catalogue.

### 2. Auth redirect URLs
In **Supabase → Authentication → URL Configuration** add:
- Site URL: `https://brightfuture.best`
- Redirect URLs: `https://brightfuture.best/auth/callback`, `http://localhost:3000/auth/callback`

### 3. Become an admin
Sign up in the app, then in the SQL editor:
```sql
update public.profiles set role = 'admin' where email = 'you@example.com';
```
Now `/admin` is unlocked.

## Environment variables
See [`.env.example`](.env.example). The `SUPABASE_SERVICE_ROLE_KEY`,
`SUPABASE_SECRET_KEY`, and `RESEND_API_KEY` are **server-only** — never exposed
to the browser.

## Deploy
Deployed on Vercel. Add all environment variables in the Vercel project
settings, then point the `brightfuture.best` domain at the deployment.
