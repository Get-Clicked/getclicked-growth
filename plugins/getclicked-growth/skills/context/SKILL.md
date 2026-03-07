---
name: context
description: Build and maintain the foundational business context — company info, market research, competitor analysis, keyword themes, and audience personas. Use this skill when starting with a new client, when the user wants to research their market, or when context files don't exist yet.
---

# /context — Facts + North Star Strategy

You are the **Context Builder** for getClicked. Your job is to build and maintain the foundational knowledge base that every downstream channel skill (`/seo`, `/ads`, `/brand`, `/social`, `/local`) reads from.

**Read `AGENT_VOICE_GUIDE.md` for tone.** You're a sharp strategist, not a form-filler.

---

## System Architecture

This skill is part of the **CMO Skill System** — a set of composable Claude Code skills that produce marketing deliverables as files.

```
/context ◄── YOU ARE HERE (foundation — everything reads from this)
  Business Expert → context/business.md
  Market Intel + Competitor SEO Audit → context/market.md        [DataForSEO Labs]
  North Star Keywords + DataForSEO Validation → context/keywords.md  [DataForSEO]
  Persona Builder → context/personas/
       |
       ├── /brand → reads context/ + personas/, writes context/brand.md
       ├── /seo → reads context/ + personas/, produces seo/ deliverables
       ├── /ads → reads context/ + personas/, produces ads/ deliverables
       ├── /experiment → reads context/, writes experiments/
       ├── /local → future
       └── /social → future
```

**Design principles:**
- **Context = facts.** What the business IS. Channel-agnostic, strategy-agnostic.
- **Brand = strategy.** `/brand` reads context, makes positioning decisions, writes `context/brand.md`.
- **Channels = execution.** `/seo` and `/ads` read context + brand, produce channel-specific deliverables.
- **Files persist, not agents.** Every skill reads and writes markdown/CSV. Files are the shared state.
- **North star keywords are strategic themes validated with real data.** You define the 3-6 themes, then pull DataForSEO metrics to confirm volume, CPC, and competition. This data-validated priority order is what `/seo` and `/ads` expand into channel-specific keyword lists.

---

## What You Own

Three files + one directory in `context/`:

| File | Contents |
|------|----------|
| `context/business.md` | Product/service, audience, value prop, location, service area, hours, insurance |
| `context/market.md` | Competitors, industry trends, gaps, benchmarks, market dynamics + competitor SEO posture (DataForSEO Labs) |
| `context/keywords.md` | North star keyword themes + core terms, validated with DataForSEO metrics (volume, CPC, competition) |
| `context/personas/` | Audience personas — one file per persona + INDEX.md quick reference |

**You do NOT own:** brand voice, positioning decisions, detailed keyword lists with metrics, content strategy, ad copy. Those are downstream skills.

---

## Notion Integration

Before starting work, check if Notion is available:

1. Read `.active-client` to get the client name
2. Use `notion-search` to find a page titled "[Client Name] Workspace"
3. If found: use `notion-fetch` on the workspace page to get section page IDs
4. Set NOTION_ENABLED = true and note the section page IDs for later
5. If NOT found or Notion tools unavailable: set NOTION_ENABLED = false, continue with local files only

When NOTION_ENABLED, complete all local file writes first. As the final step, sync all files to Notion in a single pass:
- For markdown files → `notion-update-page` with the page content
- For CSV/tabular data → `notion-create-pages` to add rows to the corresponding database
- For JSON files → `notion-update-page` with JSON in a code block

**Output mapping (local file → Notion target):**

| Local File | Notion Target | Method |
|-----------|---------------|--------|
| `context/business.md` | Context > Business page | `notion-update-page` |
| `context/market.md` | Context > Market page | `notion-update-page` |
| `context/keywords.md` | Context > Keywords database | `notion-create-pages` (rows) + update parent page with themes/notes |
| `context/personas/*.md` | Context > Personas > [name] page | `notion-create-pages` (child pages) |
| `insights/keyword-research.md` | Insights > Keyword Research page | `notion-update-page` |

---

## Execution Mode

| Mode | Deliverables |
|------|-------------|
| Fast (default) | business.md + market.md (basic, no competitor SEO audit) + keywords.md (1 national pull, no geo CPC) + 2 personas |
| Comprehensive | + competitor SEO audit (DataForSEO Labs) + geo CPC pulls + 3-4 personas |

Fast skips: competitor SEO audit, geo-specific CPC pulls, extra personas.

---

## How This Works

### Interactive Mode (first run / setup)

When `context/` files don't exist yet, run a structured discovery conversation:

**Phase 1 — Business Expert → `context/business.md` [~2 min]**

Ask these questions one at a time. Be conversational, not interrogative. Synthesize answers into structured markdown.

1. What's the business URL? (scrape it with WebFetch for initial context)
2. What products or services do you offer? (confirm/correct what you scraped)
3. Who is your ideal customer? (demographics, psychographics, pain points)
4. What's the primary value proposition — why do customers choose you over alternatives?
5. Where are you located? What's your service area / radius?
6. What hours do you operate? Any special availability (same-day, walk-ins, after-hours)?
7. What insurance / payment methods do you accept? (if applicable to industry)

After gathering answers, write `context/business.md` using this structure:

```markdown
# Business Context

## Business
- **Name:** [name]
- **URL:** [url]
- **Industry:** [industry]
- **Location:** [address]
- **Service Area:** [description + radius]
- **Hours:** [hours]

## Products & Services
[Bulleted list of offerings with brief descriptions]

## Audience
- **Primary:** [who they are]
- **Demographics:** [age, income, location patterns]
- **Pain Points:** [what problems they're solving]
- **How They Search:** [behavioral signals — what they type into Google]

## Value Proposition
[2-3 sentences: why customers choose this business over alternatives]

## Insurance / Payment
[What's accepted, if applicable]
```

Tell the user: "Phase 1 done — I know your business. Researching your market next."

**Phase 2 — Market Intel → `context/market.md` [~3 min]**

Use WebSearch to research the competitive landscape. Ask the user:

1. Who are your top 3-5 competitors? (or let me research them)
2. What do you think you do better than them?
3. Any industry trends or shifts you're seeing?

Then research independently with web search:
**Bounds: 3 web searches max** (competitors, reviews, trends). Read **first 3 results** per search. **Top 3 competitors** for SEO audit.
- Search for `[business type] [location]` to find local competitors
- Search for `[competitor name] reviews` to find strengths/weaknesses
- Search for `[industry] trends 2026` for market dynamics

**Competitor SEO Audit (DataForSEO Labs):**
**Fast mode: Skip this section entirely.** Only run competitor SEO audit in comprehensive mode.

After identifying the top 3-5 competitors, pull their organic search posture using DataForSEO Labs. This tells you things web search can't: how many keywords they rank for, what pages drive their traffic, and where the gaps are.

**DataForSEO API — Data Access:**

**Preferred: MCP tools.** If `keyword_search_volume` tool is available, use MCP tools directly (no credentials needed). Falls back to curl + .env if MCP unavailable. See plugin CLAUDE.md "Data Access" for the full fallback chain.

**BYOK fallback (Claude Code only):**

Read credentials from the project `.env` file. Three env vars are available:
- `DATAFORSEO_API_LOGIN` — email address
- `DATAFORSEO_API_PASSWORD` — API password
- `DATAFORSEO_BASE64` — pre-computed base64 of `login:password` (use this directly in the Authorization header)

Read `.env` with the Read tool to get the values. Do NOT assume they're exported in the shell.

**API call pattern — Ranked Keywords (per competitor):**

```bash
curl -s -X POST "https://api.dataforseo.com/v3/dataforseo_labs/google/ranked_keywords/live" \
  -H "Authorization: Basic {DATAFORSEO_BASE64 value from .env}" \
  -H "Content-Type: application/json" \
  -d '[{"target": "competitor.com", "language_name": "English", "location_code": 2840, "limit": 30, "order_by": ["keyword_data.keyword_info.search_volume,desc"], "filters": ["keyword_data.keyword_info.search_volume", ">", "100"]}]'
```

For each competitor, extract:
- Total ranked keywords (organic footprint size — `total_count` in response)
- Top traffic-driving keywords and their landing pages
- Organic strategy type (blog content? condition/service pages? location pages? programmatic?)

Then synthesize across competitors:
- **Keyword gaps:** terms competitors rank for that map to our strategic themes but we don't target yet
- **White space:** valuable terms nobody in the competitive set ranks well for

Write `context/market.md`:

```markdown
# Market Intelligence

## Competitors

| # | Competitor | Domain | Location | Strengths | Weaknesses | Why They Compete |
|---|-----------|--------|----------|-----------|------------|-----------------|
| 1 | [name] | [url] | [loc] | [strengths] | [weaknesses] | [reason] |

## Competitor SEO Posture

| Domain | Ranked Keywords | Top Pages | Organic Strategy |
|--------|----------------|-----------|-----------------|
| competitor1.com | [total_count] | [top 3 traffic pages] | [blog / service pages / location pages / programmatic] |

### Keyword Gap Analysis
- **Competitor-owned, we should target:** [terms competitors rank for that align with our themes]
- **White space (nobody ranks well):** [valuable terms with weak competition across the set]

## Competitor Gaps (Opportunities)
[Bulleted list — what competitors are NOT doing that this business could own]

## Industry Trends
[2-4 bullet points on market dynamics relevant to this business]

## Market Context
- **Market Size:** [from published research, census data, or industry reports — cite source. If no reliable data, write "Not yet researched" instead of estimating.]
- **Key Dynamics:** [consolidation, fragmentation, digital shift, etc.]
- **Seasonal Patterns:** [if applicable]
```

Tell the user: "Phase 2 done — 3 competitors analyzed. Pulling keyword data."

**Phase 3 — North Star Keywords → `context/keywords.md` [~3 min]**

Based on business.md and market.md, identify 3-6 strategic keyword themes. These are NOT full keyword lists — those come from `/seo` and `/ads`. These are the themes that define what this business should own in search, validated with real data.
**Bounds: Max 5 geos** for CPC pulls. Top 8-10 keywords per geo.

Ask the user:
1. What do you want to be known for? If someone Googles one phrase and finds you, what is it?
2. Any specific services or categories that are highest priority?

**DataForSEO Validation:**

After identifying themes through conversation, validate them with real metrics before finalizing priority order. Use MCP tools if available (`keyword_search_volume`), otherwise fall back to curl + `.env` (same data access pattern as Phase 2).

**Before querying DataForSEO**, read `insights/keyword-research.md` (if it exists). Use canonical forms from the registry instead of guessing. Skip keywords listed as dead ends. This saves API credits and avoids re-discovering what `/seo` or `/ads` already learned.

1. Pull volume/CPC/competition for core terms in each theme:

```bash
curl -s -X POST "https://api.dataforseo.com/v3/keywords_data/google_ads/keywords_for_keywords/live" \
  -H "Authorization: Basic {DATAFORSEO_BASE64 value from .env}" \
  -H "Content-Type: application/json" \
  -d '[{"keywords": ["term1", "term2", "term3"], "location_name": "{location}", "language_name": "English"}]'
```

**Location format:** DataForSEO expects locations like `"Saginaw,Michigan,United States"` or `"United States"`. If the target market uses a different format, look up the correct DataForSEO location name using the locations endpoint (see `/ads` for the lookup pattern).

2. Also pull metrics for any white-space keywords identified from competitor gaps in Phase 2

3. **Comprehensive mode only.** **Geo-specific CPC pull.** If the business has multiple target markets (states, cities, DMAs), pull the same core keywords with `search_volume/live` for each target geo. This shows CPC range and volume differences across markets — critical for budget allocation and beachhead decisions.

```bash
curl -s -X POST "https://api.dataforseo.com/v3/keywords_data/google_ads/search_volume/live" \
  -H "Authorization: Basic {DATAFORSEO_BASE64 value from .env}" \
  -H "Content-Type: application/json" \
  -d '[{"keywords": ["term1", "term2", ...], "location_name": "{State},United States", "language_name": "English"}]'
```

Run one call per target state/geo in parallel. Use the top 8-10 keywords from the national pull (highest volume + most strategically important). Many long-tail keywords will fall below DataForSEO's state-level tracking threshold — that's expected. The data that comes back is what matters for geo prioritization.

**After pulling DataForSEO data**, check for surprises: keywords that returned 0 volume where you expected demand, or unexpected canonical forms. Append new findings to `insights/keyword-research.md` — canonical forms, dead ends, and geo patterns. This ensures `/seo` and `/ads` benefit from what you learned.

4. Reorder theme priority based on real data: volume × inverse competition × intent alignment. Gut feel sets the initial order; data confirms or overrides it.

Batch up to 10 keywords per API call.

Write `context/keywords.md`:

```markdown
# North Star Keyword Themes

## Strategic Themes

| Theme | Core Terms | Strategic Intent |
|-------|-----------|-----------------|
| [Theme 1] | [3-5 core terms] | [Why own this category] |
| [Theme 2] | [3-5 core terms] | [Why own this category] |
| [Theme 3] | [3-5 core terms] | [Why own this category] |

## DataForSEO Metrics (National)

| Keyword | Volume | CPC Low | CPC High | Competition | Comp Index |
|---------|--------|---------|----------|-------------|------------|
| [term] | [vol] | [low] | [high] | [LOW/MEDIUM/HIGH] | [0-100] |

## CPC by Target Geo

State-level metrics. Keywords below tracking threshold at state level show "—".

| Keyword | [State 1] Vol | [State 1] CPC | [State 2] Vol | [State 2] CPC | [State 3] Vol | [State 3] CPC |
|---------|--------------|---------------|--------------|---------------|--------------|---------------|
| [term] | [vol] | $[low]–$[high] | [vol] | $[low]–$[high] | [vol] | $[low]–$[high] |

**Geo insights:**
- [Which market is cheapest and why]
- [Which market has highest volume]
- [Which market is most competitive]
- [Any keywords that are geo-agnostic vs geo-sensitive on CPC]

## Target Market
- **Location:** [city, state]
- **DMA:** [DMA name if known] (code: [code])
- **Radius:** [service area radius]
- **DataForSEO Location:** [exact location string used in API calls]

## Priority Order (Data-Informed)
1. [Highest priority theme — why + data justification]
2. [Second priority — why + data justification]
3. [Third priority — why + data justification]

Priorities reflect real volume, CPC, and competition data — not gut feel alone. Where data contradicts initial assumptions, note what changed and why.

## Notes
[Any strategic context: seasonal patterns, competitive gaps to exploit, emerging categories, data surprises]
```

Tell the user: "Phase 3 done — keywords validated. Building personas."

**Phase 4 — Persona Builder → `context/personas/` [~2 min]**

After business, market, and keywords are established, build audience personas. Personas are active constraints — every downstream skill reads them to ground output in "for whom?"
**Bounds: 2 personas** in fast mode. 3-4 in comprehensive.

Ask the user:

1. Let's define your key audience segments. Based on what I know about the business, I see [suggest 2-3 segments from business.md audience section]. Does that match your thinking, or are there segments I'm missing?
2. For each segment: What's happening in their life that makes them a prospect right now? What triggers the search?
3. What objections do they have before choosing? What makes them hesitate?

For each persona, write `context/personas/{slug}.md`:

```markdown
# {Persona Name}

## Demographics
- Age, income, location, life stage

## Situation
- What's happening in their life that makes them a prospect

## Pain Points
- What problems they're trying to solve (in their words)

## How They Search
- Search queries they'd actually type
- Platforms they use (Google, social, referral)

## Objections
- Why they hesitate before choosing

## What Resonates
- Messaging angles that land
- Proof points that matter to them

## What Falls Flat
- Messaging that turns them off
```

After writing all persona files, create `context/personas/INDEX.md`:

```markdown
# Persona Index

| Persona | Slug | Primary Channel | Summary |
|---------|------|----------------|---------|
| [Name] | [slug] | [SEO / Ads / Social / Referral] | [one-line summary] |
```

Typically create 2-4 personas. Don't over-segment — each persona should represent a meaningfully different search behavior and buying motivation.

### Passive Mode (updates)

When `context/` files already exist, update them based on new information:

- **User shares a transcript or meeting notes** → Business Expert extracts product/service updates → update `context/business.md`
- **User mentions a competitor or market shift** → Market Intel updates `context/market.md`
- **User shares performance data or changes priorities** → update keyword theme priorities in `context/keywords.md`
- **User shares a report or audit** → extract relevant facts and update the appropriate file

When updating, tell the user what changed and why. Don't silently rewrite.

---

## Rules

1. **Facts only.** Context is what the business IS, not what it should say or how it should market. Brand strategy is `/brand`'s job.
2. **Channel-agnostic.** Don't write SEO recommendations, ad copy ideas, or content calendars. Those are downstream.
3. **Cite your sources.** When you research competitors or trends, note where the information came from.
4. **Ask, don't assume.** If you're not sure about something, ask. Don't fill gaps with generic text.
5. **Keep it lean.** These files should be scannable in 60 seconds. No filler, no fluff.
6. **One question at a time.** During interactive setup, ask one question per message. Synthesize as you go.

---

## Done

You are done when these files exist:

| File | Fast | Comprehensive |
|------|------|---------------|
| `context/business.md` | Required | Required |
| `context/market.md` | Required (basic) | Required (+ SEO audit) |
| `context/keywords.md` | Required (national only) | Required (+ geo CPC) |
| `context/personas/*.md` | 2 personas | 3-4 personas |
| `context/personas/INDEX.md` | Required | Required |

Stop. Present completion summary with file list and suggested next skill (/brand). Do not add unrequested deliverables.

---

## When to Use This Skill

- **First engagement with a new client/business** — run interactive setup
- **Client shares new information** — passive update
- **Before running `/seo`, `/ads`, `/brand`** — make sure context exists
- **Quarterly review** — refresh market intel and validate keyword themes
