# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

API de Assinaturas ("Diário Premium") — an Express + TypeScript REST API backed by MariaDB/MySQL, simulating a subscription platform: users sign up, choose plans, pay via card/Pix/boleto, and get access to content while their subscription is active. Supports upgrades, cancellations, refunds, coupons, and billing history.

The entire API lives in a single file: `main.ts`. There is no `src/` directory — routes, Swagger docs, and the DB pool are all defined there. Swagger/OpenAPI docs are generated from JSDoc `@swagger` comment blocks directly above each route handler in `main.ts` (see `swaggerOptions.apis: ["./main.ts"]`), so when adding or changing a route, update its JSDoc block in place rather than writing separate documentation.

## Commands

- `npm run dev` — run the API with hot reload (`ts-node-dev`), on port 3000.
- `npm run start` — run via `ts-node` (no reload).
- `npm run build` — type-check and compile with `tsc`.
- `docker compose up` — start both the app and a MariaDB container (`compose.yml`); the DB is seeded from `bkp.sql` on first init.

There is no test suite and no linter configured in this repo.

Swagger UI is served at `/api-docs` once the app is running.

## Configuration

Environment variables (see `.env.example`, loaded via `dotenv/config`): `PORT`, `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `NODE_ENV`. When running outside Docker, copy `.env.example` to `.env` and point `DB_HOST` at your local DB.

Note: `compose.yml` sets `DB_HOST: localhost` for the `app` service even though the DB runs in a separate `banco` container — the `mysql2` pool is also configured with `connectionLimit: 1`. Be aware of both when debugging connection issues.

## Database schema

Full schema narrative is in `DATABASE_EXPLANATION.md`; raw seed/dump is in `bkp.sql`. Four functional table groups:

- **Identidade** — `users`, `user_addresses`, `user_sessions`. Users have a unique CPF, a `status` (active/inactive/blocked), and email verification.
- **Catálogo** — `plans`, `features`, `plan_features` (N:N join, with a `value` column for limits like "5 downloads/month"), `coupons`. Plans have separate monthly/annual prices and a configurable `trial_days`.
- **Assinatura** — `subscriptions`, `subscription_history`. Subscriptions store `price_at_signup` to preserve historical pricing even if the plan's price later changes. `subscription_history` is an audit log of subscription events (creation, activation, upgrade, cancellation).
- **Financeiro** — `invoices`, `payments`, `payment_methods`, `refunds`. An invoice can have multiple payment attempts; a payment references `payment_method_id`; refunds are separate records with a typed reason.

Flow: a `user` picks a `plan` → creates a `subscription` → which generates periodic `invoices` → each `invoice` gets a `payment` → which may have a `refund`.

## Code conventions in main.ts

- Routes use raw parameterized `mysql2/promise` queries (`pool.query(sql, params)`) — no ORM/query builder. Keep using parameterized placeholders (`?`) for any user-supplied values to avoid SQL injection; never string-interpolate request data into SQL.
- User-facing error messages and Swagger summaries/descriptions are written in Portuguese (pt-BR); match this convention for consistency.
- Each route is preceded by a JSDoc `@swagger` block describing its path, params, request body, and responses — update this alongside any route signature change.
