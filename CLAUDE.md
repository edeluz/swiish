# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Development (builds frontend + watches backend with nodemon)
npm run dev

# Frontend only
npm start           # React dev server on port 3000
npm run build       # Production React build

# Backend only
npm run serve       # Express server on configured PORT

# Database
npm run migrate     # Run pending db-migrate SQL migrations
```

No test or lint commands exist yet (planned future work per CONTRIBUTING.md).

## Architecture

Swiish is a **self-hosted digital business card platform** (Node/Express + React, SQLite, PWA).

### Structure

The codebase is intentionally monolithic for now (acknowledged technical debt, refactoring planned):

- **[server.js](server.js)** (~4,500 lines) — single Express backend with all routes, middleware, and business logic
- **[src/App.js](src/App.js)** (~14,000 lines) — single React component with all frontend views and state

### Backend ([server.js](server.js))

Express 4 with:
- **Auth**: JWT via `httpOnly` cookies, bcrypt passwords, CSRF protection (`csurf`), rate limiting per route tier
- **Security layers**: Helmet, CORS with origin validation, express-validator on all inputs, DOMPurify-equivalent escaping on output
- **Database**: SQLite3 via `db-migrate`; schema in [migrations/sqls/](migrations/sqls/)
- **File handling**: Multer for uploads (avatars/banners) → Sharp for image processing and preview PNG generation

**API surface:**
- `/api/setup/*` — first-run wizard
- `/api/login`, `/api/logout`, `/api/auth/*` — authentication
- `/api/cards/:slug` — public card read; `/api/cards/*` (authenticated) — card CRUD
- `/api/admin/*` — admin-only: users, cards, invitations, logs, settings
- `/api/qr/:identifier` — QR code generation
- `/manifest/:slug.json` — dynamic PWA manifest per card
- `/api/demo/*` — demo mode (hourly data reset)

**Rate limiting tiers**: `apiLimiter`, `cardReadLimiter`, `loginLimiter`, `uploadLimiter`, `publicReadLimiter` — each applied to the appropriate route groups.

### Frontend ([src/App.js](src/App.js))

React 18 + React Router 6 + TailwindCSS with:
- **Design tokens**: Semantic color/spacing tokens defined in [src/theme/swiish.js](src/theme/swiish.js) and [src/theme/minimal.js](src/theme/minimal.js); injected as CSS variables at runtime so light/dark and theme switching work without class-name changes
- **Key dependencies**: dnd-kit (drag-and-drop field ordering), DOMPurify (XSS prevention on card content), lucide-react (icons), qrcode

### Database Schema

Core tables: `organisations`, `users`, `organisation_settings`, `user_settings`, `cards` (keyed on `user_id + slug`, with unique `short_code`), `invitations`, `password_reset_tokens`, `email_verification_tokens`, `audit_log`.

Multi-tenancy: every resource belongs to an organisation; users have an `owner` or `member` role.

### Data directories (gitignored, created at runtime)

- `/data` — SQLite database files
- `/uploads` — user avatar and banner images
- `/cache` — build artifacts

## Configuration

Copy `.env.example` → `.env`. Required variables: `JWT_SECRET`, `APP_URL`. Optional: SMTP settings (falls back to console logging in dev), `DEMO_MODE=true`.

`database.json` controls the db-migrate connection (points to `/data/swiish.db` by default).

## Docker

```bash
docker compose up -d   # Runs on host port 8095
```

Multi-stage Dockerfile (Node 22 Alpine); includes FontConfig setup for Sharp/SVG text rendering with Atkinson Hyperlegible font.

## Conventions

- **Commits**: Conventional Commits (`feat:`, `fix:`, `chore:`, etc.)
- **Branching**: `master` (stable) ← `develop` ← feature branches
- **PR target**: `develop`, not `master`
- **License**: AGPL-3.0 — all contributions must be compatible
