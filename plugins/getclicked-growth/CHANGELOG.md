# Changelog

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
- MCP server renamed from `founderbee-data` to `getclicked-research`.
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
