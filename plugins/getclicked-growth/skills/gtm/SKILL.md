---
name: gtm
description: Build a go-to-market strategy using the Revealed GTM Prototype framework (Klement & White) — 9 decision worksheets covering ICP, JTBD, pricing, differentiation, demand narrative, channels, and risks.
allowed-tools: "Read Write Glob Grep mcp__notion__.* mcp__getclicked__.*"
---

<HARD-GATE>
Do NOT write GTM strategy until context/business.md, context/market.md, context/keywords.md,
AND context/personas/ exist. These are produced by the /context skill. If they don't exist,
invoke /context first. Do NOT write these files yourself.
</HARD-GATE>

# /gtm

Guide marketing leaders through building a GTM Prototype — the 9 Decision Worksheets from the Revealed framework. Buyer-first, grounded in Jobs to Be Done theory. Channels are ONE worksheet (#7), not the whole framework.

## References
- Golden examples: `docs/golden-examples/gtm-strategy.md`, `docs/golden-examples/gtm-channels.md`
- API patterns: `docs/reference/api-patterns.md`
- Notion guide: `docs/reference/notion-workspace.md`

## Input
- `context/business.md`, `context/keywords.md`, `context/personas/` — **required.** If missing, run `/context` first.
- `context/brand.md` — strongly preferred (positioning feeds Worksheets 4, 5, 6).
- `context/market.md`, `insights/`, `ads/budget.md`, `seo/analysis.md` — optional.

## Process

### Phase 1 — Discovery [~3 min]
**CHECKPOINT — Discovery (MANDATORY, never skip)**
Ask these one at a time. Wait for each answer before asking the next:
1. "How are you acquiring customers today?"
2. "What's working? What's not?"
3. "If I could fix one thing about your go-to-market in 90 days, what would it be?"
4. "How do you price — and do customers push back?"

Do NOT proceed to worksheets until you have answers to at least questions 1-3. These answers feed every worksheet.

Determine stage: Pre-PMF (<$10K MRR) → focus Worksheets 1-5. GTM-Fit (some revenue) → full prototype. Scaling → emphasis on Worksheets 7, 9.

### Phase 2 — Worksheets 1-5: The Value Side
1. **Who is buying?** ICP mapping from personas. Primary, Adjacent, Decision Maker, Stakeholders.
2. **What Jobs?** Reframe pain points as JTBD: Key Affordances, Anticipated Change (reduce/increase what), Catalysts.
3. **Pricing & packaging.** Value for money: cost of adoption vs doing nothing vs competitors.
4. **Better & different.** Competing Solutions, One-Good-Reason-to-Avoid (eliminate it), How Different, How Better.
5. **Hiring Process.** Answer 6 JTBD questions with evidence. Any "no" = won't hire. Be honest about gaps.

**CHECKPOINT — Value Side Review**
Before moving to demand-side worksheets, summarize the value side:
"Here's what I've got so far:
- **ICP:** [1-line]
- **Core Job:** [JTBD statement]
- **Better & Different:** [key differentiator]
- **Biggest hiring risk:** [from Worksheet 5]
Does this capture it? The demand strategy I build next depends on getting this right."
Wait for response.

### Phase 3 — Worksheets 6-9: The Demand Side
6. **Demand Gen Narrative.** 4-beat arc: world changing → today's solutions failing → new affordances → new goals. **Write `gtm/messaging.md`** with expanded narrative + per-persona + per-channel messaging.
7. **Where to catalyze demand.** Shopping Vectors (use `keyword_search_volume` for real search demand), Channels (match to ICP), Collateral. Be opinionated — recommend 2-3 primary channels with conviction.
8. **Winning pitch.** Website/deck structure that generates willingness to hire.
9. **Known risks.** Risk register: Risk, Type, Severity, Mitigation, Trigger.

### Phase 4 — Validation Roadmap
Write `gtm/validation-roadmap.md`: Value Testing (storyboards + acceptance criteria) → Demand Testing (Simulated Selection) → Build gates → Go to Market (90-day milestones) → Iteration triggers.

### Phase 5 — Write all files
**IMPORTANT: Split output into 3 files, not one monolithic doc.**
1. `gtm/strategy.md` — all 9 worksheets (the prototype)
2. `gtm/messaging.md` — Worksheet 6 expanded with persona + channel messaging
3. `gtm/validation-roadmap.md` — testing plan + launch milestones

## Output

| File | Required |
|------|----------|
| `gtm/strategy.md` | Yes |
| `gtm/messaging.md` | Yes |
| `gtm/validation-roadmap.md` | Yes |

**Notion:** Sync all 3 files to Go-to-Market section pages.

Write narrative with conviction. Tables only for genuinely tabular data (decision matrices, risk registers, collateral checklists). This is the Revealed framework — do NOT mix in Bullseye, Traction, or other channel-first frameworks.

## Quality check
- All 9 worksheets are present and grounded in real context data
- Worksheet 7 channels are backed by DataForSEO search demand, not guesses
- The 6 Hiring Questions (Worksheet 5) have honest answers — gaps flagged, not hidden

## Budgets
- Max 3 Read calls (golden examples + reference files)
- Max 2 MCP research calls (keyword_search_volume for Shopping Vectors, web_search for channel research)
- Max 2 Notion writes (strategy + messaging)
- Max 3K characters per Notion page section

## Next
After completing this skill, route based on Worksheet 7 findings:
If paid search was identified as a primary channel, invoke `/ads`:
"GTM strategy complete. Worksheet 7 identified paid search as primary. Building the campaign now."

Otherwise, offer based on recommended channels. Don't end the conversation here.
