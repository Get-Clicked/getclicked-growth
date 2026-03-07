# Changelog

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
