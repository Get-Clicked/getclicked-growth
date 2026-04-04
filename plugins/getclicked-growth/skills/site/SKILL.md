---
name: site
description: Edit website content and SEO metadata through natural language — update headlines, fix meta titles, create CMS pages, deploy landing page variants, and publish changes via Webflow. Use when updating site copy after a brand refresh, deploying landing pages from /landing specs, fixing SEO issues flagged by /audit, or managing A/B test variants.
allowed-tools: "Read Write Glob Grep mcp__notion__.* mcp__getclicked-research__.* mcp__webflow__.*"
---

# /site

Read a live Webflow site, brainstorm data-grounded copy changes, and push them — headlines, body text, SEO metadata, CMS items. Never touch layout, styles, or page structure. Content only. Subcommands: connect, scan, edit, seo, create, build, design, domains.

## References
- Notion guide: `docs/reference/notion-workspace.md`

## Input
- **Webflow MCP connector** — required. If unavailable, guide setup (Claude Code: add to `.mcp.json`, Cowork: Settings > Connectors).
- `context/brand.md`, `seo/keywords.csv`, `landing/pages/`, `ads/ad-groups.json`, `context/personas/`, `insights/`, `compete/` — all optional but make every edit data-grounded.

## Process

### Three-gate safety model (all workflows)
1. **Brainstorm:** Read target page + all strategy files. Propose 2-3 options with data-backed reasoning. Collaborate with user.
2. **Stage:** User approves. Show final diff. Push changes (NOT published). Report what changed.
3. **Publish:** User explicitly says "publish." Summarize staged changes, ask final confirmation, publish.

Never auto-publish. Never combine Stage and Publish.

### Subcommands

**`/site connect`** — First-time setup. Verify Webflow MCP, list sites, store site ID in `.active-webflow-site`, provide Designer Bridge link for text editing: `https://{shortName}.design.webflow.com/?app=dc8209c65e3ec02254d15275ca056539c89f6d15741893a0adf29ad6f381eb99`

**`/site scan`** — Content map. List all pages + metadata. Full element read on top 10 pages. Save `site/content-map.md`. Identify gaps: missing SEO titles, empty meta descriptions, weak headlines.

**`/site edit`** — Core workflow. User describes change. Ensure Designer Bridge open for static text. Read elements + strategy files. Three-gate flow using `element_tool > set_text`.

**`/site seo`** — Batch SEO optimization. Read `seo/keywords.csv` for validated keywords. Scan page metadata. Present changeset table (page, field, current, proposed, keyword + volume). Three-gate flow using `data_pages_tool > update_page_settings`.

**`/site create`** — New CMS items. Check landing specs if available. Map content to collection fields. Three-gate flow using `data_cms_tool > create_collection_items`.

**`/site build`** — Deploy landing pages from `/landing` specs to Webflow CMS. First-time: guide collection creation + field setup + template binding. Per page: map spec to CMS fields, three-gate flow. Variants: create another CMS item with different copy for A/B testing.

**`/site design`** — Map landing page spec sections to Relume Library components. Output design brief to `landing/design/{slug}-design-brief.md`. Principles: lightest weight wins, split layouts for heroes, no carousels, 3 items max per row.

**`/site domains`** — Domain naming. Rules: under 15 chars, no hyphens, no misspellings, .com preferred, spellable after hearing once. Check availability via Name.com API (`/core/v1/` paths only). Kill premium domains.

### Smart routing (no subcommand)
"Update headline" = edit. "Fix SEO" = seo. "Deploy landing pages" = build. "What's on my site?" = scan. "I need a domain" = domains.

### Tools to use
`data_pages_tool` (list/read/update pages), `element_tool` (set_text — requires Designer Bridge), `data_cms_tool` (CMS CRUD + publish), `data_sites_tool` (list sites, publish). **Never use:** `element_builder`, `style_tool`, `variable_tool`, `de_component_tool`.

### Data grounding
Never write copy that isn't: (a) verbatim from user, or (b) generated from validated data (keywords, brand voice, persona language, performance insights). If data doesn't exist, say so and suggest the upstream skill.

## Output

| File | Required |
|------|----------|
| `site/content-map.md` | Only from `/site scan` |
| `site/changelog.md` | After any edit/seo/build operation |

**Notion:** Sync content-map and changelog to Site section.

**Inline fallback:** Changelog table per page: element, old value, new value, status (staged/published).

## Quality check
- Three-gate model followed — no auto-publishing, no skipped brainstorm
- All generated copy validated against brand.md (if it exists)
- SEO edits use validated keywords from seo/keywords.csv, not guesses

## Budgets
- Max 3 Read calls (context + brand + landing specs)
- Max 3 MCP research calls (web_extract for brand extraction)
- Max 2 Notion writes (content-map + changelog)
- Max 3K characters per Notion page section

## Next
Context-dependent: after scan, suggest fixing issues. After build, suggest running `/audit` to verify. After seo, suggest `/audit` for a full check.
