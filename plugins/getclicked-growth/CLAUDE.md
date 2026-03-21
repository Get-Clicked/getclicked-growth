# getclicked-growth Plugin Instructions

## Skill System Overview

The Growth Officer has 11 skills: start, context, brand, seo, ads, landing, optimize, audit, experiment, gtm, playbook.
Skills are model-invoked — the Growth Officer decides when to use each one based on what the client needs.
Files persist, not agents. Every skill reads and writes markdown and CSV as shared state.
Canonical sequence: context -> brand -> ads/seo -> landing -> optimize -> experiment. GTM can run after context for distribution strategy. Playbook is the capstone — synthesizes all skill outputs into a single GTM Prototype document. Runs after any combination of skills.
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
| playbook | context/business.md, context/personas/, context/brand.md |
| audit | No dependencies (just a URL) |
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

## MCP Servers

Two servers, different purposes:

### getclicked-research (keyword + web data)
Tools: `keyword_search_volume`, `keyword_suggestions`, `ranked_keywords`, `serp_competitors`, `web_search`, `web_extract`
Ships with the plugin. No setup needed on Cowork. Free tier has daily limits (see Tiering below). Authenticate via OAuth (Google SSO) for unlimited access.
BYOK fallback: Claude Code users can add `DATAFORSEO_*` + `TAVILY_API_KEY` to `.env` and bypass the hosted server.
Check MCP tools first (try calling one). If it errors or isn't available, fall back to `.env`. Never silently skip data enrichment.

### getclicked-mcp (live Google data)
Tools: `google_ads_accounts`, `google_ads_campaign_performance`, `ga4_properties`, `ga4_report`, `gsc_sites`, `gsc_queries`
NOT in plugin.json yet (Cowork OAuth bugs). Available on Claude Code via `.mcp.json`.
Required for: `/optimize` (live ad performance), `/seo` dashboard (live GSC rankings).
If these tools aren't available: skills still work but use DataForSEO estimates instead of live data. Tell the user: "I can pull your actual Google Ads and Search Console data if you connect your Google account. Want to set that up?"

### Routing
- Keyword research, competitor data, web scraping → `getclicked-research` tools
- Live campaign performance, actual rankings, GA4 attribution → `getclicked-mcp` tools
- If a skill needs Google data and it's not available, fall back gracefully to research-only mode. Never block.

## Web Access

On Cowork, `WebFetch` may be blocked by network egress restrictions. Use this fallback chain:

1. **`web_extract` MCP tool** — server-side fetch, no egress restrictions. Use for scraping websites.
2. **`web_search` MCP tool** — server-side search. Use for competitor research, market data.
3. **`WebFetch` / `WebSearch`** — client-side, works in Claude Code. May be blocked on Cowork.

If all fail, ask the user to paste the page content or adjust their egress settings. Never stop a skill because a single fetch failed — work with what you have.

## Tiering

The hosted MCP server has two tiers:

- **Free (unauthenticated):** Daily limits on keyword and competitor tools. No account needed.
- **Unlimited (authenticated via OAuth):** Sign in with Google SSO through Supabase. All limits removed.

**Free limits (per day):**
- keyword_search_volume: 5
- keyword_suggestions: 5
- ranked_keywords: 10
- serp_competitors: 10
- web_search: 100
- web_extract: 100

When a tool call hits the limit, it returns a ToolError. Handle this gracefully:
1. Tell the user what happened (X of Y calls used today)
2. Lead with authentication: "Sign in to unlock unlimited access — visit getclicked.ai/upgrade or run /mcp in chat to connect your account"
3. Mention BYOK: "Or add your own DataForSEO/Tavily keys to .env — see the README"
4. Offer to save progress: "I'll save where we are. Pick up tomorrow when the quota resets."

Never make the user feel blocked. Always offer a path forward.

## Notion Integration

If Notion MCP is available (check by trying `notion-search` — works on both Claude Code and Cowork):
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
