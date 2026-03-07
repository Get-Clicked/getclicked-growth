# getclicked-growth Plugin Instructions

## Skill System Overview

The Growth Officer has 8 skills: start, context, brand, seo, ads, landing, optimize, experiment.
Skills are model-invoked — the Growth Officer decides when to use each one based on what the client needs.
Files persist, not agents. Every skill reads and writes markdown and CSV as shared state.
Canonical sequence: context -> brand -> ads/seo -> landing -> optimize -> experiment.
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
| start | No dependencies (onboarding flow) |

If a required file is missing, run the upstream skill first. Do not proceed with stale or absent inputs.

## Data Quality Rules

- DataForSEO: real metrics only. Every number must be actual pulled data or explicitly marked UNVALIDATED. No estimated ranges, no "approximately," no assumptions.
- Ad copy character limits: headlines <= 30 chars, descriptions <= 90 chars. Validate at generation time, never post-hoc.
- Cite sources for competitor research and market data. Link to the tool or endpoint that produced the number.
- Cross-skill keyword intelligence lives in insights/keyword-research.md — read before making DataForSEO calls to avoid re-pulling known dead ends.

## Security

- NEVER print API keys, tokens, client secrets, refresh tokens, customer IDs, or account IDs to terminal output.
- Load credentials from .env silently — read the file, do not echo values.
- Sessions may be recorded for demos. Treat all terminal output as potentially public.

## BYOK Fallback

When hosted MCP tools are not available, check .env for credentials:
- DATAFORSEO_API_LOGIN + DATAFORSEO_API_PASSWORD (or DATAFORSEO_BASE64)
- TAVILY_API_KEY

Use curl or direct HTTP calls to reach APIs when MCP is unavailable.
If neither MCP nor .env credentials exist, STOP and tell the user exactly which credentials are needed and where to set them.
Do not silently skip data enrichment — missing data must be surfaced, not worked around.

## Notion Integration

If Notion MCP is available (check .mcp.json for a Notion server entry):
- Dual-write all skill outputs: local files AND corresponding Notion pages.
- On first run, search for a "[Client Name] Workspace" page in Notion.
- If found, write skill outputs to the matching sections within that workspace.
- If not found or Notion is unavailable, continue with local files only.
- Never block on Notion. Local file output is always the baseline.
- Notion is the persistence layer for ephemeral environments (e.g., Cowork).
