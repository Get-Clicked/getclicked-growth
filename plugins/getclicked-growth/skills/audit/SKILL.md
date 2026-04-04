---
name: audit
description: Audit any website for production readiness — broken links, content gaps, responsive design, and technical SEO. Use when a site is ready for QA before launch or after changes.
allowed-tools: "Read Write Glob Grep mcp__notion__.* mcp__getclicked-research__.*"
---

# /audit

Crawl any public URL, find what's broken, flag what's missing, and produce a prioritized punch list. Works on any website — not just sites built by getClicked skills. Two modes: fast (homepage + 3 pages) and comprehensive (up to 25 pages).

## References
- Golden example: `docs/golden-examples/audit-report.md`
- Notion guide: `docs/reference/notion-workspace.md`

## Input
- **Target URL** — required. Ask if not provided.
- `context/brand.md` — optional (enables voice consistency checks)
- `context/business.md` — optional (enables business info accuracy checks)
- `landing/pages/` — optional (enables spec-vs-reality comparison, comprehensive only)

## Process

### 1. Discovery
Normalize the URL. Fetch homepage via `web_extract` MCP tool. Extract internal links from nav, footer, CTAs. Check `/sitemap.xml` and `/robots.txt`. Fast mode: homepage + up to 3 high-value pages. Comprehensive: up to 25 pages from sitemap + nav.

### 2. Link check
For each audited page, classify every link: Broken (4xx/5xx) = Critical. Placeholder (`#`, `javascript:void(0)`) = Critical. Redirect (3xx) = Important. External broken = Important. Write `audit/links.md`.

### 3. Content check
On every page: placeholder text (lorem ipsum, "coming soon"), heading hierarchy (skipped levels, multiple H1s), missing sections (no CTA, empty areas), thin content (< 100 words). Comprehensive adds: alt text audit, legal pages, brand consistency vs brand.md, spec-vs-reality against landing specs.

### 4. Technical SEO
Per page: title tag (exists, 30-60 chars), meta description (120-155 chars), H1 (exactly one), OG tags, canonical URL, robots.txt, sitemap. Comprehensive adds: structured data, HTTPS check. Write `audit/technical-seo.md`.

### 5. Synthesis
Merge all findings into `audit/report.md`. Write it like a brief from a trusted colleague — plain language, specific fixes, priority order. Three sections: "Fix before launch" (critical), "Fix this week" (important), "Nice to have." No tables, no severity labels — the sections ARE the priority. Max 30 bullets; group small issues.

**Voice rules:** Write to a marketing lead, not a developer. Every bullet is self-contained. Say what's wrong AND what to do. No issue IDs or category tags.

## Output

| File | Required |
|------|----------|
| `audit/report.md` | Yes — the client deliverable |
| `audit/links.md` | Yes — link health inventory |
| `audit/technical-seo.md` | Yes — meta, schema, robots, sitemap |

**Notion:** Sync `audit/report.md` to Audit > Site Review page (single narrative memo: bottom line, fix now, fix this week, can wait).

**Inline fallback:** Three priority tiers — Critical (blocks launch), Important (fix this week), Nice-to-have (backlog). Each finding: what's wrong, where, why it matters, how to fix.

## Quality check
- No false positives — if you can't verify a link is broken, say so
- Every finding includes a specific fix, not vague advice ("Add alt text to hero image on /about" not "improve accessibility")
- Fast mode catches 80% of issues — don't upsell comprehensive unless the site is large

## Budgets
- Max 2 Read calls (golden example + context files)
- No MCP research calls needed (just web_extract for crawling)
- Max 1 Notion write
- Max 3K characters per Notion page section

## Next
Suggest fixing the issues or running `/seo` — "Site review is done. Want me to fix the SEO metadata, or run a full organic search analysis?"
