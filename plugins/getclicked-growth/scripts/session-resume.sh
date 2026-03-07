#!/usr/bin/env bash
set -euo pipefail

# Skill completion checks
check_nonempty() { [[ -f "$1" ]] && [[ -s "$1" ]]; }

context_done=false
brand_done=false
ads_done=false
seo_done=false
landing_done=false
optimize_done=false
experiment_done=false

# context: context/business.md + context/market.md + context/keywords.md all exist and non-empty
if check_nonempty "context/business.md" && check_nonempty "context/market.md" && check_nonempty "context/keywords.md"; then
  context_done=true
fi

# brand: context/brand.md exists and non-empty
if check_nonempty "context/brand.md"; then
  brand_done=true
fi

# ads: ads/keywords.csv + ads/ad-groups.json exist
if [[ -f "ads/keywords.csv" ]] && [[ -f "ads/ad-groups.json" ]]; then
  ads_done=true
fi

# seo: seo/keywords.csv + seo/content-ideas.csv exist
if [[ -f "seo/keywords.csv" ]] && [[ -f "seo/content-ideas.csv" ]]; then
  seo_done=true
fi

# landing: landing/pages/ has at least 1 .md file
if [[ -d "landing/pages" ]] && compgen -G "landing/pages/*.md" >/dev/null 2>&1; then
  landing_done=true
fi

# optimize: optimize/report.md exists
if [[ -f "optimize/report.md" ]]; then
  optimize_done=true
fi

# experiment: experiments/ has at least 1 EXP-*.md file
if [[ -d "experiments" ]] && compgen -G "experiments/EXP-*.md" >/dev/null 2>&1; then
  experiment_done=true
fi

# Check if ANY skill is complete
any_done=false
for skill in $context_done $brand_done $ads_done $seo_done $landing_done $optimize_done $experiment_done; do
  if $skill; then
    any_done=true
    break
  fi
done

if ! $any_done; then
  echo "--- SESSION RESUME ---"
  echo "No skills have been run yet. Start by talking about your business — the Growth Officer will take it from there."
  echo "--- END SESSION RESUME ---"
  exit 0
fi

# Determine suggested next skill (canonical order)
suggested=""
if ! $context_done; then
  suggested="context"
elif ! $brand_done; then
  suggested="brand"
elif ! $ads_done; then
  suggested="ads"
elif ! $seo_done; then
  suggested="seo"
elif ! $landing_done; then
  suggested="landing"
elif ! $optimize_done; then
  suggested="optimize"
elif ! $experiment_done; then
  suggested="experiment"
fi

# Notion detection
notion_configured=false
if [[ -f ".mcp.json" ]]; then
  if command -v jq >/dev/null 2>&1; then
    jq -e '.mcpServers.notion' .mcp.json >/dev/null 2>&1 && notion_configured=true
  else
    grep -q '"notion"' .mcp.json 2>/dev/null && notion_configured=true
  fi
fi

yn() { if $1; then echo "YES"; else echo "NO"; fi; }

echo "--- SESSION RESUME ---"
echo "Skills:"
echo "  context: $(yn $context_done)"
echo "  brand: $(yn $brand_done)"
echo "  ads: $(yn $ads_done)"
echo "  seo: $(yn $seo_done)"
echo "  landing: $(yn $landing_done)"
echo "  optimize: $(yn $optimize_done)"
echo "  experiment: $(yn $experiment_done)"
echo ""
if [[ -n "$suggested" ]]; then
  echo "Suggested next: $suggested"
  echo ""
fi
if $notion_configured; then
  echo "Notion MCP: configured"
  echo "ACTION_FOR_AGENT: Search Notion for pages matching \"* Workspace\" to detect Notion-based workspaces."
else
  echo "Notion MCP: not configured"
fi
echo "--- END SESSION RESUME ---"
