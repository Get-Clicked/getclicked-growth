# API Patterns Reference

Shared reference for DataForSEO and Tavily usage across all skills. Read this instead of inlining API patterns in each SKILL.md.

---

## MCP Tool Reference

Use MCP tools first. No credentials needed -- the hosted server handles auth.

| Tool | Purpose | Key Params |
|------|---------|-----------|
| `keyword_search_volume` | Batch volume/CPC/competition for up to 10 keywords | `keywords[]`, `location_name`, `language_name` |
| `keyword_suggestions` | Expand a seed keyword into related terms | `keyword`, `location_name` |
| `ranked_keywords` | Competitor organic keyword analysis (what they rank for) | `target` (domain), `location_code`, `limit`, `filters` |
| `serp_competitors` | Find who competes for a keyword in SERPs | `keywords[]`, `location_name` |
| `domain_overview` | Domain-level organic + paid metrics snapshot | `target` (domain) |
| `paid_keywords` | Keywords a domain bids on in Google Ads | `target` (domain) |
| `competitor_ads` | Actual ad copy a domain runs | `target` (domain) |
| `domain_intersection` | Keywords multiple domains share | `targets[]` |
| `web_search` | Tavily web search (competitor research, trends) | `query` |
| `web_extract` | Tavily page scrape (site content, CSS, structure) | `url` |

---

## Location Code Format

DataForSEO expects locations as comma-separated strings:

```
"Saginaw,Michigan,United States"
"Denver,Colorado,United States"
"United States"                    (national)
```

If unsure of the exact format, use the locations endpoint to look up the correct string. State-level codes for `search_volume/live`: use `"{State},United States"` format.

---

## Fallback Chain

1. **MCP tools** (preferred) -- call `keyword_search_volume` or similar directly. No credentials needed.
2. **BYOK curl** (Claude Code only) -- read `.env` for `DATAFORSEO_BASE64` (or `DATAFORSEO_API_LOGIN` + `DATAFORSEO_API_PASSWORD`). Use the Read tool to get values -- never assume shell exports. Never print credentials.
3. **web_search** -- for market research and competitor intel when keyword tools are unavailable.

If all paths fail, stop and tell the user. Never estimate metrics.

---

## Free Tier Limits

Unauthenticated users hit daily limits on the hosted MCP server:

| Tool | Daily Limit |
|------|------------|
| `keyword_search_volume` | 5 calls |
| `keyword_suggestions` | 5 calls |
| `ranked_keywords` | 10 calls |
| `serp_competitors` | 10 calls |
| `web_search` | 100 calls |
| `web_extract` | 100 calls |

When a call hits the limit, handle gracefully: tell the user, offer OAuth sign-in for unlimited access, mention BYOK as alternative, offer to save progress.

Note: limits will change when unified MCP ships.

---

## Caching Rule

Before every DataForSEO call, read `insights/keyword-research.md` (if it exists). Use known canonical forms. Skip keywords listed as dead ends. After calls, append new findings (canonical forms, dead ends, geo patterns) to the same file.

This saves API credits and prevents re-discovering what previous skill runs already learned.

---

## Batch Size

`keyword_search_volume` accepts up to **10 keywords per call**. Plan batches accordingly.

For geo-specific CPC pulls, run one `search_volume/live` call per target state in parallel. Long-tail keywords often fall below state-level tracking thresholds -- that is expected.

---

## Zero-Volume Investigation

When a keyword returns 0 volume but the concept is real, test 2-3 word-order variants before declaring it dead. DataForSEO tracks the specific canonical form Google uses (e.g., "online UTI treatment" = 0, "treat UTI online" = 5,400/mo). Append results to `insights/keyword-research.md`.
