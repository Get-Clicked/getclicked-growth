# getclicked-growth Plugin Instructions

## Skill System Overview

The Growth Officer has 9 skills: start, context, brand, seo, ads, landing, optimize, experiment, gtm.
Skills are model-invoked — the Growth Officer decides when to use each one based on what the client needs.
Files persist, not agents. Every skill reads and writes markdown and CSV as shared state.
Canonical sequence: context -> brand -> ads/seo -> landing -> optimize -> experiment. GTM can run after context for distribution strategy.
Skills are composable but self-contained. Context files and personas are shared state across all skills.
Insights compound across sessions — each run builds on previous learnings.

## Skill Dependencies

| Skill | Requires |
|-------|----------|
| context | No dependencies (run first) |
| brand | context/business.md, context/market.md |
| ads | context/keywords.md |
| seo | context/keywords.md |
| landing | ads/ad-groups.json |
| optimize | ads/keywords.csv |
| experiment | context/business.md |
| gtm | context/business.md, context/market.md, context/keywords.md |
| start | No dependencies (onboarding flow) |

If a required file is missing, run the upstream skill first. Do not proceed with stale or absent inputs.

## First Contact

On session start, silently check if `context/business.md` exists.
- **If it doesn't exist:** This is a new user. Follow the `/start` skill automatically — no slash command needed. The user just talks, you take it from there.
- **If it exists:** This is a returning user. Greet briefly and ask what they want to work on, or pick up where they left off.

## Data Quality Rules

- DataForSEO: real metrics only. Every number must be actual pulled data or explicitly marked UNVALIDATED. No estimated ranges, no "approximately," no assumptions.
- Ad copy character limits: headlines <= 30 chars, descriptions <= 90 chars. Validate at generation time, never post-hoc.
- Cite sources for competitor research and market data. Link to the tool or endpoint that produced the number.
- Cross-skill keyword intelligence lives in insights/keyword-research.md — read before making DataForSEO calls to avoid re-pulling known dead ends.

## Security

- NEVER print API keys, tokens, client secrets, refresh tokens, customer IDs, or account IDs to terminal output.
- Load credentials from .env silently — read the file, do not echo values.
- Sessions may be recorded for demos. Treat all terminal output as potentially public.

## Data Access (DataForSEO + Tavily)

Skills need keyword data (DataForSEO) and web research (Tavily). Two paths, checked in order:

1. **MCP tools (Cowork default):** Use `keyword_search_volume`, `keyword_suggestions`, `ranked_keywords`, `serp_competitors`, `web_search`, `web_extract` tools directly. No credentials needed — server-side.
2. **BYOK (.env fallback):** Read `.env` for `DATAFORSEO_API_LOGIN` + `DATAFORSEO_API_PASSWORD` (or `DATAFORSEO_BASE64`) and `TAVILY_API_KEY`. Use curl.
3. **Neither:** STOP. Tell user: "I need DataForSEO + Tavily access. On Cowork, the founderbee-data server provides this. In Claude Code, add credentials to .env."

Check MCP tools first (try calling one). If it errors or isn't available, fall back to .env. Never silently skip data enrichment.

## Web Access

On Cowork, `WebFetch` may be blocked by network egress restrictions. Use this fallback chain:

1. **`web_extract` MCP tool** — server-side fetch, no egress restrictions. Use for scraping websites.
2. **`web_search` MCP tool** — server-side search. Use for competitor research, market data.
3. **`WebFetch` / `WebSearch`** — client-side, works in Claude Code. May be blocked on Cowork.

If all fail, ask the user to paste the page content or adjust their egress settings. Never stop a skill because a single fetch failed — work with what you have.

## Notion Integration

If Notion MCP is available (check .mcp.json for a Notion server entry):
- Dual-write all skill outputs: local files AND corresponding Notion pages.
- On first run, search for a "[Client Name] Workspace" page in Notion.
- If found, write skill outputs to the matching sections within that workspace.
- If not found or Notion is unavailable, continue with local files only.
- Never block on Notion. Local file output is always the baseline.
- Notion is the persistence layer for ephemeral environments (e.g., Cowork).
- On Cowork (ephemeral VMs), local files are lost between sessions. If Notion is NOT configured, warn the user once: "Your work will only persist in this session. Connect Notion to save across sessions."
- Never repeat this warning after the first time per session.

## Execution Modes

All skills default to **fast mode** — core deliverables only.
Comprehensive mode is opt-in: user says "deep dive", "full analysis", "go deep", or "thorough".
When running fast, announce what's skipped: "Running fast — [core deliverables]. Say 'go deep' for [extras]."

| Signal | Mode |
|--------|------|
| "quick", "fast", "just", "overview" | fast |
| "deep dive", "full", "thorough", "go deep" | comprehensive |
| No signal | **fast** (default) |

## Progress Signals

- **Before starting:** Announce the plan: "Building your ads campaign. 4 steps: keywords → copy → negatives → budget. ~10 minutes."
- **Between steps:** One-line status: "Keywords done (17 validated). Writing ad copy next."
- **After completing:** Summary with file list and suggested next skill.
- Never go silent for more than 2 minutes of tool calls without a status update.

## Notion Batching

- Complete ALL local file output first.
- Sync to Notion as a single pass at the end.
- Never interleave Notion writes with local work.
- Report "Synced N/M files to Notion" in completion summary.
