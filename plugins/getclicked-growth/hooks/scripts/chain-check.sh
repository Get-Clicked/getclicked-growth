#!/bin/bash
# Stop hook: suggest continuation if chain seems incomplete
# Does NOT use exit 2 (no blocking) — just injects additionalContext
INPUT=$(cat)
STOP_REASON=$(echo "$INPUT" | jq -r '.stop_reason // ""')

if [ "$STOP_REASON" != "endTurn" ]; then
  exit 0
fi

if [ -f "context/business.md" ] && [ ! -f "context/brand.md" ] && [ ! -f "ads/ad-groups.json" ]; then
  echo '{"hookSpecificOutput":{"additionalContext":"You have context research but have not built any campaigns or positioning yet. Ask the user if they want to continue to the next step."}}'
fi

exit 0
