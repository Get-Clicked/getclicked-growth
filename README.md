# getclicked-growth

Your AI Growth Officer — market research, brand strategy, ad campaigns, SEO, landing pages, and optimization. A dedicated marketing team that lives in your editor.

## What It Does

The Growth Officer builds and runs your marketing. You set the strategy, it does the work.

It ships with eight skills that cover the full marketing loop:

- **start** — Guided onboarding. Learns your business, gets you to your first win.
- **context** — Deep-dives your business, market, competitors, and keywords. Real data from DataForSEO — no guessing.
- **brand** — Nails your positioning, voice, and messaging guardrails so everything sounds like you.
- **ads** — Builds Google Ads campaigns end-to-end: keywords, ad copy, negatives, budget allocation, and ready-to-import export files.
- **seo** — Organic strategy: keyword research, technical site audit, and content planning.
- **landing** — Landing page specs matched to your ad groups. Every ad sends traffic to a page built to convert.
- **optimize** — Pulls live campaign data, finds waste, and ranks improvements by impact.
- **experiment** — Tests marketing ideas with real hypotheses and success criteria. Learnings compound across sessions.

## Quick Start

1. Install the plugin:

   ```bash
   claude plugin install github:Get-Clicked/getclicked-growth
   ```

2. Open your project directory and start Claude Code.

3. Just talk. The Growth Officer figures out what you need.

   - "I need help with my Google Ads"
   - "Research my market and competitors"
   - "Build me a landing page for my ad campaign"
   - "What keywords should I be bidding on?"

## Setup

The plugin works out of the box — but real keyword data requires API keys.

### DataForSEO (recommended)

Add to your project `.env`:

```
DATAFORSEO_API_LOGIN=your-email
DATAFORSEO_API_PASSWORD=your-password
```

Powers keyword research with real search volume, CPC, and competition data. Every number in your deliverables will be actual pulled data, not estimates.

### Tavily (optional)

```
TAVILY_API_KEY=your-key
```

Enables live web research for market analysis and competitor intelligence.

### Notion (optional)

Connect Notion for cloud persistence — your work survives across sessions and is shareable with your team:

```json
{
  "mcpServers": {
    "notion": {
      "type": "http",
      "url": "https://mcp.notion.com/mcp"
    }
  }
}
```

Add this to your project `.mcp.json` and authorize when prompted.

## How It Works

Skills are model-invoked — talk naturally, and the agent picks the right skill for the job. No slash commands to memorize (though they work too).

The canonical sequence builds on itself:

```
context --> brand --> ads --+--> landing --> optimize --> experiment
                    seo ---+
```

Context informs brand. Brand constrains ads and SEO. Ads feed landing pages. Live data drives optimization. Experiments test new ideas. Learnings flow back into everything.

**Key principles:**

- Files persist locally as markdown and CSV — diffable, readable, yours
- Every number is real data or explicitly marked `UNVALIDATED`
- The agent has opinions. It tells you what it actually thinks, not three equally-weighted options.
- Insights compound. What you learn in one session carries forward to the next.

## Who It's For

Marketing leaders who know strategy but need execution leverage. You set direction, approve the work, and keep your judgment in the loop. The Growth Officer handles the research, the builds, and the busy work.

Not a dashboard. Not a chatbot. A teammate that does the work.

## License

MIT — Founderbee Labs Inc.

## Links

- **Issues:** [github.com/Get-Clicked/getclicked-growth/issues](https://github.com/Get-Clicked/getclicked-growth/issues)
- **Founderbee:** [getclicked.ai](https://getclicked.ai)
