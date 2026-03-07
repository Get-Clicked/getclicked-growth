#!/usr/bin/env bash
set -euo pipefail

echo "--- GROWTH OFFICER STATUS ---"

# DataForSEO
if [[ -f ".env" ]] && grep -q "DATAFORSEO_API_LOGIN" .env 2>/dev/null; then
  echo "DataForSEO: configured"
else
  echo "DataForSEO: not configured (set DATAFORSEO_API_LOGIN + DATAFORSEO_API_PASSWORD in .env)"
fi

# Tavily
if [[ -f ".env" ]] && grep -q "TAVILY_API_KEY" .env 2>/dev/null; then
  echo "Tavily: configured"
else
  echo "Tavily: not configured (set TAVILY_API_KEY in .env for web research)"
fi

# Notion
notion_configured=false
if [[ -f ".mcp.json" ]]; then
  if command -v jq >/dev/null 2>&1; then
    jq -e '.mcpServers.notion' .mcp.json >/dev/null 2>&1 && notion_configured=true
  else
    grep -q '"notion"' .mcp.json 2>/dev/null && notion_configured=true
  fi
fi
if $notion_configured; then
  echo "Notion: connected"
else
  echo "Notion: not connected (optional — add to .mcp.json for cloud persistence)"
fi

echo "--- END STATUS ---"
