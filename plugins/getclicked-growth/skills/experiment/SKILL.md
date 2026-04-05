---
name: experiment
description: Design hypothesis-driven marketing experiments with clear success criteria, track them through a structured lifecycle, and capture learnings that compound across sessions. Use when testing a new channel, validating a messaging angle, deciding between landing page variants, or when optimize flags something worth A/B testing.
allowed-tools: "Read Write Glob Grep mcp__notion__.* mcp__getclicked__.*"
---

# /experiment

Turn marketing actions into testable hypotheses with clear success criteria, track them through a lifecycle, and capture learnings that compound across sessions. Two modes: Launch (no campaign yet — the experiment drives channel execution) and Optimization (campaign running — frame changes as isolated tests).

## References
- Golden example: `docs/golden-examples/experiment.md`
- API patterns: `docs/reference/api-patterns.md`
- Notion guide: `docs/reference/notion-workspace.md`

## Input
- `context/business.md` — **required.** If missing, run `/context` first.
- `context/personas/` — optional but valuable (experiments target specific personas)
- `insights/` — read before designing (don't re-test what we already know)
- `optimize/report.md` — check if `/optimize` proposed experiments
- Channel deliverables (`ads/`, `seo/`, `landing/`) — optional. Launch mode: these don't exist yet. Optimization mode: experiments link to existing deliverables.

## Process

### 1. Determine mode
Existing campaign AND experiment is about that campaign = Optimization mode. Everything else = Launch mode.

### 2. Frame the hypothesis
Structure as: **If** [action], **then** [outcome], **because** [reasoning]. Bad: "If we run ads, we'll get leads." Good: "If we position X as Y and target Z via Google Ads on [keywords], then we'll generate demo requests at <$150 CPA because [insight]."

### 3. Define success criteria
Pre-commit three thresholds before launch:
- **WIN:** primary metric + target + timeframe + minimum sample size
- **KILL:** metric + threshold after spend/time that triggers early stop
- **PROTECT:** metric we can't hurt + floor value

### 4. Design the test
**Launch mode:** Map channel stack — which skills run, which ad groups, which landing pages, budget per persona. **Optimization mode:** Link to specific existing deliverables (ad groups, content, pages). Isolate one variable.

### 5. Write experiment file
Assign next number from `experiments/INDEX.md`. Write `experiments/EXP-NNN-{slug}.md` with: metadata table, the bet (1 sentence), hypothesis, success criteria table, conversion path, persona cards, budget + timeline, pre-committed decisions (what we do if it wins, partially wins, or fails).

### 6. Update index
Update `experiments/INDEX.md` with new row: #, title, status, channel, persona, dates.

### Recording results (when user shares performance data)
Update experiment file Results section. Compare to success criteria — call it Win, Loss, or Inconclusive. Write learnings to `insights/{topic}-{date}.md`. Update `insights/INDEX.md` and `insights/channel-learnings.md`.

**Rules:** Every keyword must cite actual DataForSEO metrics or be marked UNVALIDATED. One variable at a time. Reflection is mandatory on completion. Inconclusive is a valid outcome.

## Output

| File | Required |
|------|----------|
| `experiments/EXP-NNN-{slug}.md` | Yes |
| `experiments/INDEX.md` | Yes |
| `insights/{topic}-{date}.md` | Only on experiment completion |

**Notion:** Sync experiment file to Experiments section as child page. Update INDEX page.

**Inline fallback:** Hypothesis (if/then/because), success criteria (WIN/KILL/PROTECT table), conversion path, budget, timeline, pre-committed decisions.

## Quality check
- Hypothesis is falsifiable with a specific metric and threshold, not "see what happens"
- Success criteria are set before launch, not retroactively
- Every keyword cites real DataForSEO data or is explicitly marked UNVALIDATED

## Budgets
- Max 3 Read calls (golden example + context + insights)
- Max 2 MCP research calls (keyword validation)
- Max 2 Notion writes (experiment page + INDEX)
- Max 3K characters per Notion page section

## Next
Suggest running the experiment or `/optimize` to analyze results — "Experiment is designed. Ready to launch it, or want to check how existing campaigns are performing first?"
