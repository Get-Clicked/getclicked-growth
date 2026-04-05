---
name: funnel
description: Analyze conversion funnels from acquisition through activation and revenue — pull analytics from PostHog or GA4, identify drop-offs by channel, and recommend experiments targeting the biggest leaks. Use when ads are converting but revenue isn't following, investigating why signups don't activate, comparing channel quality beyond clicks, or before scaling ad spend.
allowed-tools: "Read Write Glob Grep mcp__notion__.* mcp__getclicked__.*"
---

# /funnel

Connect acquisition (ads, SEO, organic) to business outcomes (activation, revenue, retention) by pulling analytics data, mapping the funnel, identifying where users drop off, and proposing experiments to fix the biggest leaks. Core insight: cost-per-activated-user matters more than cost-per-click.

## References
- API patterns: `docs/reference/api-patterns.md`
- Notion guide: `docs/reference/notion-workspace.md`

## Input
- `context/business.md` — **required** (understand the product and ICP).
- **At least one analytics source** — PostHog via `getclicked-mcp` (preferred), GA4 via `getclicked-mcp`, or user-provided funnel data. If none available, offer manual mode: "Paste your funnel metrics and I'll work with that."
- `ads/ad-groups.json`, `landing/pages/`, `optimize/report.md`, `context/personas/`, `insights/`, `funnel/state.json` — optional, increasingly valuable.

## Process

### 1. Define the funnel
If `funnel/state.json` exists, reuse the funnel definition (confirm with user). Otherwise, auto-discover from PostHog events or ask: "What are the key steps from first visit to paying customer? I need 3-6 stages." Store definition in `funnel/state.json`.

Data maturity gates analysis depth: Thin (<100 entries or <14d) = snapshot only. Usable (100-500, 14-30d) = patterns with caveats. Solid (500+, 30d+) = full analysis. Rich (1000+, 60d+) = cohorts + segments.

### 2. Funnel snapshot
Pull current data from connected analytics. For each stage: visitor count, conversion rate to next stage, cumulative rate, drop-off rate. Compare to previous run if benchmarks exist. Flag any stage where drop-off worsened >5pp.

### 3. Channel attribution
Map acquisition channels to funnel outcomes. Build channel x funnel matrix: volume per stage, stage conversion rates, end-to-end rate, cost per activated user (not just cost per click). Cross-reference with `ads/ad-groups.json` to identify which ad groups produce users that activate vs. tourists.

### 4. Drop-off diagnosis
For each significant drop-off (>30% or worsening trend): which segments drop off most, when they drop (same session vs. day 3), what's the last event before dropping, is there an intent mismatch between acquisition promise and product experience. Cross-reference landing pages and personas.

### 5. Experiment proposals (comprehensive only — fast mode flags leaks in prose)
For each major drop-off: target stage, hypothesis, what to change, expected impact, measurement plan, minimum sample size, which acquisition channels benefit. Write `funnel/drop-off-experiments.json`.

### 6. Synthesis
Archive previous report. Write `funnel/report.md`: executive summary, funnel table, channel attribution narrative ("Google Ads drove 500 visits but only 12% activated vs. 34% organic — intent mismatch"), drop-off diagnosis paragraphs, experiment proposals, honest take. Update `funnel/state.json` benchmarks. Write to `insights/funnel-patterns.md`.

**Voice:** Growth advisor who follows the money, not a dashboard narrator. Connect cause to effect. "40% of free-trial signups never complete onboarding. It's worse for enterprise users (52%) than startup users (28%). Enterprise users hit a credit card gate they didn't expect."

## Output

| File | Fast | Comprehensive |
|------|------|---------------|
| `funnel/report.md` | Yes | Yes |
| `funnel/state.json` | Yes | Yes |
| `funnel/analysis.json` | Yes | Yes |
| `funnel/channel-funnel-matrix.json` | Skip | Yes |
| `funnel/drop-off-experiments.json` | Skip | Yes |

**Notion:** Sync `funnel/report.md` to Insights > "Funnel Analysis YYYY-MM-DD".

**Inline fallback:** Funnel stages with conversion rates, biggest leak (stage + drop-off % + hypothesis), channel attribution (cost per activated user, not just CPC), top experiment proposal.

## Quality check
- Never fabricate funnel data — real analytics or explicitly user-provided
- Data maturity gates respected — no onboarding redesign recommendations from 50 signups
- Channel quality reframed as cost-per-activated-user, not cost-per-click

## Budgets
- Max 3 Read calls (context + ads + insights)
- Max 3 MCP research calls (PostHog/GA4 queries)
- Max 1 Notion write
- Max 3K characters per Notion page section

## Next
Suggest `/experiment` to formalize the top funnel fix — "Biggest leak is [stage] at [X]% drop-off. Want me to design an experiment to test a fix?"
