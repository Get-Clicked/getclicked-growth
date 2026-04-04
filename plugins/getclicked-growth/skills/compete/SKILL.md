---
name: compete
description: Research competitor domains — organic rankings, paid keywords, ad copy, landing pages, and keyword gaps. Produces a CEO-ready narrative report and machine-readable gaps file for downstream skills.
allowed-tools: "Read Write Glob Grep mcp__notion__.* mcp__getclicked-research__.*"
---

# /compete

Deep competitive intelligence. Give it a domain and it pulls organic rankings, paid keywords, ad copy, and landing pages — then synthesizes into a narrative report and machine-readable gaps file. No prior context required.

## References
- Golden example: `docs/golden-examples/context-market.md` (closest reference for narrative competitor analysis)
- API patterns: `docs/reference/api-patterns.md`
- Notion guide: `docs/reference/notion-workspace.md`

## Input
- User provides competitor domain(s) — OR — `context/market.md` has a competitor list
- `context/business.md` — optional, enables `domain_intersection` for keyword overlap
- `context/brand.md` — optional, sharpens differentiation analysis
- `insights/keyword-research.md` — read before DataForSEO calls

## Process

### Phase 1 — Target Selection [~1 min]
Confirm which domains to research before pulling data. Each domain costs API credits.

### Phase 2 — Domain Intelligence [~3-5 min per competitor]
For each confirmed domain, pull via MCP tools:
1. `domain_overview` — traffic, keyword counts, backlinks
2. `ranked_keywords` — top organic keywords with positions and traffic
3. `paid_keywords` — keywords they bid on, estimated CPC

Write per-competitor: `compete/{domain-slug}/overview.md` (narrative strategy summary) + `organic-keywords.csv` + `paid-keywords.csv`.

### Phase 3 — Deep Intelligence [Comprehensive only]
1. `competitor_ads` — actual ad copy (headlines, descriptions, landing URLs)
2. `web_extract` on top 3-5 landing pages
3. `domain_intersection` if client domain known

Write: `compete/{slug}/ad-copy.md` + `compete/{slug}/landing-pages.md`.

### Phase 4 — Synthesis [~2-3 min]
Compare across all competitors. Write:

**`compete/gaps.md`** — machine-readable. Sections: Organic gaps (they rank, we don't), Paid gaps (they bid, we don't), Contested ground, Positioning gaps, Ad copy patterns, Landing page patterns.

**`compete/compete-report.md`** — CEO-ready narrative. Structure: single biggest finding, competitive landscape overview, per-competitor deep dives (30-second take, organic position, paid strategy, vulnerability), keyword battlefield (they own / we own / contested / white space), strategic recommendations for /brand, /ads, /seo, /landing.

### `/compete copypaste` variant
Research one competitor comprehensively, then build the whole counter-campaign inline: ads targeting their keywords with better copy, landing pages beating their weaknesses, framed as an experiment. Requires `context/business.md` + `context/brand.md`.

## Output

| File | Fast | Comprehensive |
|------|------|---------------|
| `compete/{slug}/overview.md` | Required | Required |
| `compete/{slug}/organic-keywords.csv` | Required | Required |
| `compete/{slug}/paid-keywords.csv` | Required | Required |
| `compete/{slug}/ad-copy.md` | Skip | Required |
| `compete/{slug}/landing-pages.md` | Skip | Required |
| `compete/gaps.md` | Required | Required |
| `compete/compete-report.md` | Required | Required |

**Notion:** Sync report + gaps to Competitive Intel section.

## Quality check
- Every metric is real DataForSEO data — never estimate traffic or keyword counts
- Every competitor gets a specific vulnerability identified (not just description)
- gaps.md is machine-parseable with consistent CSV-style sections

## Budgets
- Max 2 Read calls (reference files)
- Max 3 MCP calls per competitor (domain_overview + ranked_keywords + paid_keywords)
- Max 2 Notion writes (report + gaps)
- Max 3K characters per Notion page section

## Next
Suggest based on findings: `/brand` if positioning gaps dominate, `/ads` if paid keyword gaps are rich, `/seo` if organic gaps tell the story.
