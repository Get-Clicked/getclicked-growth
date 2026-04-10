---
name: brand
description: Define brand positioning, voice, messaging pillars, and guardrails using the Spendesk narrative model. Use when establishing how a brand should sound, writing a positioning doc, or aligning a team on messaging before a launch.
allowed-tools: "Read Write Glob Grep mcp__notion__.* mcp__getclicked__.*"
---

## Current state
!`[ -f context/brand.md ] && echo "UPDATING: Brand exists" || echo "CREATING: No brand yet"`
!`[ -f context/business.md ] && echo "Context available" || echo "WARNING: No business context — run /context first"`

<HARD-GATE>
Do NOT write brand positioning or any context/brand.md content until context/business.md
AND context/market.md exist. These files are produced by the /context skill. If they
don't exist, invoke /context first. Do NOT write these files yourself — the skill's
DataForSEO validation, golden example formatting, and persona development process is
what makes the output valuable. Freehand context is a shortcut that produces worse
downstream work.
</HARD-GATE>

# /brand

Take the factual foundation from `/context` and make strategic decisions — positioning, voice, messaging, and guardrails. Output is `context/brand.md` (shared state all channel skills read) + `context/brand-visual.json` (visual identity for landing pages and design).

## References
- Golden example: `docs/golden-examples/brand.md`
- Notion guide: `docs/reference/notion-workspace.md`

## Input
- `context/business.md` — **required.** If missing, run `/context` first.
- `context/market.md` — **required.** Competitive context shapes positioning.
- `context/keywords.md`, `context/personas/`, `insights/`, `compete/gaps.md` — optional, read all available.

## Process

### Discovery (zero questions if context has enough info; max 1 question)
Read all context files. If positioning, voice, and competitive differentiation are clear from the data, skip questions entirely and write the doc. If one critical gap exists (e.g., no sense of brand personality), ask ONE question: "How should your brand feel to someone encountering it for the first time?"

### Write `context/brand.md`
Follow the Spendesk narrative model — story-first, personality, conviction. Every section is prose unless a table genuinely earns its place.

**Section flow (7 sections):**
1. **The problem we solve.** 2-3 paragraphs. Make the reader feel the gap. End with bold positioning line.
2. **Who we solve it for.** Each persona as a character paragraph — role, daily pain, trigger to buy.
3. **How we solve it better.** Product paragraph, pull-quote positioning line, conversational "vs. [Competitor]" comparisons.
4. **How we sound.** Voice as bullet pairs (do this / not that). Tone-by-channel and forbidden language in `<details>` toggles.
5. **What we say and when.** Each messaging pillar as H3 with bold pull-quote, supporting paragraph, "use when" note.
6. **When they push back.** Each objection bold, response as conversational paragraph in brand voice.
7. **The rules.** Guardrails as clean bulleted list.

**Do NOT produce:** positioning canvas tables, tiered boilerplate, messaging pillar tables, competitive messaging tables.

**CHECKPOINT — Brand Voice**
After writing brand.md, present the core positioning:
"Here's how I'd position you:

**[Bold positioning line from section 1]**

Voice: [2-3 do/don't pairs from section 4]

Does this sound like you? Anything feel off?"
Wait for response. Rewrite affected sections of brand.md if needed before extracting visual identity.

### Extract visual identity
After writing brand.md, extract visual brand identity from the client's website using `web_extract`. Write `context/brand-visual.json` with colors, typography, logo, buttons, layout tokens. Skip if file already exists and user hasn't asked for a refresh.

If `web_extract` is unavailable for visual identity extraction, skip `brand-visual.json` and note it was skipped. The brand positioning doc is the core deliverable — visual tokens can be extracted later.

### If MCP research tools are unavailable
- Use `web_search` / WebSearch to find publicly available competitor and market data for positioning
- Mark any market metrics as UNVALIDATED (do not estimate or guess)
- Still produce `context/brand.md` — positioning, voice, and messaging are valuable even without exact metrics
- Tell the user: "I worked with publicly available data. Connect the research tools for deeper competitive intelligence."

## Output

| File | Required |
|------|----------|
| `context/brand.md` | Yes |
| `context/brand-visual.json` | Conditional (skip if web_extract unavailable) |

**Notion:** Sync `context/brand.md` to Brand & Positioning page.

## Quality check
- Every positioning decision traces to facts in context files — no invented differentiators
- Voice examples are specific ("Say X instead of Y"), not abstract ("Be authentic")
- Brand fidelity: every generated page must pass "could this be a subpage on their actual site?"

## Budgets
- Max 2 Read calls (golden example + context files)
- Max 1 MCP research call (web_extract for visual identity)
- Max 1 Notion write
- Max 3K characters per Notion page section

## Next
After completing this skill, ask which channel matters more right now:
"Brand positioning is locked in. Ads or SEO — which matters more right now?"

If the user's original request targeted a specific skill (e.g., "build me ads"), invoke that skill directly.
If the user gives an open-ended answer or says "both," invoke `/ads` first (it feeds `/landing`).
Do not end the conversation here — the user hired an agency, not a one-shot consultant.
