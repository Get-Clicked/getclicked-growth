---
name: brandbook
description: Extract a client's brand (logo, colors, fonts, imagery) from their website, package it as a beautiful hosted brand-guidelines book, derive an agent prompt pack downstream skills consume. Use after /brand (auto-chains) or standalone for existing clients.
allowed-tools: "Read Write Glob Grep mcp__notion__.* mcp__getclicked__.*"
---

## Current state
!`[ -f context/brand.md ] && echo "OK: brand.md exists" || echo "WARNING: no brand.md — will run /brand first"`
!`[ -f context/business.md ] && echo "OK: business.md exists" || echo "BLOCKED: no business.md — /brand will run /context first"`

<HARD-GATE>
Never write `context/brand-visual.json` or upload assets directly. The only path to
commit visual identity is via `publish_brand_book` (and `extract_brand` for upload).
The server enforces CAS, validators, and the public-read asset bucket.
</HARD-GATE>

# /brandbook

Builds a hosted brand guidelines book at `brand.getclicked.ai/{slug}-{suffix}` and writes `context/brand-prompt-pack.md` for downstream skills.

## Inputs
- `context/brand.md` — **required**. Auto-runs `/brand` if missing.
- `context/business.md` — required for domain discovery. Auto-runs `/context` if missing.
- `context/brand-overrides.json` — optional. User-locked field overrides.
- `context/brand-uploads/` — optional. PDF brand guide / `logo.svg` / `palette.json` / `voice.md`.

## Process

1. **Entry:** `log_run_start(client_slug=<active>, skill="brandbook", plugin_version=<from plugin.json>)`. Capture `run_id`.

2. **Discover URL** from `context/business.md`. If the file doesn't list a domain, ask the user once.

3. **Extract:** call `extract_brand(url=<domain>, client_slug=<active>, brand_uploads_path="context/brand-uploads")`. Returns `visual_json`, `asset_refs`, `provenance`, `warnings`.

4. **CHECKPOINT — color roles:**
   > "Vision picked these as your brand colors:
   > - Primary: {visual_json.color_roles.primary.hex}
   > - Secondary: {visual_json.color_roles.secondary.hex}
   > - Background: {visual_json.color_roles.background.hex}
   >
   > Right? Or should I override any?"
   On override: write `context/brand-overrides.json` (merge with any existing), re-run step 3 so the extractor picks up the overrides.

5. **Read parent_revisions:** fetch latest `brand_pages.revision` for this client_slug (via `resolve_brand_asset_urls` or by a direct lookup you pass through the extract_brand result cache). For first publish, `parent_revisions = {"brand_pages.revision": null}`.

6. **Commit:** `publish_brand_book(client_slug=<active>, visual_json=<JSON string of visual_json>, asset_refs=<from step 3>, parent_revisions=<step 5>, run_id=<captured>)`.

   Handle responses:
   - `{ok: true, revision, book_url, prompt_pack_md, assets_manifest}` → write `context/brand-prompt-pack.md` locally so downstream skills can read it without re-calling. Proceed to step 7.
   - `{ok: false, reason: "stale_revision", current_revision}` → fetch latest, ask user "Someone published rev {current_revision} while we were extracting — override or merge?" Retry with updated `parent_revisions`. Cap 3 attempts.
   - `{ok: false, reason: "memory_violations", violations}` → surface each; ask user to update `brand.md` or override the constraint. Retry. Cap 3 attempts. Never bypass.
   - `{ok: false, reason: "narrative_missing"}` → run `/brand` first, then retry.
   - `{ok: false, reason: "missing_assets"}` → asset upload didn't stick; re-run step 3.
   - Server unreachable → write payload to `.pending-publish/{run_id}.json`, tell user "Server unreachable — queued for retry on next session." Do NOT claim success.

7. **Show result:**
   > "Brand book live: {book_url}
   > PDF: {pdf_url or 'generating…'}
   > Agent prompt pack: context/brand-prompt-pack.md
   >
   > Next: want me to build a landing page? /landing"

8. **Exit:** `log_run_finish(run_id=<captured>, client_slug=<active>, status="completed", outputs_manifest=<from publish_brand_book>)`.

## Outputs
| File | Required |
|------|----------|
| `context/brand-prompt-pack.md` | Yes (written from `publish_brand_book` response). |
| `brand_pages` row + asset blobs | Yes (server-owned). |

## Budgets
- Max 1 `extract_brand` call (internal vision + crawl).
- Max 3 `publish_brand_book` retry attempts.
- Max 1 `log_run_start` + 1 `log_run_finish`.

## Next
"Brand book is live. Want me to build a landing page? /landing"
If the user gives an open-ended answer, invoke `/landing`.
