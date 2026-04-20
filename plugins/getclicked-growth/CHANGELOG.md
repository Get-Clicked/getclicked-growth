# Changelog

## [0.18.3] - 2026-04-20

### Added
- Pending Publish Queue (BEE-361): HARD-GATE in CLAUDE.md defines the queue format (`pending_publish/*.json`) and drain rules. When a `publish_*` call fails transiently (network / 5xx / timeout / validator unavailable), the agent writes the full payload to the queue. Before any new publish, drain FIFO first. At session start, hydration is followed by queue drain. Never write canonical paths freehand as a workaround. Cowork ephemeral VMs can lose the queue between sessions — agent saves an `open_question` memory so the next session at least knows about the gap. Persistent server-side queue deferred to BEE-368 if needed.

## [0.18.2] - 2026-04-20

### Added
- Notion Mirror (BEE-360): every successful `publish_*` response now includes a `notion_hint` object. Plugin CLAUDE.md adds a HARD-GATE requiring the agent to mirror each page to the workspace's Notion in the same turn, using the user's Notion MCP connector (client-side auth — no server-side integration or `NOTION_API_KEY` required). First publish per file path: agent creates a child page under the workspace root and calls `set_notion_page` to register the mapping. Subsequent publishes update in place. Graceful when the connector is absent or `workspace_url` is null.

### Infrastructure (research MCP)
- New Supabase migration `010_notion_page_registry.sql` — `(workspace_id, file_path) -> notion_page_id`.
- New MCP tools: `set_notion_page`, `get_notion_pages` (both `require_member`-gated).
- `_publish()` returns `notion_hint` with per-file `{file_path, notion_page_id, suggested_title, content, action}` and top-level `workspace_url` + `instructions`.

## [0.18.1] - 2026-04-20

### Added
- Session Hydration Step 0: agent now resolves the active workspace from `get_account_status().workspace_memberships` on every session start (both Claude Code and Cowork), instead of inferring "no active workspace" from a stale SESSION RESUME block. Auto-hydrates memory + activity once the workspace is resolved, and pulls published content before doing fresh research. Requires research-MCP update (also 2026-04-20) that adds `caller_email` + `workspace_memberships` to the `get_account_status` response.

## [0.4.0] - 2026-03-20

### Added
- Freemium tiering: per-tool daily limits for free users, API key auth for paid users.
- `Authorization: Bearer ${GETCLICKED_API_KEY}` header in plugin.json for paid tier.
- PostHog analytics: session_start, tool_call, free_limit_hit, invalid_key events.
- Tiering section in CLAUDE.md with graceful wall-message handling guidance.
- Post-onboarding upgrade mention in `/start` skill.

### Changed
- `RateLimitMiddleware` replaced by `TieringMiddleware` (per-tool limits, API key auth, burst limiting).
- README rewritten with Free Tier / Upgrade / Developers: BYOK sections. Skill count updated to 11.
- Server instructions updated with upgrade URL.

## [0.3.1] - 2026-03-19

### Added
- `/playbook` skill — capstone GTM Prototype deliverable. Synthesizes all skill outputs into 9 Revealed worksheets + validation roadmap.
- `/audit` skill — website QA: broken links, content gaps, responsive design, technical SEO.
- `/publish` command for syncing monorepo plugin to public repo with JSON validation.
- Context persona template: optional Buying Role (B2B) field.

### Changed
- `mcp.json` removed — MCP server config inlined into `plugin.json`.
- Synthesis Layer added to architecture diagram.
- CLAUDE.md updated to reflect 11 skills.

### Fixed
- MCP server rate limiter rewritten as FastMCP middleware (was Starlette — wrong layer).

## [0.3.0] - 2026-03-09

### Changed
- Marketplace packaging fixes: `repository`, `license`, `keywords`, `metadata` fields synced.
- Version field added to marketplace plugin entry (required for relative-path plugins).
- Repo URLs corrected to `Get-Clicked/getclicked-growth`.

## [0.2.0] - 2026-03-07

### Added
- MCP-first data access: skills use hosted MCP server tools before falling back to BYOK .env credentials.
- Cowork session persistence via Notion integration with local file fallback.
- Auto-onboarding: `/start` runs automatically when no context files exist.
- Session resume: detects completed skills on session start.

### Changed
- MCP server renamed from `founderbee-data` to `getclicked`.
- Trailing slash added to MCP endpoint URL (required by FastMCP HTTP transport).
- Plugin restructured as marketplace with nested plugin directory.

## [0.1.0] - 2026-03-06

### Added
- 9 skills: start, context, brand, ads, seo, landing, optimize, experiment, gtm
- Growth Officer agent with skill routing, auto-chaining, and time estimates
- Fast/comprehensive execution modes (fast is default — core deliverables only)
- Progress signals between major steps (never silent >2 min)
- Done checklists on every skill to prevent scope creep
- Notion integration with local file fallback
- Session resume (detects completed skills on session start)
- Health check (validates DataForSEO, Tavily, Notion credentials)
- BYOK credential support (DataForSEO, Tavily via .env)
- Cross-skill keyword intelligence (insights/keyword-research.md)
- Insight compounding across sessions (insights/ read by all skills)
- Landing page conversion research reference data (REFERENCE.md)

### Skills Detail
- `/start` — Guided onboarding, auto-delegates to /context
- `/context` — Business facts, market intel (competitor SEO audit via DataForSEO Labs), keyword themes (DataForSEO-validated), personas
- `/brand` — Positioning statement, voice attributes, messaging pillars, guardrails
- `/ads` — Full Google Ads campaign: keywords, RSA copy (character-validated), negatives (conflict-checked), budget, forecast, Google Ads Editor export CSVs, campaign settings, Gamma presentation prompt
- `/seo` — Site audit, keyword research (80-150 keywords), competitive analysis, content ideas
- `/landing` — Page audit, PAS-framework page specs matched to ad groups, geo pages, A/B variants, dev/design brief
- `/optimize` — Campaign performance analysis with maturity-gated steps, plan vs actual, search term audit, keyword health, copy refresh, landing page correlation
- `/experiment` — Hypothesis-driven marketing (launch + optimization modes), lifecycle tracking, learning extraction to insights/
- `/gtm` — Bullseye channel prioritization, experiment designs per channel, 90-day plan, messaging framework, competitive distribution map
