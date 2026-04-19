---
name: context
description: Build foundational business context — company profile, market landscape, validated keyword themes, and audience personas with real DataForSEO metrics. Use when onboarding a new client, starting a marketing engagement, or when other skills need context files.
allowed-tools: "Read Write Glob Grep mcp__notion__.* mcp__getclicked__.* WebFetch WebSearch"
---

## Current state
!`[ -f context/business.md ] && echo "RETURNING: Context exists — read existing files before researching" || echo "NEW: No context yet — start fresh research"`

# /context

Build and maintain the foundational knowledge base that every downstream skill reads from. Four phases: business profile, market intel, keyword validation, and personas. Facts only — no brand strategy, no channel tactics.

## References
- Golden examples: `docs/golden-examples/context-business.md`, `docs/golden-examples/context-market.md`, `docs/golden-examples/context-keywords.md`, `docs/golden-examples/context-persona.md`
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
Wait for response. Adjust personas if needed, then continue to next skill.

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

**Notion:** Sync each file after writing — see Notion guide for page mapping.

Write narrative, not spreadsheets. Business page reads like an investment memo. Market page reads like a strategy brief. Keywords page uses tables (genuinely tabular) with narrative interpretation above each. Personas are characters with tension and motivation, not demographic spec sheets.

## Quality check
- Every keyword metric is real DataForSEO data or marked UNVALIDATED
- Business facts are sourced from the user or scraped site — nothing invented
- Personas use the customer's own language, not marketing-speak

## Budgets
- Max 3 Read calls (golden examples + reference files)
- Max 5 MCP research calls (keyword_search_volume, ranked_keywords, web_extract, web_search)
- Max 4 Notion writes (business, market, keywords, personas)
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
