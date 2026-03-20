# getclicked-growth

Your AI Growth Officer — market research, brand strategy, ad campaigns, SEO, landing pages, and optimization. A dedicated marketing team that lives in your editor.

## What It Does

The Growth Officer builds and runs your marketing. You set the strategy, it does the work.

It ships with eleven skills that cover the full marketing loop:

- **start** — Guided onboarding. Learns your business, gets you to your first win.
- **context** — Deep-dives your business, market, competitors, and keywords. Real data from DataForSEO — no guessing.
- **brand** — Nails your positioning, voice, and messaging guardrails so everything sounds like you.
- **ads** — Builds Google Ads campaigns end-to-end: keywords, ad copy, negatives, budget allocation, and ready-to-import export files.
- **seo** — Organic strategy: keyword research, technical site audit, and content planning.
- **landing** — Landing page specs matched to your ad groups. Every ad sends traffic to a page built to convert.
- **optimize** — Pulls live campaign data, finds waste, and ranks improvements by impact.
- **experiment** — Tests marketing ideas with real hypotheses and success criteria. Learnings compound across sessions.
- **gtm** — Go-to-market distribution strategy: channel prioritization, experiment designs, 90-day plan.
- **playbook** — Capstone GTM Prototype: synthesizes everything into a single strategic document.
- **audit** — Website QA: broken links, content gaps, responsive design, technical SEO.

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

## Free Tier

The plugin works immediately — no setup, no API keys. The free tier includes:

- **Market research** — competitor analysis, keyword themes, real search data
- **Brand strategy** — positioning, voice, messaging pillars
- **Site audit** — broken links, technical SEO, content gaps

That's enough to understand your market and see what needs fixing.

## Upgrade

For unlimited research, Google Ads campaigns, SEO strategy, landing pages, optimization, and experimentation:

→ **[getclicked.ai/upgrade](https://getclicked.ai/upgrade)**

Set `GETCLICKED_API_KEY` in your environment after subscribing.

## Developers: Bring Your Own Keys

If you prefer to use your own API credentials instead of upgrading:

### DataForSEO

```
DATAFORSEO_API_LOGIN=your-email
DATAFORSEO_API_PASSWORD=your-password
```

Sign up at [dataforseo.com](https://dataforseo.com). Powers keyword research with real search volume, CPC, and competition data.

### Tavily

```
TAVILY_API_KEY=your-key
```

Get a key at [tavily.com](https://tavily.com). Enables web research for market analysis.

Add these to your project `.env`. Skills will use your keys directly instead of the hosted service.

### Notion (optional)

Connect Notion for cloud persistence — work survives across sessions:

Add to your project `.mcp.json`:

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
