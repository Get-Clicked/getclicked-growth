#!/bin/bash
# PostToolUse hook: detect Notion writes, suggest next skill
# Fires on mcp__notion__.* tool calls
# Returns additionalContext to nudge agent toward next skill in chain
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // ""')

case "$TOOL" in
  mcp__notion__notion-update-page|mcp__notion__notion-create-pages)
    if [ -f "context/brand.md" ] && [ ! -f "ads/ad-groups.json" ]; then
      echo '{"hookSpecificOutput":{"additionalContext":"Brand positioning is complete. The natural next step is building Google Ads campaigns from the keyword research. Suggest running the ads skill next."}}'
    elif [ -f "ads/ad-groups.json" ] && [ ! -d "landing/pages" ]; then
      echo '{"hookSpecificOutput":{"additionalContext":"Ad campaigns are built. Landing pages are the obvious next step — each ad group needs a page. Suggest running the landing skill next."}}'
    elif [ -f "context/business.md" ] && [ ! -f "context/brand.md" ]; then
      echo '{"hookSpecificOutput":{"additionalContext":"Business context is documented. Brand positioning should come next to establish voice before writing any campaigns. Suggest running the brand skill next."}}'
    fi
    ;;
esac
exit 0
