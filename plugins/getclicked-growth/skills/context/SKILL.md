---
name: context
description: Build foundational business context — company profile, market landscape, validated keyword themes, and audience personas with real DataForSEO metrics. Use when onboarding a new client, starting a marketing engagement, or when other skills need context files.
allowed-tools: "Read Write Glob Grep mcp__notion__.* mcp__getclicked__.* WebFetch WebSearch"
---

<HARD-GATE>
Publish-path enforcement. Commit core context files via `publish_context_files` (business.md,
market.md, keywords.md) and personas via `publish_files` (variable paths). Do NOT use
Write/Edit to produce `context/business.md`, `context/market.md`, `context/keywords.md`,
or `context/personas/*.md`. Generate content as strings → call the publish tool → server
writes. Write remains available for `.pending-publish/*` and `insights/*.md` scratch only.
</HARD-GATE>

## Current state
!`[ -f context/business.md ] && echo "RETURNING: Context exists — read existing files before researching" || echo "NEW: No context yet — start fresh research"`

# /context

Build and maintain the foundational knowledge base that every downstream skill reads from. Four phases: business profile, market intel, keyword validation, and personas. Facts only — no brand strategy, no channel tactics.

## References
- Golden examples: `docs/golden-examples/context-business.md`, `docs/golden-examples/context-market.md`, `docs/golden-examples/context-keywords.md`, `docs/golden-examples/context-persona.md`, `docs/golden-examples/context-live-ads.md`
- API patterns: `docs/reference/api-patterns.md`
- Notion guide: `docs/reference/notion-workspace.md`

## Input
- User's business URL and answers to discovery questions
- `insights/keyword-research.md` (if exists) — read before DataForSEO calls to avoid re-pulling dead ends
- `.active-client` + `context/notion-workspace.json` for Notion sync

## Process

### Phase 1 — Business Expert [~2 min]
1. Ask for business URL. Scrape it with `web_extract` for initial context.
2. Extract visual brand identity silently into `context/brand-identity.json` (colors, fonts, logo, button styles from computed CSS — see golden example for schema).
3. Ask one question at a time: products/services, ideal customer, value prop, location/service area, hours, insurance/payment.
4. Write `context/business.md` — narrative investment-memo style (see golden example).

**CHECKPOINT — Business Summary**
After writing business.md, present a 4-5 sentence summary:
"Here's what I found about your business: [what you do, who you serve, how you're different, where you operate].
Did I get this right? What am I missing?"
Wait for response. Update business.md if needed, then continue to Phase 2.

### Phase 2 — Market Intel [~3 min]
1. Ask about top 3-5 competitors and differentiators. Research independently: 3 web searches max.
2. **Comprehensive only:** Pull `ranked_keywords` per competitor (top 3) for SEO posture and gap analysis.
3. Write `context/market.md` — strategy-brief style with competitor table + narrative interpretation.

### Phase 3 — North Star Keywords [~3 min]
1. Identify 3-6 strategic keyword themes from business + market context.
2. Validate with `keyword_search_volume` (batch 10 per call). Read `insights/keyword-research.md` first.
3. **Comprehensive only:** Geo-specific CPC pulls via `keyword_search_volume` per target state (max 5 geos, top 8-10 keywords).
4. Reorder priorities by real data: volume x inverse competition x intent alignment.
5. Write `context/keywords.md`. Append new findings to `insights/keyword-research.md`.

**CHECKPOINT — Keyword Themes**
Before moving to personas, present the keyword themes:
"Here are the [N] keyword themes I'd build your campaigns around:
- [Theme 1]: [top keyword] at [volume]/mo, $[CPC]
- [Theme 2]: [top keyword] at [volume]/mo, $[CPC]
What's missing? Anything here that doesn't fit?"
Wait for response. Adjust keywords.md if needed, then continue to Phase 4.

### Phase 4 — Personas [~2 min]
1. Suggest 2-3 segments from business.md audience section. Ask user to confirm/adjust.
2. Ask: what triggers the search? What objections before choosing?
3. Write `context/personas/{slug}.md` (character-first, not demographic spec) + `context/personas/INDEX.md`.
4. **Fast:** 2 personas. **Comprehensive:** 3-4 personas.

**CHECKPOINT — Personas**
After writing ALL persona files and INDEX.md, present a 1-line summary of each:
"I've drafted [N] personas:
- **[Name]**: [role], triggered by [catalyst], worried about [objection]
Do these feel right? Anyone I'm missing?"
Wait for response. Adjust personas if needed, then continue to Phase 5.

### Phase 5 — Live Ads Inventory [~2 min, Claude Code only]
1. Probe for CLI availability — shell out with `!fb-pages live-ads --help`. If the command errors (not installed, not on PATH, Playwright missing), skip Phase 5 gracefully. Tell the user verbatim: "I'll skip the live ads scan — it needs the fb-pages CLI installed locally. Run `uv pip install -e founderbee-integrations && uv run playwright install chromium` from the repo root, then re-run and I'll pick up Phase 5." Continue to next skill.
2. Determine identifiers:
   - **Meta handle:** if a Facebook URL was scraped into `context/business.md` during Phase 1, use it. Otherwise ask the user for their Facebook Page handle or full URL.
   - **Google domain:** use the primary domain already captured in `context/business.md`.
3. Shell out to the scraper — max 1 Bash call:
   ```
   !fb-pages live-ads --meta-handle "<handle>" --google-domain "<domain>" --country US --out context/
   ```
4. Read `context/live-ads.json`. Branch on per-platform `status` fields:
   - **`meta.status == "not_found"`** — ask the user to paste the exact Facebook Page URL and re-run with `--meta-handle <URL>`. If they confirm the business has no Page, record "Meta: no Page" in live-ads.md and continue to Google.
   - **`meta.status == "consent_or_login_wall"` or `"timeout"`** — record the block in live-ads.md, surface the `meta.debug_screenshot` path to the user, and continue with Google data. Do NOT pretend the scrape succeeded.
   - **`google.status == "ambiguous"`** — present the `candidates` list verbatim (each has `advertiser_id`, `advertiser_name`, `region`, `ads_count`, `verified`) and ask the user which advertiser is theirs. Re-run with `--google-advertiser-id <ID>`.
   - **`google.status == "unverified_advertiser"`** — treat as a legitimate finding, not an error. Note in live-ads.md: "Not a verified advertiser in Google Ads Transparency — small businesses and brand-new accounts often aren't listed."
   - **Either side `"selector_break"`** — stop and report to the user that the platform DOM changed and selectors need re-capture via Task 0 of the live-ads plan. Do NOT hand-roll replacements in live-ads.md — an incorrect inventory is worse than no inventory.
5. Synthesize `context/live-ads.md` from the JSON, following the golden example at `docs/golden-examples/context-live-ads.md`. Narrative-first. Never invent ads that weren't in the scrape. Every ad referenced in prose must carry its source URL (`snapshot_url` for Meta, `creative_page_url` for Google).
6. Do NOT embed the raw JSON in the MD. Reference it: "Full creative inventory in `context/live-ads.json`."
7. **Write to Notion** (if `context/notion-workspace.json` exists and has a `live_ads` entry):
   a. **Narrative page:** `notion-update-page` on `pages.live_ads.id` with the content of `context/live-ads.md` (narrative + channel gaps + implications for /ads). Max 3K chars per section — split if needed.
   b. **Database (first run only):** if `pages.live_ads.database_id` is missing OR null, call `notion-create-database` as a child of `pages.live_ads.id` with the schema defined in `docs/reference/notion-workspace.md` → "Live Ads Inventory Database Schema". Save the returned `database_id` back to the registry.
   c. **Rows:** for each ad in `meta.ads[]` and `google.ads[]`, call `notion-create-pages` in the database with one page per ad. Populate:
      - Title: `{advertiser} {format} {library_id_last6 or creative_id_last6}`
      - Platform: `Meta` or `Google`
      - Advertiser: from `advertiser_name`
      - Format: Meta ads → derive from `media_type` (`image`/`video`); Google ads → `format`
      - Status: `Active` if Meta `active` is true, else `Inactive`; Google always `Active` in v1
      - Start Date: Meta `start_date` parsed; blank for Google
      - Source: `page_scoped` (Meta default), `keyword_fallback` (Meta when `source` field tagged), `domain_suggestion` (Google when advertiser_name came from post-click nav)
      - Creative Text: truncated to 500 chars
      - Media: `media_url`
      - Link: `snapshot_url` (Meta) or `creative_page_url` (Google)
      - Scraped: today's date
   d. On Notion failures (auth lost, 500, etc.), log internally and continue — local files are the baseline. Never block on Notion.

   **Workspace page missing `live_ads` entry?** The registry was built before this skill existed. Create the page once via `notion-create-pages` as a child of the workspace root (title: "Live Ads Inventory"), save its id to `context/notion-workspace.json` under `pages.live_ads.id`, then proceed with steps (a)-(c).

**Known schema gaps to respect when writing live-ads.md:**
- Meta's per-ad `platforms` field is always `[]` per documented DOM gap. When describing platform mix, use **page-level** observations ("Facebook + Instagram"), not per-ad data.
- Google v1 scrape is grid-only: per-ad `first_shown` / `last_shown` / `regions` / `ad_funded_by` / `preview_link` are not captured. Don't paraphrase fields that aren't there.

**CHECKPOINT — Live Ads Summary**
After writing live-ads.md, present a 3-4 line summary:
"Here's what you already have in market:
- Meta: [status] — [N] ads, [platforms], earliest start [date]
- Google: [status] — [N] ads, [formats]
- Biggest gap I see: [one channel or format they're not using]
Does this match what your team is running? Anything I'm missing?"
Wait for response. Update live-ads.md if the user names ads that didn't show up in the scrape (they may be running outside the scraped region). Then continue.

### If MCP research tools are unavailable
- Use `web_search` / WebSearch to find publicly available data
- Mark all metrics as UNVALIDATED (do not estimate or guess)
- Still produce all output files — structure and strategic analysis are valuable even without exact metrics
- Tell the user: "I worked with publicly available data. Connect the research tools for exact keyword volumes and CPCs."

### Passive mode (updates)
When context files already exist, update based on new information. Tell the user what changed and why.

## Output

| File | Fast | Comprehensive |
|------|------|---------------|
| `context/business.md` | Required | Required |
| `context/brand-identity.json` | Required | Required |
| `context/market.md` | Required (basic) | Required (+ SEO audit) |
| `context/keywords.md` | Required (national) | Required (+ geo CPC) |
| `context/personas/*.md` + INDEX | 2 personas | 3-4 personas |
| `context/live-ads.json` + `context/live-ads.md` | Optional (Playwright required) | Required (Playwright required) |

**Notion:** Sync each file after writing — see Notion guide for page mapping.

Write narrative, not spreadsheets. Business page reads like an investment memo. Market page reads like a strategy brief. Keywords page uses tables (genuinely tabular) with narrative interpretation above each. Personas are characters with tension and motivation, not demographic spec sheets.

## Quality check
- Every keyword metric is real DataForSEO data or marked UNVALIDATED
- Business facts are sourced from the user or scraped site — nothing invented
- Personas use the customer's own language, not marketing-speak
- Live ad entries link back to their source (`snapshot_url` for Meta, `creative_page_url` for Google) — never paraphrase an ad without the receipt
- Non-ok scraper statuses are surfaced explicitly, not silently treated as "no data"

## Budgets
- Max 3 Read calls (golden examples + reference files)
- Max 5 MCP research calls (keyword_search_volume, ranked_keywords, web_extract, web_search)
- Max 1 Bash shell-out (`fb-pages live-ads`) — skip gracefully if Playwright missing
- Max ~5 Notion writes for narrative pages (business, market, keywords, personas, live-ads narrative). The live-ads database takes an additional N writes (one `notion-create-pages` call per ad; batch when possible).
- Max 3K characters per Notion page section

## Commit via `publish_context_files` + `publish_files` (multiplayer — HARD-GATE)

Shared state is server-authoritative. Commit through the publish tools, not via raw file writes.

1. **At skill entry:** `log_run_start(client_slug=<active>, skill="context", plugin_version=<plugin.json>)` → capture `run_id`.
2. **Determine `parent_revision`** per file from `.pending-publish/manifest.json` (absent = first write).
3. **Commit core files:**
   ```
   publish_context_files(client_slug=<active>,
     business_md=<content>, market_md=<content>, keywords_md=<content>,
     parent_revision={...}, run_id=<captured>)
   ```
4. **Commit personas** (variable paths) via the generic tool:
   ```
   publish_files(client_slug=<active>,
     files={"context/personas/INDEX.md": <content>,
            "context/personas/{slug}.md": <content>, ...},
     parent_revision={...}, run_id=<captured>)
   ```
5. **Handle responses:** `ok` → update local manifest. `stale_revision` → rebase + retry. `memory_violations` → rewrite + retry (cap 3). Server unreachable → `.pending-publish/{op_id}.json`. Never bypass.
6. **At skill exit:** `log_run_finish(run_id, client_slug=<active>, status, outputs_manifest=<manifest>)`.

Local `context/*` files remain scratch/cache.

## Next
After completing this skill, route based on the user's original request:

**Open-ended request** ("help me grow", "build a campaign", "get started"):
Invoke `/brand` without asking. "Context is built. Now establishing brand positioning."

**Specific skill requested** ("I need SEO", "run ads", "GTM strategy"):
Route directly to that skill — don't force through /brand. "Context is built. Now [skill]."

**Default chain:** /context -> /brand -> /ads -> /landing (for open-ended requests only).
Do not end the conversation here.
