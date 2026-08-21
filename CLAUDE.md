# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this app is

A LINE LIFF-based digital stamp card app for event visitors ("夕焼けマルシェ", a Maebashi event). Visitors log in via LINE inside the LIFF webview, check in at events (via an NFC tag or QR code that resolves "today's" event), and collect stamps that determine a rank. Staff use an ActiveAdmin backend to manage events, visitors, ranks, and to grant stamps manually (paper-card visitors, or as a fallback when NFC/GPS fails).

## Commands

```bash
bin/setup                 # install deps, prepare DB, start dev server (bin/dev)
bin/setup --reset         # same, but resets the DB first
bin/dev                   # start Rails server + dartsass watch + tailwindcss watch (see Procfile.dev)

bundle exec rspec                          # full test suite
bundle exec rspec spec/requests/liff/checkin_spec.rb   # single file
bundle exec rspec spec/requests/liff/checkin_spec.rb:17 # single example by line

bin/rubocop                # style lint (rubocop-rails-omakase house style)
bin/brakeman                # static security analysis
bin/bundler-audit           # gem vulnerability audit
bin/importmap audit         # JS dependency vulnerability audit
bin/ci                      # runs setup + rubocop + the three audits above (config/ci.rb)

bin/kamal deploy            # deploy via Kamal (config/deploy.yml)
```

Note: GitHub Actions CI (`.github/workflows/ci.yml`) only runs Brakeman, bundler-audit, importmap audit, and RuboCop — it does **not** run `rspec`. Always run the test suite locally before considering work done.

## Architecture

### Two front ends sharing one Rails app

- **`/liff/*`** — visitor-facing pages, LIFF webview only, Tailwind-styled, `layout "liff"`. All controllers inherit from `Liff::BaseController`, which requires a visitor session (`session[:visitor_id]`) and redirects to `liff/entry` otherwise.
- **`/admin/*`** — ActiveAdmin, Devise-authenticated `AdminUser`, Sprockets/Sass-based (kept separate from the Tailwind pipeline used by LIFF pages). Resource configs live in `app/admin/*.rb`.

These two halves have no shared session/auth: visitors are identified by `Visitor` records (LINE-linked or paper-card), admins by `AdminUser` (Devise).

### Visitor identity: two ways in, one record

A `Visitor` either has a `line_user_id` (LINE-linked, created via LIFF login) or a `card_number` (paper card, staff-issued via admin, auto-incremented by `Visitor.next_card_number`). A DB check constraint enforces at least one is present (`visitors_line_user_id_or_card_number_check`). See `app/models/visitor.rb`.

### LIFF login flow

`liff_bootstrap_controller.js` calls `liff.init` → `liff.login()` if needed → `liff.getIDToken()` → POSTs the token to `Liff::SessionsController#create`, which verifies it via `LineIdTokenVerifier` (calls LINE's `/oauth2/v2.1/verify` endpoint) and finds-or-creates the `Visitor`. Post-login redirect target is restricted to `/liff/*` paths only (`Liff::SafeReturnTo` concern) to prevent open redirects — never relax this.

### Check-in flow

1. A physical NFC tag (or QR) points at a single fixed URL: `GET /liff/checkin` (`Liff::CheckinController`). This resolves "today's" published `Event` (`held_on == Date.current`, `status: :published`, most-recently-created wins if several) and redirects into the per-event flow. **This is why the app's timezone matters**: `config.time_zone = "Tokyo"` in `config/application.rb` makes `Date.current` follow JST — the physical tag's URL never needs to change between events, but only if "today" is computed in the venue's local calendar day.
2. `GET /liff/events/:event_id/checkin/new` renders a page that requests browser geolocation (`checkin_controller.js`) and auto-submits it.
3. `POST /liff/events/:event_id/checkin` (`Liff::CheckinsController`) validates the coordinates against `Event#within_venue_radius?` — **fail-open**: if the event has no `venue_lat`/`venue_lng` configured, the location check is skipped entirely. On failure, the visitor is directed back with an in-place retry, with staff manual grant as the documented fallback.

### Stamps

One `Stamp` per `(visitor, event)` pair, enforced by a unique DB index (`index_stamps_on_visitor_id_and_event_id`) in addition to a model validation — duplicate check-ins are handled both at the AR validation layer and by rescuing `ActiveRecord::RecordNotUnique` (race condition between concurrent requests). `Stamp#source` (enum: `line_checkin`, `staff_manual`, `paper_card`) records how the stamp was granted; `granted_by` links to the `AdminUser` for manual grants.

### Ranks

`Rank.for_stamp_count(count)` picks the highest rank whose `min_stamps` is `<= count`, computed on the fly (no rank stored on `Visitor`). `Visitor#rank` and mypage's "next rank" both derive from live stamp counts.

### Distance calculation

`Event#within_venue_radius?` / `#distance_from_venue_meters` implement the haversine formula directly (no external geo gem) — `app/models/event.rb`.

## Conventions worth preserving

- LIFF-side forms are submitted via dynamically-built `<form>` elements + `requestSubmit()` (not `fetch`), so Turbo Drive intercepts them like normal navigation instead of forcing a full reload. See `checkin_controller.js` / `liff_bootstrap_controller.js` for the pattern if adding similar client-driven submissions.
- Flash usage: `flash[:stamp_acquired]` triggers a distinct celebratory toast (`app/views/layouts/liff.html.erb`) instead of a plain `notice`/`alert` banner — reuse this key when adding another "stamp granted" path.
- `ransackable_attributes`/`ransackable_associations` are defined explicitly (allowlist) on every model for ActiveAdmin filtering — extend these rather than opening them up broadly.
