---
name: brand
description: Define brand positioning, voice, messaging pillars, and guardrails using the Spendesk narrative model. Use when establishing how a brand should sound, writing a positioning doc, or aligning a team on messaging before a launch.
allowed-tools: "Read Write Glob Grep mcp__notion__.* mcp__getclicked__.*"
---

## Current state
!`[ -f context/brand.md ] && echo "UPDATING: Brand exists" || echo "CREATING: No brand yet"`
!`[ -f context/business.md ] && echo "Context available" || echo "WARNING: No business context — run /context first"`

<HARD-GATE>
Publish-path enforcement. This skill MUST commit via `publish_brand` — do NOT use
Write/Edit to produce `context/brand.md` or `context/brand-visual.json`. Generate
the content as a string in memory, then pass it as an argument to `publish_brand`.
The server handles the write. Write remains available only for `.pending-publish/*`
and `insights/*.md` scratch. See plugin CLAUDE.md "Multiplayer publish-path" HARD-GATE.
</HARD-GATE>

<HARD-GATE>
Do NOT write brand positioning or any context/brand.md content until context/business.md
AND context/market.md exist. These files are produced by the /context skill. If they
don't exist, invoke /context first. Do NOT write these files yourself — the skill's
DataForSEO validation, golden example formatting, and persona development process is
what makes the output valuable. Freehand context is a shortcut that produces worse
downstream work.
</HARD-GATE>

# /brand

Take the factual foundation from `/context` and make strategic decisions — positioning, voice, messaging, and guardrails. Output is `context/brand.md` (shared state all channel skills read). Visual identity lives in `/brandbook`, which this skill auto-chains to.

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

### Visual identity — delegated to `/brandbook`
This skill no longer writes `context/brand-visual.json`. Visual identity is the `/brandbook` skill's responsibility: it runs the vision-assisted extractor, uploads assets, and ships a hosted brand book at `brand.getclicked.ai/{slug}`. `/brand` owns the narrative; `/brandbook` owns the visual side. See the Next section — this skill auto-chains to `/brandbook`.

### If MCP research tools are unavailable
- Use `web_search` / WebSearch to find publicly available competitor and market data for positioning
- Mark any market metrics as UNVALIDATED (do not estimate or guess)
- Still produce `context/brand.md` — positioning, voice, and messaging are valuable even without exact metrics
- Tell the user: "I worked with publicly available data. Connect the research tools for deeper competitive intelligence."

## Output

| File | Required |
|------|----------|
| `context/brand.md` | Yes |
| `context/brand-visual.json` | NO — owned by `/brandbook`, not this skill. |

**Notion:** Sync `context/brand.md` to Brand & Positioning page.

## Commit via `publish_brand` (multiplayer — HARD-GATE)

Shared state is server-authoritative. The skill must commit through `publish_brand`, not raw file writes.

1. **At skill entry:** call `log_run_start(client_slug=<active>, skill="brand", plugin_version=<from plugin.json>)` and keep the returned `run_id`.
2. **Before committing**, read the caller's local cache manifest (in `.pending-publish/manifest.json` if present, otherwise absent = first write) to determine `parent_revision` per file path.
3. **Commit:** call `publish_brand(client_slug=<active>, brand_md=<content>, brand_visual_json=None, parent_revision={"context/brand.md": <int|null>}, run_id=<captured>)`. Pass `brand_visual_json=None` — visual identity is `/brandbook`'s concern.
4. **Handle responses:**
   - `{ok: true, revision, manifest}` → success. Update local cache manifest with new revision numbers. Proceed.
   - `{ok: false, reason: "stale_revision", current_revision, conflicts}` → another teammate published first. Fetch their version, offer the user a merge/override, retry with updated `parent_revision`.
   - `{ok: false, reason: "memory_violations", violations}` → address each violation (rewrite), retry. Cap at 3 attempts. Never bypass.
   - Server unreachable / tool error → write the payload to `.pending-publish/{op_id}.json` and tell the user: "Server unreachable — queued for retry on next session." Do NOT pretend the commit succeeded.
5. **At skill exit:** call `log_run_finish(run_id=<captured>, client_slug=<active>, status="completed" | "failed", outputs_manifest=<the manifest from publish_brand>)`.

Local `context/brand.md` / `context/brand-visual.json` remain scratch/cache — they mirror the server's authoritative copy but never precede it.

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
**Auto-chain to `/brandbook`** once the narrative is committed. `/brandbook` runs the vision-assisted extractor against the client's website, uploads assets, and ships the hosted brand-guidelines book. Tell the user: "Brand narrative is locked in — now building the brand book with your logo, colors, and fonts."

After `/brandbook` finishes, ask:
"Brand book is live. Ads or SEO — which matters more right now?"
If the user's original request targeted a specific skill, invoke that directly. If open-ended or "both," invoke `/ads` first (it feeds `/landing`).
