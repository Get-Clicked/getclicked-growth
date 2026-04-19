---
name: landing
description: Create landing page specs aligned to ad groups — one page per ad group with matched messaging, PAS framework copy, CTAs, and conversion optimization. Use when ads exist and need landing pages, or building A/B test variants.
allowed-tools: "Read Write Glob Grep Bash mcp__notion__.* mcp__getclicked__.*"
---

## Current state
!`[ -f ads/ad-groups.json ] && echo "Ad groups available — build pages to match" || echo "WARNING: No ad groups — run /ads first"`

<HARD-GATE>
Do NOT write landing page specs or any landing/ files until ads/ad-groups.json,
ads/export-keywords.csv, AND context/business.md all exist. ad-groups.json and
export-keywords.csv are produced by the /ads skill. business.md is produced by /context.
If any are missing, invoke the upstream skill first (which will auto-chain its own
dependencies). Do NOT write these files yourself — the /ads skill validates character
limits, pulls real CPC data, and structures ad groups for Google Ads Editor import.
Freehand ad groups break the message-match chain.

This gate applies to Search campaigns only. App campaigns do not produce landing pages —
installs go to the app store.
</HARD-GATE>

# /landing

Build conversion-optimized landing pages that match ad copy to page content. One page per ad group so every visitor lands on a page designed for their exact search intent. Pages are built as JSON content files for the Astro landing page engine — the engine handles layout, animations, responsive design, and conversion patterns automatically.

## Architecture

**Landing page engine repo:** `getclicked-pages` (Astro 5 static site)
**Deployed at:** `https://getclicked-pages-v2.onrender.com/c/{client_slug}/{page_slug}`
**Components:** 10 section types (Hero, Stats, ProductShowcase, Testimonials, ProblemCards, HowItWorks, Comparison, FAQ, FinalCTA, TrustBar)
**Brand system:** `theme.json` → CSS variables. Swap the theme, entire page re-themes.

The agent's job: write page content JSON (~50-130 lines) + ensure brand assets are in place. The engine handles everything else.

## References
- Page content schema: `getclicked-pages/src/lib/types.ts` (PageContent, Section types)
- Golden examples: `docs/golden-examples/landing-page-spec.md`, `docs/golden-examples/landing-brief.md`
- Conversion research: `skills/landing/REFERENCE.md`
- Brand learnings: Read memory file `feedback_landing_page_engine_learnings.md` before generating

## Input
- `ads/ad-groups.json`, `ads/export-keywords.csv` — **required.** If missing, run `/ads` first.
- `context/business.md` — **required** (name, URL, credentials, customers).
- `context/brand.md` — **required** for messaging/voice.
- `context/brand-visual.json` or `context/brand-extraction.json` — **required** for theme. If missing, extract brand from client site using Chrome DevTools.
- `context/personas/` — optional, grounds copy in real persona language.

## Process

### Step 0: Ensure brand assets exist [~5 min if missing]

Check if the Astro engine has this client's theme and assets:

```
getclicked-pages/clients/{client_slug}/theme.json     — brand tokens
getclicked-pages/public/clients/{client_slug}/         — product images, logos, headshots
```

**If theme.json is missing:**
1. Extract brand from client site using Chrome DevTools agent → `brand_raw.json`
2. Normalize to `theme.json` following the Theme interface from `getclicked-pages/src/lib/types.ts`
3. Apply learnings from `feedback_landing_page_engine_learnings.md`:
   - Button padding minimum `14px 28px` (never use raw extracted compact padding)
   - Don't set `heroGradient` unless it's a subtle light wash (not a bold CTA gradient)
   - Secondary button must have visible bg OR border (never transparent + same-color text)

**If product images are missing:**
1. Download product screenshots, logos, headshots from client site
2. Save to `getclicked-pages/public/clients/{client_slug}/`
3. Use self-hosted paths (`/clients/{slug}/filename.ext`) in page JSON — NEVER hotlink external CDNs

### Step 1: Page specs -> `landing/pages/{slug}.md` [~4 min]

**Fast:** Top 3 BOFU ad groups. **Comprehensive:** All groups.

Per ad group, write a page spec with draft copy. PAS framework: Problem → Agitate → Solve.

**9 content blocks (CRO-validated order):**
1. Hero — H1 echoes ad headline, subtitle expands value prop, dual CTA, product image
2. Trust bar — 4 signals with specific numbers
3. Problem + Agitation — PAS copy in persona voice (3 cards)
4. Stats — key metrics with customer quotes (dark section)
5. Solution / Product showcase — features as outcomes with screenshots
6. How It Works — 3 steps, Step 3 = the outcome
7. Social Proof — named testimonials with details
8. FAQ — 4-6 questions from persona fears
9. Final CTA — same CTA label, risk removal (dark section)

**Non-negotiables:** H1 echoes ad headline (message match). One CTA label, three placements. 5th-7th grade reading level. No navigation links. Mobile-first.

**CHECKPOINT — First Page Review**
After writing the FIRST page spec, present the hero:
"Here's the landing page for your [ad group] campaign:
**H1:** [headline]  |  **CTA:** [button text]  |  **Trust:** [trust line]
Message matches ad headline '[ad headline]'. Sound right?"
Wait for response before building remaining pages.

### Step 2: Generate page JSON -> `getclicked-pages/clients/{slug}/pages/{page}.json` [~3 min per page]

Convert each page spec to the Astro engine's JSON format. The JSON schema:

```json
{
  "schema_version": "1.0",
  "meta": { "title": "...", "description": "...", "robots": "noindex, nofollow" },
  "campaign": { "campaign_id": "...", "ad_group": "...", "variant_key": null },
  "nav": { "logo_text": "...", "ctas": { "primary": { "text": "...", "url": "..." } } },
  "sections": [
    { "type": "hero", "headline": "...", "subtitle": "...", "ctas": {...}, "product_image": {...}, "trust_line": "..." },
    { "type": "stats", "variant": "dark", "heading": "...", "items": [...] },
    { "type": "product_showcase", "heading": "...", "products": [...] },
    { "type": "problem_cards", "heading": "...", "cards": [...] },
    { "type": "how_it_works", "heading": "...", "steps": [...] },
    { "type": "testimonials", "featured": {...}, "cards": [...] },
    { "type": "faq", "heading": "...", "items": [...] },
    { "type": "final_cta", "variant": "dark", "headline": "...", "ctas": {...} }
  ],
  "footer": { "badges": [...], "copyright": "..." },
  "tracking": { "client_slug": "...", "page_slug": "..." }
}
```

**Section type reference (what each type expects):**

| Section | Required fields | Key rules |
|---------|----------------|-----------|
| `hero` | headline, subtitle, ctas (CTAGroup) | product_image uses self-hosted path. trust_line optional. |
| `stats` | items[] with number, label | variant: "dark". quote optional per item (Quote object). |
| `product_showcase` | heading, products[] with label, name, description, image (Media) | Image src = self-hosted path. columns: 2 or 3. |
| `problem_cards` | heading, cards[] with heading, description | Auto-numbered (01, 02, 03) by component. |
| `how_it_works` | heading, steps[] with number, heading, description | 3 steps. Step 3 = the outcome. |
| `testimonials` | featured (Quote) or cards (Quote[]) | Avatar uses self-hosted path. Fallback shows initial. |
| `comparison` | heading, us {label, items[]}, them {label, items[]} | Dark vs light columns. |
| `faq` | heading, items[] with question, answer | Native accordion, no JS. |
| `final_cta` | headline, ctas (CTAGroup) | variant: "dark". Subtitle optional. |
| `trust_bar` | logos (Logo[]) | mode: "static" or "marquee". |

**Critical rules for JSON generation:**
- All image `src` values must be self-hosted paths (`/clients/{slug}/filename.ext`), NEVER external CDN URLs
- CTA objects need `text` and `url` — `variant` defaults to "primary" or "secondary"
- Media objects need `src` and `alt` — always include alt text
- `tracking.client_slug` and `tracking.page_slug` are required

### Step 3: Build + deploy [~1 min]

```bash
cd ~/Documents/getclicked-pages
git add clients/{slug}/ public/clients/{slug}/
git commit -m "feat: {client} landing pages — {N} pages for {campaign}"
git push origin main
```

Render auto-deploys in ~30 seconds. Pages go live at:
`https://getclicked-pages-v2.onrender.com/c/{client_slug}/{page_slug}`

### Step 4: Brief -> `landing/brief.md` [~1 min, ALWAYS REQUIRED]

Summary for the workspace: page inventory table with live URLs, shared elements, content needs from client, which ad groups map to which pages.

## Output

| File | Location | Purpose |
|------|----------|---------|
| `landing/pages/*.md` | Local workspace | Page specs with draft copy (strategy layer) |
| `landing/brief.md` | Local workspace | Summary + live URLs |
| `getclicked-pages/clients/{slug}/theme.json` | Engine repo | Brand tokens |
| `getclicked-pages/clients/{slug}/pages/*.json` | Engine repo | Page content for Astro |
| `getclicked-pages/public/clients/{slug}/*` | Engine repo | Self-hosted images |

**Notion:** Sync brief + live preview URLs to Landing Pages section.

## Quality check
- Every page H1 echoes its ad headline (message match)
- All trust signals use specific numbers — no vague claims
- Copy is 5th-7th grade reading level
- All images use self-hosted paths (not external CDN URLs)
- JSON validates against the PageContent schema (schema_version, meta, nav, sections, footer, tracking all present)
- Page builds successfully: `cd ~/Documents/getclicked-pages && npx astro build`
- Test both the new page AND existing pages still build (no regressions)

## Brand extraction learnings (read before every run)

1. **`--text-accent` must NEVER appear on dark sections** — use `--text-on-dark` or `--text-on-dark-muted`
2. **Button padding minimum `14px 28px`** — raw extracted values are often compact variants
3. **Don't set `heroGradient`** unless it's a subtle light wash — bold gradients make hero text unreadable
4. **Secondary button needs visible boundary** — solid bg OR visible border, never transparent-on-transparent
5. **Always self-host images** — hotlinking gets CORS-blocked
6. **Test with both dark-accent and light-accent brands** — bugs hide when accent ≈ surface color

## Budgets
- Max 3 Read calls (reference files + context)
- Max 3 MCP research calls (web_extract for auditing existing pages)
- Max 2 Notion writes (brief + pages)

## Next
After completing this skill, offer next steps — don't auto-chain:
"Landing pages built and live. Run /experiment to set up A/B tests, or wait 7+ days for traffic and run /optimize to analyze performance."

/optimize and /experiment require explicit intent. Don't invoke without asking.
