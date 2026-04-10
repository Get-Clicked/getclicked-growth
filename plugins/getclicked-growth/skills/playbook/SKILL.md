---
name: playbook
description: Synthesize all skill outputs into a structured GTM Prototype Playbook — the capstone deliverable covering 9 decision worksheets plus a validation roadmap. Use when the client wants a single strategic document that pulls everything together. Requires context, personas, and brand to exist.
allowed-tools: "Read Write Glob Grep mcp__notion__.* mcp__getclicked__.*"
---

<HARD-GATE>
Do NOT write the playbook until context/business.md, context/personas/, AND
context/brand.md exist. Business and personas are produced by /context, brand by /brand.
If any are missing, invoke the upstream skill first. The playbook synthesizes — it does
not generate source material.
</HARD-GATE>

# /playbook

Pull together everything other skills have produced and synthesize it into the Revealed GTM Prototype — 9 Decision Worksheets from Alan Klement & Eric White's framework. This is the capstone: one document that captures every critical go-to-market decision. The playbook gets richer as more skills have run.

## References
- Golden example: `docs/golden-examples/playbook.md`
- Notion guide: `docs/reference/notion-workspace.md`

## Input
- `context/business.md`, `context/personas/`, `context/brand.md` — **required.** If missing, run upstream skills first.
- All other skill outputs are optional but enrich specific worksheets:
  - `context/market.md` + `compete/` = WS 4, 7. `context/keywords.md` + `ads/` + `seo/` = WS 7. `gtm/` = WS 6, 7, 9. `landing/` = WS 8. `experiments/` + `optimize/` = WS 9 + Validation Roadmap.

## Process

### 1. Inventory (~30s)
Read all available skill outputs. Build a coverage map: which worksheets are strong (data exists), which are draft (data missing). Present the map to the user.

### 2. Gap-fill Q&A (~3 min)
Ask 3-4 questions to fill gaps. Always ask about pricing (WS 3): pricing model, tiers/packages, switching costs, de-risking strategies. Ask about buying committee if B2B. Ask about risks if no experiment/GTM data exists. One question at a time. Comprehensive mode adds JTBD deep dive and full risk workshop.

### 3. Synthesis (~4 min)
Write `gtm/playbook.md`. For each worksheet, pull from identified sources, reframe into Revealed structure, add `> Source:` citation, mark incomplete sections `[DRAFT -- run /skill to enrich]`.

**Worksheet-to-source mapping:**
1. **Who's buying** = personas/ -> ICP map
2. **What Jobs** = business.md + personas/ -> JTBD (Affordances, Anticipated Change, Catalysts)
3. **Pricing** = user Q&A -> Value for Money analysis
4. **Better & different** = market.md + brand.md -> Competing Solutions, One-Good-Reason-to-Avoid
5. **Hiring process** = brand.md + personas/ -> 6 JTBD hiring questions
6. **Demand narrative** = brand.md + messaging.md -> 4-beat arc (world changing -> old failing -> new affordances -> new goals)
7. **Catalyze demand** = keywords.md + ads/ + seo/ -> Shopping Vectors, Channels, Collateral
8. **Winning pitch** = landing/ + brand.md -> Simulated Selection structure
9. **Known risks** = experiments/ + optimize/ + Q&A -> Risk Register
+ **Validation Roadmap** = experiments/ + validation-roadmap.md + optimize/

**Design principle:** Synthesis, not duplication. Reframe existing data. Never regenerate what already exists.

### 4. Coverage report
Present: strong sections, draft sections (with which skill to run), suggested next steps.

## Output

| File | Required |
|------|----------|
| `gtm/playbook.md` | Yes — all 9 worksheets + validation roadmap |

**Notion:** Sync `gtm/playbook.md` to GTM > Playbook page.

**Inline fallback:** Executive thesis (1 sentence), 9 numbered worksheets (narrative, not tables), source citations per section, DRAFT markers with specific skill to run, validation roadmap.

## Quality check
- Every section cites its source with `> Source:` line
- Incomplete sections marked `[DRAFT -- run /X to enrich]` with specific skill
- Pricing section comes from user Q&A, never inferred

## Budgets
- Max 3 Read calls (golden example + all context/skill files)
- Max 0 MCP research calls (synthesis only)
- Max 1 Notion write
- Max 3K characters per Notion page section

## Next
This is the capstone. Present the coverage report and suggest which specific skills
to run to strengthen draft sections. For each `[DRAFT]` section, name the skill:
"Worksheet 7 is draft — run /ads to fill it with real campaign data."
