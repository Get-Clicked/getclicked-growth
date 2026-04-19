---
name: seo
description: Build organic search strategy — live rankings dashboard with real DataForSEO metrics, keyword gaps, competitor content analysis, and prioritized actions with CPC savings math. The SEMrush killer.
allowed-tools: "Read Write Glob Grep mcp__notion__.* mcp__getclicked__.*"
---

<HARD-GATE>
Do NOT write SEO analysis or any seo/ files until context/keywords.md, context/business.md,
AND context/market.md exist. These files are produced by the /context skill. If they don't
exist, invoke /context first. Do NOT write these files yourself.
</HARD-GATE>

# /seo

Produce a live rankings dashboard that shows a marketer their entire organic position — what they rank for, where competitors beat them, and exactly what to do about it. In 5 minutes, not $200/month.

## References
- Golden example: `docs/golden-examples/seo-analysis.md`
- API patterns: `docs/reference/api-patterns.md`
- Notion guide: `docs/reference/notion-workspace.md`

## Input
- `context/business.md`, `context/keywords.md`, `context/market.md` — **required.** If missing, run `/context` first.
- `context/brand.md`, `context/personas/` — optional, for voice alignment and content targeting.
- `insights/keyword-research.md` — read before DataForSEO calls.
- `compete/{domain}/organic-keywords.csv` — if exists, use instead of re-calling `ranked_keywords` for those competitors.

## Process

### Step 1 — Pull Rankings [~2 min]
1. `ranked_keywords` for client domain (from business.md)
2. `ranked_keywords` for each competitor domain (up to 3, from market.md)
3. `keyword_search_volume` for target keywords not covered by rankings data
4. `serp_competitors` for primary keywords to surface unknown competitors

### Step 2 — Build Dashboard -> `seo/dashboard.md` [~3 min]
Primary deliverable. Structure:
1. **Executive summary** — single most important finding, not "we analyzed your rankings"
2. **Domain overview** — total keywords, page 1/2/beyond counts, organic traffic estimate, narrative interpretation
3. **Current rankings by page** — group by URL, top pages first, narrative on whether each pulls its weight
4. **Quick wins** (pos 11-20, vol >500, comp <30), **Defend** (pos 1-5, contested), **Losing ground** (dropped 5+ pos, requires previous run), **Dead weight** (irrelevant terms)
5. **Competitor keyword gaps** — per competitor, keywords they rank for that client doesn't, filtered by theme relevance
6. **Top 5 content actions** — specific keyword + specific action + estimated traffic gain + CPC savings math. Each is a mini-brief, not a line item.
7. **Trend** — if previous dashboard exists, compare snapshots. Otherwise note "first snapshot."

**CHECKPOINT — Dashboard Review**
After writing dashboard.md, present the top finding:
"Your biggest opportunity: [describe top quick win or gap].
[1-2 sentence explanation of why it matters + estimated value].
Want me to prioritize content actions around this, or is there a different area you care about more?"
Wait for response. Adjust keyword prioritization in keywords.csv if needed.

### Step 3 — Target Keywords -> `seo/keywords.csv` [~2 min]
50-80 keywords (fast) or 80-150 (comprehensive). All intent types. Cluster by semantic similarity. Map to content type (Landing Page, Service Page, Blog, FAQ). Assign tiers: Tier 1 (quick wins), Tier 2 (competitor gaps), Tier 3 (long-term).

### Step 4 — Site Audit -> `seo/audit.md` [Comprehensive only]
Scrape site with `web_extract`. Analyze: technical (speed, mobile, HTTPS, meta tags), content (thin pages, missing H1s, cannibalization), local (GBP, NAP, schema), links. Each finding: what it costs, what we found, how to fix it.

### If MCP research tools are unavailable
- Use `web_search` / WebSearch to find publicly available ranking and traffic data
- Mark all metrics as UNVALIDATED (do not estimate or guess)
- Still produce all output files — the dashboard structure and strategic analysis are valuable even without exact metrics
- Tell the user: "I worked with publicly available data. Connect the research tools for exact rankings, volumes, and CPCs."

### Step 5 — Content Ideas -> `seo/content-ideas.csv` [Comprehensive only]
25-40 content ideas mapped to keywords. Prioritize dashboard quick wins and competitor gaps.

## Output

| File | Fast | Comprehensive |
|------|------|---------------|
| `seo/dashboard.md` | Required | Required |
| `seo/keywords.csv` | Required (50-80) | Required (80-150) |
| `seo/audit.md` | Skip | Required |
| `seo/content-ideas.csv` | Skip | Required (25-40) |

**Notion:** Sync dashboard to SEO Strategy page, keywords to SEO > Keywords database.

## Quality check
- Dashboard is the hero — it reads like a strategist's briefing, not a data dump
- Every metric is real DataForSEO data, never estimated
- Content actions include specific CPC savings math ("ranking organically saves $X/month")

## Budgets
- Max 2 Read calls (golden example + reference files)
- Max 5 MCP research calls (ranked_keywords client + 3 competitors + keyword_search_volume)
- Max 2 Notion writes (dashboard + keywords)
- Max 3K characters per Notion page section

## Commit via `publish_seo_dashboard` (multiplayer — HARD-GATE)

Shared state is server-authoritative. Commit through `publish_seo_dashboard`, not via raw file writes.

1. **At skill entry:** `log_run_start(client_slug=<active>, skill="seo", plugin_version=<plugin.json>)` → capture `run_id`.
2. **Determine `parent_revision`** per file from `.pending-publish/manifest.json` (absent = first write).
3. **Commit:**
   ```
   publish_seo_dashboard(client_slug=<active>,
     dashboard_md=<content>, keywords_csv=<content>, audit_md=<content or null>,
     parent_revision={"seo/dashboard.md": <int|null>, "seo/keywords.csv": <int|null>, "seo/audit.md": <int|null>},
     run_id=<captured>)
   ```
4. **Handle responses:** `ok` → update local manifest. `stale_revision` → rebase + retry. `memory_violations` → rewrite + retry (cap 3). Server unreachable → `.pending-publish/{op_id}.json`. Never bypass.
5. **At skill exit:** `log_run_finish(run_id, client_slug=<active>, status, outputs_manifest=<manifest>)`.

For `seo/content-ideas.csv` (comprehensive-only, variable shape), use `publish_files`.
Local `seo/*` files remain scratch/cache.

## Next
After completing this skill, route based on findings:
If quick wins map to landing page opportunities, offer `/landing`.
If the bigger need is distribution strategy, offer `/gtm`.
"Dashboard built. Landing pages for your quick wins, or full distribution strategy with /gtm?"

Don't auto-chain — SEO next step depends on user priority. But don't end here either.
