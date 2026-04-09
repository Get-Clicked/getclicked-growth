---
name: ads
description: Build Google Ads campaigns — Search (keyword research, RSA ad copy, negatives, budget) or App Install (text assets, creative brief, measurement plan). Real DataForSEO data.
allowed-tools: "Read Write Glob Grep mcp__notion__.* mcp__getclicked__.*"
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

## Campaign Type

After reading context, ask the user:

> "What's the goal for this campaign?"
> - **Get app installs** — people download your app directly from the App Store or Play Store
> - **Drive website traffic** — people visit your site, sign up, buy something

If app installs → follow the **App Campaign Process** below.
If website traffic → follow the existing **Process** (Search campaigns, unchanged).

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

## App Campaign Process

Use this flow when the user chose "Get app installs."

### A1. Research (~3 min)
Same as Step 1 above. Keyword research informs text assets even though App campaigns don't use keywords for targeting.

### A2. Collect app details
Ask for or detect from context:
- App store link (Play Store or App Store URL)
- Platform: Android, iOS, or both (if both, build one campaign per platform)
- Target CPI (or recommend based on market data — typical range $1.50-$4.50)

Extract app_id from the URL:
- Play Store: package name from URL (e.g., `com.grability.rappi`)
- App Store: numeric ID from URL (e.g., `900910900`), NOT the bundle ID

### A3. Text assets → `ads/app-assets.json`
5 headlines (max 30 chars each), 5 descriptions (max 90 chars each).

Same character validation rules as Search RSAs. Each asset must make sense independently AND in any combination. Use keyword research + brand positioning to inform copy.

**HARD LIMITS: Headlines <= 30 chars. Descriptions <= 90 chars.** Count character by character.

Output `ads/app-assets.json` (text assets only — Step 3):
```json
{
  "campaign_name": "[Business] - App Installs - [Geo]",
  "app_id": "[package name or store ID]",
  "app_store": "GOOGLE_PLAY",
  "campaign_subtype": "APP_CAMPAIGN",
  "bidding_goal": "OPTIMIZE_INSTALLS_TARGET_INSTALL_COST",
  "headlines": [{"text": "..."}, ...],
  "descriptions": [{"text": "..."}, ...]
}
```

After budget/targeting are decided (Steps A5-A6), produce the full export `ads/app-campaign.json`:
```json
{
  "campaign_name": "[Business] - App Installs - [Geo]",
  "app_id": "[package name or store ID]",
  "app_store": "GOOGLE_PLAY",
  "campaign_subtype": "APP_CAMPAIGN",
  "bidding_goal": "OPTIMIZE_INSTALLS_TARGET_INSTALL_COST",
  "target_cpa_micros": 2000000,
  "daily_budget_micros": 100000000,
  "headlines": [{"text": "..."}, ...],
  "descriptions": [{"text": "..."}, ...],
  "location_ids": [2840],
  "language_ids": [1000]
}
```

If user selected "both" platforms, produce two export files: `ads/app-campaign-android.json` and `ads/app-campaign-ios.json`.

### A4. Creative brief → `ads/creative-brief.md`
Tell the user what images and videos to produce:

**Images (strongly recommended, not required):**
- Square (1:1): 1200x1200px
- Landscape (1.91:1): 1200x628px
- Portrait (4:5): 1200x1500px
- JPG or PNG, max 5MB. No "Download"/"Install" text. Show app UI.

**Videos (strongly recommended — Google auto-generates if missing):**
- Landscape (16:9), Portrait (9:16), Square (1:1)
- 15-30 seconds, hosted on YouTube
- Logo in first 3 seconds, show app UI early

### A5. Budget → `ads/budget.md`
- Target CPI and daily budget (minimum 50x CPI)
- Bidding strategy: tCPI for < 30 daily conversions
- Scaling rules: max 20% increase every 48-72 hours
- Learning period: 1-2 weeks, don't change during learning

### A6. Measurement → `ads/measurement.md`
- Conversion tracking: Firebase (recommended) or MMP (AppsFlyer, Adjust)
- Events: first_open + optimization event
- Launch checklist with checkboxes

## App Campaign Output
1. `ads/app-assets.json` — text assets + app details (Step A3)
1b. `ads/app-campaign.json` (or per-platform `-android.json` / `-ios.json`) — full export with budget/targeting (Step A7)
2. `ads/creative-brief.md` — image/video specs for the user
3. `ads/budget.md` — budget + bidding + scaling
4. `ads/measurement.md` — tracking setup + launch checklist

**Notion:** Sync to existing Ad Campaigns page — campaign overview + text assets table + creative brief + budget + measurement.

## App Campaign Next Step
Do NOT suggest `/landing` for App campaigns (installs go to app store, not landing pages).
Instead: "Campaign is built. Next steps: upload your creative assets to Google Ads, set up conversion tracking, and enable the campaign. Want me to help optimize your app store listing or run a competitive analysis?"

## Budgets
- Max 3 Read calls (golden example + reference files + context)
- Max 3 MCP research calls (keyword_search_volume batches)
- Max 2 Notion writes (ad groups + budget/forecast)
- Max 3K characters per Notion page section

## Next
**Search campaigns:** Suggest `/landing` — "Campaign built. Dedicated landing pages convert 116% better than homepage traffic. Run /landing to build matched pages for each ad group?"

**App campaigns:** Do NOT suggest `/landing`. Instead: "Campaign is built. Upload your creative assets to Google Ads, set up conversion tracking, and enable it. Want me to help optimize your app store listing or run a competitive analysis?"
