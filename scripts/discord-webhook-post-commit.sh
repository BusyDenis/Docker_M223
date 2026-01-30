#!/bin/sh
# Sendet bei jedem Commit eine Nachricht an den Discord-Webhook.
# Webhook-URL kann überschrieben werden: DISCORD_WEBHOOK_URL="..." (z.B. in .env oder Umgebung)

DISCORD_WEBHOOK_URL="${DISCORD_WEBHOOK_URL:-https://discord.com/api/webhooks/1466780880918806672/kT8a8nNWgbjWDa8Dp3FWOIQBaLLSjypGKc0WIZDuA1kgXeli9K934S1y7vHVxUo0-vbi}"

COMMIT_MSG=$(git log -1 --pretty=%B)
COMMIT_AUTHOR=$(git log -1 --pretty=%an)
COMMIT_HASH=$(git log -1 --pretty=%h)
REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "Docker_M223")

# JSON-Payload mit Python (portabel) oder einfacher Ersetzung bauen
if command -v python3 >/dev/null 2>&1; then
  export COMMIT_MSG COMMIT_AUTHOR COMMIT_HASH REPO_NAME
  PAYLOAD=$(python3 -c "
import json, os
msg = os.environ.get('COMMIT_MSG', '')
author = os.environ.get('COMMIT_AUTHOR', '')
h = os.environ.get('COMMIT_HASH', '')
repo = os.environ.get('REPO_NAME', '')
content = '**Neuer Commit** in \`' + repo + '\`\n\n**Nachricht:** ' + msg.replace('**', '') + '\n**Autor:** ' + author + '\n**Hash:** ' + h
print(json.dumps({'content': content}))
")
else
  # Fallback: einfaches JSON (Commit-Nachricht ohne Sonderzeichen)
  SAFE_MSG=$(echo "$COMMIT_MSG" | head -1 | sed 's/"/\\"/g')
  PAYLOAD="{\"content\": \"**Neuer Commit** in \\\`$REPO_NAME\\\`\n\n**Nachricht:** $SAFE_MSG\n**Autor:** $COMMIT_AUTHOR\n**Hash:** $COMMIT_HASH\"}"
fi

curl -s -S -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$DISCORD_WEBHOOK_URL" >/dev/null 2>&1 || true
