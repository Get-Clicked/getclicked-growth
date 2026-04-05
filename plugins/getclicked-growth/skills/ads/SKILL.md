---
name: ads
description: Build Google Ads campaigns — keyword research with real DataForSEO data, RSA ad copy, negative keywords, budget allocation, and ready-to-import CSV files. Use when launching paid search or expanding into new markets.
allowed-tools: "Read Write Glob Grep mcp__notion__.* mcp__getclicked-research__.*"
---

## Current state
!`[ -f ads/ad-groups.json ] && echo "UPDATING: Campaigns exist" || echo "CREATING: No campaigns yet"`
!`[ -f context/keywords.md ] && echo "Keywords available" || echo "WARNING: No keywords — run /context first"`

# /ads

Build complete Google Ads campaigns from strategic context. Six steps: keyword research, ad copy, negatives, budget, forecast, and export CSVs. Every metric is real DataForSEO data.

## References
- Golden example: `docs/golden-examples/ads-forecast.md`
- API patterns: `docs/reference/api-patterns.md`
- Notion guide: `docs/reference/notion-workspace.md`

## Input
- `context/business.md`, `context/keywords.md` — **required.** If missing, run `/context` first.
- `context/brand.md`, `context/market.md`, `context/personas/` — optional, read all available.
- `insights/keyword-research.md`, `insights/copy-patterns.md`, `insights/negative-patterns.md` — read before DataForSEO calls.
- `compete/gaps.md` — optional, competitor paid keywords inform campaign.

## Process

### 1. Keyword Research -> `ads/keywords.csv` [~3 min]
Read north star themes from `context/keywords.md`. Expand each into paid-specific keywords (max 6 themes, 10 keywords per theme). Focus on transactional/commercial intent. Use `keyword_search_volume` (batch 10 per call). 0-volume: test 2-3 word-order variants before declaring dead.

Assign: match type (Phrase default, Exact for high-value), bid tier (High/Med/Low), ad group (5-20 keywords per tight semantic cluster), intent, stage (TOFU/MOFU/BOFU).

### 2. Ad Copy -> `ads/ad-groups.json` [~3 min]
**Fast:** Top 3 BOFU ad groups. **Comprehensive:** All groups.

Per ad group: 8-10 headlines covering keyword, feature, benefit, brand/trust, social proof, price/offer, competitive, CTA categories. 2-4 descriptions.

**HARD LIMITS: Headlines <= 30 chars. Descriptions <= 90 chars.** Count character by character. Validate ALL before proceeding.

**Policy check:** No restricted terms for the industry. Healthcare: zero Rx/prescription/pharmacy/medication. No unsubstantiated superlatives. Check landing page alignment.

### 3. Negatives -> `ads/negatives.json` [~1 min]
8 categories: job seekers, DIY/education, wrong intent, wrong geography, irrelevant modifiers, information-only, wrong audience, brand competitors. 3-tier architecture (account/campaign/ad-group). Cross-check every negative against positives — never block a paying keyword.

### 4. Budget -> `ads/budget.md` [~1 min]
3 tiers (minimum/recommended/aggressive). Allocation by ad group with rationale. Each group needs $5-10/day minimum. Scaling rules.

### 5. Forecast -> `ads/forecast.md` [Comprehensive only]
Two scenarios: Conservative (Month 1-2, no QS history, 3% CVR) and Optimized (Month 3+, improving QS, 5% CVR). Revenue model, spend-to-revenue projection, breakeven analysis, "the honest take" section. See golden example.

### 6. Export -> `ads/export-*.csv` [~1 min]
Three Google Ads Editor import CSVs: `export-keywords.csv`, `export-ads.csv`, `export-negatives.csv`. One row per entity. Only active groups.

### If MCP research tools are unavailable
- Use `web_search` / WebSearch to find publicly available data
- Mark all metrics as UNVALIDATED (do not estimate or guess)
- Still produce all output files — structure and strategic analysis are valuable even without exact metrics
- Tell the user: "I worked with publicly available data. Connect the research tools for exact keyword volumes and CPCs."

## Output — Fast mode (default)
All of these are REQUIRED even in fast mode:
1. `ads/keywords.csv` — keyword research with real metrics
2. `ads/ad-groups.json` — ad groups with RSA headlines + descriptions
3. `ads/negatives.json` — negative keyword list
4. `ads/budget.md` — budget allocation + forecast (mark UNVALIDATED if no real CPC data)
5. `ads/export-keywords.csv`, `ads/export-ads.csv`, `ads/export-negatives.csv` — Google Ads Editor import files

If MCP research tools are unavailable, still produce all files but mark metrics as UNVALIDATED.

## Output — Comprehensive mode (adds)
6. `ads/forecast.md` — full forecast with revenue model
7. `ads/campaign-settings.json` — campaign settings for import

**Notion:** Sync keywords, ad groups, negatives, budget, forecast to Ads section pages.

## Quality check
- Every headline <= 30 chars, every description <= 90 chars — no exceptions
- Every keyword metric is real DataForSEO data or marked UNVALIDATED
- Negatives don't conflict with positive keywords (conflicts_prevented logged)

## Budgets
- Max 3 Read calls (golden example + reference files + context)
- Max 3 MCP research calls (keyword_search_volume batches)
- Max 2 Notion writes (ad groups + budget/forecast)
- Max 3K characters per Notion page section

## Next
Suggest `/landing` — "Campaign built. Dedicated landing pages convert 116% better than homepage traffic. Run /landing to build matched pages for each ad group?"
