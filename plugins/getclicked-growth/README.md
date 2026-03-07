# getclicked-growth

Your AI Growth Officer — a dedicated marketing team that lives in your editor.

Build market research, brand strategy, Google Ads campaigns, SEO plans, landing pages, and go-to-market strategy from a single conversation. Every deliverable is grounded in real data (DataForSEO), not guesses.

## What You Get

| Skill | What It Does | Time (fast) |
|-------|-------------|-------------|
| `/start` | Guided onboarding for new users | ~3 min |
| `/context` | Business facts, market research, competitor analysis, keyword themes, personas | ~8 min |
| `/brand` | Positioning, voice, messaging pillars, guardrails | ~5 min |
| `/ads` | Google Ads campaigns — keywords, ad copy, negatives, budget, export files | ~10 min |
| `/seo` | Organic strategy — keyword research, site audit, content ideas | ~8 min |
| `/landing` | Landing page specs matched to ad groups with conversion optimization | ~8 min |
| `/optimize` | Live campaign analysis — plan vs actual, search term audit, ranked actions | ~8 min |
| `/experiment` | Hypothesis-driven marketing with success criteria and lifecycle tracking | ~5 min |
| `/gtm` | Go-to-market distribution strategy with channel prioritization and 90-day plan | ~8 min |

## Getting Started on Cowork

Everything works out of the box. DataForSEO (keyword research) and Tavily (web research) are provided automatically via the founderbee-data MCP server — no API keys or `.env` setup needed.

**What's included:** Market research, keyword data, competitor analysis, ad campaigns, SEO strategy, landing pages, go-to-market plans, and experimentation — all powered by real data.

**What's optional:** Google Ads optimization (`/optimize`) requires Google Ads API access via the founderbee-google integration. The agent will walk you through setup if you need it.

**First command:** Just start talking about your business, or say "I'm new" for guided onboarding.

**Where data is saved:** Connect Notion for cross-session persistence. Without Notion, your work lives in the current session only.

## Getting Started on Claude Code

1. **Install the plugin**
2. **Set up credentials** (see [Setup](#setup) below)
3. **Say** "I need help marketing my business" — the Growth Officer takes it from there

Or jump straight to a skill: "Build me a Google Ads campaign for [your business]"

The agent auto-chains dependencies. If you ask for ads but don't have context yet, it runs `/context` first automatically.

## Setup

### Required (Claude Code only): DataForSEO

1. Sign up at [dataforseo.com](https://dataforseo.com) — free trial includes API credits
2. Create a `.env` file in your project root:
   ```
   DATAFORSEO_API_LOGIN=your@email.com
   DATAFORSEO_API_PASSWORD=your_api_password
   ```

### Required (Claude Code only): Tavily

1. Get an API key at [tavily.com](https://tavily.com) — free tier available
2. Add to your `.env`:
   ```
   TAVILY_API_KEY=tvly-your_key_here
   ```

*On Cowork, both services are provided automatically — skip these steps.*

### Optional: Notion (cloud persistence)

For Cowork users or anyone who wants deliverables saved to Notion:

1. Add a Notion MCP server to your `.mcp.json`:
   ```json
   {
     "mcpServers": {
       "notion": {
         "command": "npx",
         "args": ["-y", "@anthropic/notion-mcp-server"],
         "env": {
           "NOTION_API_KEY": "your_notion_integration_token"
         }
       }
     }
   }
   ```
2. Create a Notion integration at [notion.so/my-integrations](https://www.notion.so/my-integrations)
3. Share your workspace pages with the integration

Without Notion, all output writes to local files (fully functional, git-versioned).

### Optional: Google Ads (live optimization)

Required only for `/optimize`. The agent will prompt you when needed.

### Verify Setup

The plugin runs a health check on session start. You'll see:
```
--- GROWTH OFFICER STATUS ---
DataForSEO: configured (MCP or BYOK)
Tavily: configured (MCP or BYOK)
Notion: connected (or "not connected — optional")
--- END STATUS ---
```

## How It Works

**Files persist, not agents.** Every skill reads and writes markdown, CSV, and JSON files as shared state. Context flows downstream:

```
/context (foundation)
    |
/brand (strategy)
    |
    +-- /ads --> /landing --> /optimize
    |
    +-- /seo
    |
    +-- /gtm
    |
    +-- /experiment (learning layer — feeds insights back to all skills)
```

**Two execution modes:**
- **Fast (default):** Core deliverables only. Say "go deep" for the full analysis.
- **Comprehensive:** Everything — competitor SEO audits, geo CPC pulls, forecast projections, client presentations.

**Insights compound.** Each `/optimize` run and `/experiment` result writes learnings to `insights/`. Every skill reads insights before generating — the system gets smarter over time.

## Example Workflow

```
You: "I run a home services company in Boise. Help me get more customers."

Growth Officer runs:
  /context (fast) → business.md, market.md, keywords.md, 2 personas
  /ads (fast)     → keywords.csv, ad-groups.json, negatives.json, budget.md, exports
  /landing        → audit.md, 3 page specs matched to ad groups, brief.md

Result: Ready-to-import Google Ads campaign + landing page specs in ~25 minutes.
```

## Data Quality

- Every keyword metric is real DataForSEO data or explicitly marked `UNVALIDATED`
- No estimated ranges, no "approximately," no assumptions
- Ad copy character limits enforced at generation time (headlines ≤ 30, descriptions ≤ 90)
- Negative keywords cross-checked against positives before adding

## File Structure

```
context/
  business.md          # What the business is
  market.md            # Competitors, trends, gaps
  keywords.md          # North star themes + DataForSEO metrics
  brand.md             # Positioning, voice, messaging
  personas/            # Audience personas (one file each)

ads/
  keywords.csv         # Paid keywords with match types, bids, metrics
  ad-groups.json       # Ad groups with headlines + descriptions
  negatives.json       # Negative keywords with conflict prevention
  budget.md            # Budget allocation + bid recommendations
  export-*.csv         # Google Ads Editor import files

seo/
  keywords.csv         # Organic keywords with tiers + content mapping
  audit.md             # Technical + content + local SEO audit
  content-ideas.csv    # Content strategy mapped to keywords

landing/
  audit.md             # Existing page scores
  pages/*.md           # One page spec per ad group
  brief.md             # Dev/design handoff summary

optimize/
  report.md            # Performance analysis + ranked actions
  state.json           # Run history + benchmarks

experiments/
  EXP-NNN-*.md         # Individual experiment files
  INDEX.md             # Master experiment table

insights/
  keyword-research.md  # Canonical forms, dead ends, geo patterns
  copy-patterns.md     # Headline/CTA patterns that work
  negative-patterns.md # Proven negative keyword categories
```

## Support

- Issues: [github.com/Get-Clicked/getclicked-agent/issues](https://github.com/Get-Clicked/getclicked-agent/issues)
- Email: hello@founderbeelabs.com
- Website: [getclicked.ai](https://getclicked.ai)

## License

MIT — see [LICENSE](LICENSE)
