---
name: optimize
description: Pull live Google Ads performance data, compare against the original plan, identify waste and opportunities, and generate ranked action items with dollar-impact estimates. Use when a campaign has been running 7+ days, monthly performance reviews, before scaling budget, or when the user asks "how's the campaign doing?"
allowed-tools: "Read Write Glob Grep mcp__notion__.* mcp__getclicked__.*"
---

## Current state
!`[ -f ads/ad-groups.json ] && echo "Campaigns exist — can analyze" || echo "WARNING: No campaigns to optimize"`

# /optimize

Pull live Google Ads data, compare against the original plan, identify what's working and what's leaking, and generate ranked improvements with dollar-impact estimates. Analysis depth scales with campaign maturity — Early (<14d) gets a light read, Mature (60d+) gets the full treatment.

## References
- Golden example: `docs/golden-examples/optimize-report.md`
- API patterns: `docs/reference/api-patterns.md`
- Notion guide: `docs/reference/notion-workspace.md`

## Input
- `ads/ad-groups.json`, `ads/forecast.md`, `ads/budget.md`, `ads/keywords.csv`, `ads/negatives.json` — **required.**
- `context/business.md` — **required** (industry benchmarks).
- **Google Ads access** via `gads` CLI — **required.** If unavailable: "I need Google Ads API access to pull live campaign data. Want me to walk you through setup?"
- `insights/*`, `landing/pages/`, `optimize/state.json` — optional, increasingly valuable.

## Process

### 1. Resolve campaign + pull data
Check `optimize/state.json` for campaign ID, or auto-detect via `gads report campaigns`. Pull all 4 reports: campaigns, search-terms, keywords, ads. Calculate maturity: Early (<14d), Learning (14-30d), Baseline (30-60d), Mature (60d+). Maturity gates everything.

### 2. Plan vs. actual
Compare `ads/forecast.md` projections against live data: spend, CPC, CTR, CVR, conversions, CAC. Compare budget allocation by ad group. Compare keyword CPC plan vs. actual. Include industry benchmarks from `context/business.md`. **Early maturity:** present numbers but say "directional only — don't make changes yet."

### 3. Search term audit
Read existing `ads/negatives.json` and `insights/negative-patterns.md` first. Flag: wasted spend (clicks + zero conversions + cost >$10), wrong intent, irrelevant traffic. Cross-check every candidate against `ads/keywords.csv` — never block a positive keyword. Find expansion candidates (conversions >0, not in keywords.csv). Update `ads/negatives.json` with source attribution.

### 4. Keyword health (comprehensive, 14d+)
Quality Score distribution by band. For QS <=5 + spend >$100: diagnose which component is "Below Average" (Expected CTR = copy, Ad Relevance = tighten groups, Landing Page = fix message match). 4-quadrant triage: Stars (protect), Potentials (watch), Money Pits (pause), Dead Weight (pause). Write `optimize/keyword-changes.json`.

### 5. Ad copy performance (comprehensive, 14d+)
Ad strength audit. Per-group CTR/CVR comparison. Below-avg CTR = copy problem. Good CTR + low CVR = landing page problem. Generate copy refresh candidates (headlines <=30 chars, descriptions <=90 chars). Write `optimize/copy-refresh.json`.

### 6. Synthesis
Archive previous report to `optimize/history/`. Write `optimize/report.md`: executive summary, plan vs. actual, search term health, ranked actions (most impactful first), proposed experiments, recommended cadence. Update `optimize/state.json` with benchmarks. Write to `insights/`.

**Voice:** Opinionated verdicts, not dashboards. "CTR is 2.1%" is a dashboard. "CTR is 2.1% — below benchmark. The headline leads with features instead of outcomes. Refresh it." is optimization.

## Output

| File | Fast | Comprehensive |
|------|------|---------------|
| `optimize/report.md` | Yes | Yes |
| `optimize/state.json` | Yes | Yes |
| `ads/negatives.json` (updated) | Yes | Yes |
| `optimize/keyword-changes.json` | Skip | Yes |
| `optimize/copy-refresh.json` | Skip | Yes |
| `optimize/expansion-candidates.csv` | Skip | Yes |

**Notion:** Sync `optimize/report.md` to Insights > "Optimize Report YYYY-MM-DD".

**Inline fallback:** Maturity tag, spend analyzed, plan vs. actual table, negatives added (est. savings), ranked actions with dollar impact.

## Quality check
- Maturity gates are non-negotiable — no keyword pauses at 10 days
- Character limits enforced: headlines <=30, descriptions <=90
- Negative keywords cross-checked against positives before adding

## Budgets
- Max 3 Read calls (golden example + plan files + insights)
- Max 0 MCP research calls (data comes from gads CLI)
- Max 1 Notion write
- Max 3K characters per Notion page section

## Next
Suggest `/experiment` for changes that need isolation testing — "Performance review is done. A few changes need testing before committing. Want me to design experiments for them?"
