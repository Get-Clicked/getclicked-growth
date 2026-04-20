# Notion Workspace Reference

Shared reference for all skills. Read this instead of inlining Notion setup in each SKILL.md.

---

## Workspace Template

When creating a new workspace, title it "[Client Name] Workspace" and create these section pages as children:

```
Research section:
  Business & Market        <- context/business.md + context/market.md combined
  Competitive Intelligence <- compete/compete-report.md, compete/gaps.md
  Personas                 <- context/personas/ (one sub-page per persona)
  Brand & Positioning      <- context/brand.md
  Keywords                 <- context/keywords.md
  Live Ads Inventory       <- context/live-ads.md narrative + child database of ads (one row per ad)

Strategy section:
  Go-to-Market             <- gtm/prototype.md, gtm/messaging.md, gtm/validation-roadmap.md
  SEO Strategy             <- seo/dashboard.md, seo/keywords.csv

Execution section:
  Ad Campaigns             <- ads/ad-groups.json, ads/budget.md, ads/forecast.md
  Landing Pages            <- landing/pages/*.md
  Experiments              <- experiments/EXP-*.md
  Performance              <- optimize/report.md, funnel/report.md
```

Create the full structure up front (pages can be empty). Write content into existing pages as each skill completes. This gives the user a table of contents from the start.

---

## Registry Pattern

After creating the workspace, save page IDs to `context/notion-workspace.json`:

```json
{
  "client": "client-name",
  "workspace_id": "uuid-of-workspace-page",
  "pages": {
    "business_market": { "id": "uuid", "title": "Business & Market" },
    "competitive": { "id": "uuid", "title": "Competitive Intelligence" },
    "personas": { "id": "uuid", "title": "Personas" },
    "brand": { "id": "uuid", "title": "Brand & Positioning" },
    "keywords": { "id": "uuid", "title": "Keywords" },
    "live_ads": { "id": "uuid", "title": "Live Ads Inventory", "database_id": "uuid-of-child-database-or-null" },
    "gtm": { "id": "uuid", "title": "Go-to-Market" },
    "seo": { "id": "uuid", "title": "SEO Strategy" },
    "ads": { "id": "uuid", "title": "Ad Campaigns" },
    "landing": { "id": "uuid", "title": "Landing Pages" },
    "experiments": { "id": "uuid", "title": "Experiments" },
    "performance": { "id": "uuid", "title": "Performance" }
  }
}
```

On every skill run, read the registry first. Never search Notion if the registry exists.

---

## Page-to-File Mapping

| Local File | Notion Target | Method |
|-----------|---------------|--------|
| `context/business.md` + `context/market.md` | Business & Market | `notion-update-page` |
| `context/brand.md` | Brand & Positioning | `notion-update-page` |
| `context/keywords.md` | Keywords | `notion-update-page` |
| `context/live-ads.md` + `context/live-ads.json` | Live Ads Inventory (page + child database) | `notion-update-page` (narrative) + `notion-create-database` (first run) + `notion-create-pages` (one per ad row) |
| `context/personas/*.md` | Personas (sub-pages) | `notion-create-pages` |
| `compete/*.md` | Competitive Intelligence | `notion-update-page` |
| `gtm/*.md` | Go-to-Market | `notion-update-page` |
| `seo/dashboard.md`, `seo/keywords.csv` | SEO Strategy | `notion-update-page` |
| `ads/ad-groups.json`, `ads/budget.md`, `ads/forecast.md` | Ad Campaigns | `notion-update-page` |
| `landing/pages/*.md` | Landing Pages (sub-pages) | `notion-create-pages` |
| `experiments/EXP-*.md` | Experiments (sub-pages) | `notion-create-pages` |
| `optimize/*.md` + `funnel/*.md` | Performance | `notion-update-page` |

---

## Writing Rules

1. **Write incrementally.** Each deliverable goes to Notion immediately after the local file is created. Do not batch writes to the end of a skill run.
2. **Use `update_content`, not `replace_content`.** The replace command fails if child pages exist and you don't reference every one. Update does search-and-replace on specific sections -- safer and more predictable.
3. **Read the registry first.** Never call `notion-search` when `context/notion-workspace.json` exists.
4. **Max 3K characters per page section.** Notion blocks have limits. Break long content into multiple sections.
5. **Never block on Notion.** If it fails, log internally and continue. Local files are always the baseline.
6. **Preserve child pages.** If you must use `replace_content`, first `notion-fetch` to get all `<page url="...">` tags and include them in your new content.

---

## Output Length Constraints

| Section | Target Length | Format |
|---------|-------------|--------|
| Business & Market | 2-3K characters | Narrative prose |
| Brand & Positioning | 2-3K characters | Narrative prose |
| Keywords | Table + brief theme intros | Minimal prose, tables earn their place |
| Ad Campaigns | Structured JSON + summary | Narrative per ad group + tables for keywords |
| Each landing page spec | 1-2K characters | PAS framework prose |
| GTM | 3 pages (strategy, messaging, validation) | 2K each, narrative |
| SEO Strategy | Dashboard format | Narrative sections + genuinely tabular data |
| Experiments | Per-experiment pages | 1-2K each |
| Live Ads Inventory | Narrative summary (1-2K) + child database | Narrative prose above; database below with one row per ad |

---

## Live Ads Inventory Database Schema

When creating the child database under the Live Ads Inventory page (first `/context` Phase 5 run that finds ads), use this schema:

| Property | Type | Options / Notes |
|---|---|---|
| Title | title | `{advertiser} {format} {library_id[-6:] or creative_id[-6:]}` — lets the user scan by advertiser at a glance |
| Platform | select | `Meta`, `Google` |
| Advertiser | rich_text | From ad dict `advertiser_name` (Meta) or `advertiser_name` (Google) |
| Format | select | `Image`, `Video`, `Text`, `Carousel`, `Unknown` |
| Status | select | `Active`, `Inactive` (Meta only — Google always Active via Transparency) |
| Start Date | date | Meta `start_date`; blank for Google (v1 grid-only) |
| Source | select | `page_scoped`, `keyword_fallback`, `domain_suggestion` — for scrape-attribution debugging |
| Creative Text | rich_text | Truncated to 500 chars; full text in `context/live-ads.json` |
| Media | url | `media_url` |
| Link | url | `snapshot_url` (Meta) or `creative_page_url` (Google) |
| Scraped | date | Date of the `/context` run |

After creating the database once (first run with ads), save `database_id` to the registry under `pages.live_ads.database_id`. On subsequent runs, use `notion-create-pages` against that database_id to insert new rows (one per ad); do not recreate the database.

Update the narrative summary via `notion-update-page` on the Live Ads Inventory parent page — the narrative replaces each run to reflect the latest scrape.
