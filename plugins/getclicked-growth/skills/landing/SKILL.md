---
name: landing
description: Create landing page specs aligned to ad groups — one page per ad group with matched messaging, PAS framework copy, CTAs, and conversion optimization. Use when ads exist and need landing pages, or building A/B test variants.
allowed-tools: "Read Write Glob Grep mcp__notion__.* mcp__getclicked-research__.*"
---

## Current state
!`[ -f ads/ad-groups.json ] && echo "Ad groups available — build pages to match" || echo "WARNING: No ad groups — run /ads first"`

# /landing

Build conversion-optimized landing page specs that match ad copy to page content. One page per ad group so every visitor lands on a page designed for their exact search intent. Then generate branded HTML and publish live.

## References
- Golden examples: `docs/golden-examples/landing-page-spec.md`, `docs/golden-examples/landing-brief.md`
- Conversion research: `skills/landing/REFERENCE.md` (benchmarks, A/B test data, form field research)
- API patterns: `docs/reference/api-patterns.md`
- Notion guide: `docs/reference/notion-workspace.md`

## Input
- `ads/ad-groups.json`, `ads/export-keywords.csv` — **required.** If missing, run `/ads` first.
- `context/business.md` — **required** (name, location, hours, credentials, review count).
- `context/brand.md`, `context/brand-visual.json` — optional but needed for branded HTML generation.
- `context/personas/` — optional, grounds copy in real customer language.
- `insights/`, `compete/` — optional, past conversion learnings + competitor page analysis.

## Process

### 1. Audit -> `landing/audit.md` [~2 min]
Read Final URLs from `ads/export-keywords.csv`. For each unique URL (max 5), fetch with `web_extract` and score on 8 dimensions: Message Match, CTA Clarity, Trust Signals, Relevance, Mobile, Speed, Reading Level, Form Friction (1-5 each, /40 total). Verdict: Build new / Fix / Good.

### 2. Page Specs -> `landing/pages/{slug}.md` [~4 min]
**Fast:** Top 3 BOFU ad groups. **Comprehensive:** All groups.

Per ad group, write a full page spec with draft copy (not descriptions of copy). PAS framework: Problem (persona's words) -> Agitate (cost of inaction) -> Solve (service as relief).

**9 sections in order (CRO-validated, don't rearrange):**
1. Hero — H1 echoes ad headline, primary CTA, image direction
2. Micro-trust bar — 4 signals with specific numbers (reviews, credential, experience, guarantee)
3. Problem + Agitation — PAS copy in persona voice
4. Solution + Benefits — 3 outcomes (not features) + CTA #2 (same label)
5. How It Works — 3 steps, Step 3 = the outcome they want
6. Social Proof — named testimonials with concrete details
7. FAQ / Objection Handling — 4-6 questions from persona fears, price mandatory, FAQPage schema
8. Final CTA — CTA #3 (same label) + risk removal
9. Footer — phone, address, hours. Zero navigation.

**Non-negotiables:** Headlines <= 30 chars in ad, H1 echoes it. One CTA label, three placements. 5th-7th grade reading level. 3 form fields max (never phone). No navigation. Mobile-first (CTA within 600px on 375px screen).

Each spec ends with an **ad copy alignment check** table verifying message match.

### 3. Generate + Publish HTML [per page]
If `context/brand-visual.json` exists: generate self-contained HTML (all CSS inline, Google Fonts, Lucide icons, CSS variables from brand tokens). Write to `landing/mockup/{slug}.html`. If `publish_landing_page` MCP tool available, publish and show live URL.

### 4. Geo Pages [Comprehensive only]
Location-specific variants for local businesses. Unique content per city (not city-name swaps). Top 5-10 cities.

### 5. Brief -> `landing/brief.md` [~1 min]
Summary for dev/design: page inventory table, shared elements, build order, content needs from client, technical requirements.

## Output

| File | Fast | Comprehensive |
|------|------|---------------|
| `landing/audit.md` | Required | Required |
| `landing/pages/*.md` | Top 3 groups | All groups |
| `landing/mockup/*.html` | Top 3 groups | All groups |
| `landing/brief.md` | Required | Required |
| `landing/geo/*.md` | Skip | If applicable |
| `landing/variants/*.md` | Skip | If requested |

**Notion:** Sync pages with live preview links at top, brief to Landing Pages section.

## Quality check
- Every page H1 echoes its ad headline (message match verified in alignment table)
- All trust signals use specific numbers from business.md — no vague claims
- Copy is 5th-7th grade reading level — short sentences, no jargon

## Budgets
- Max 3 Read calls (golden examples + REFERENCE.md + context files)
- Max 3 MCP research calls (web_extract for auditing existing pages)
- Max 2 Notion writes (brief + pages)
- Max 3K characters per Notion page section

## Next
Suggest `/experiment` or `/optimize` — "Landing pages built. Run /experiment to set up A/B tests, or /optimize after 7+ days of live traffic to analyze performance."
