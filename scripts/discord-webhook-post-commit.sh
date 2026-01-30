#!/bin/sh
# Sendet bei jedem Commit eine Nachricht an den Discord-Webhook.
#
# Optionale Umgebungsvariablen / .env:
#   DISCORD_WEBHOOK_URL   - Webhook-URL (Standard: siehe unten)
#   DISCORD_IMAGE_URL     - Bild-URL für die Nachricht (z.B. Logo oder Screenshot)
#   DISCORD_CUSTOM_MESSAGE - Deine eigene Nachricht (wird oben angezeigt, z.B. "Deploy läuft!")
#   DISCORD_LINK_URL      - URL, auf die der Titel klickt (Standard: https://denis.dev.noseryoung.ch/)

DISCORD_WEBHOOK_URL="${DISCORD_WEBHOOK_URL:-https://discord.com/api/webhooks/1466780880918806672/kT8a8nNWgbjWDa8Dp3FWOIQBaLLSjypGKc0WIZDuA1kgXeli9K934S1y7vHVxUo0-vbi}"
DISCORD_LINK_URL="${DISCORD_LINK_URL:-https://denis.dev.noseryoung.ch/}"
DISCORD_IMAGE_URL="${DISCORD_IMAGE_URL:-https://media.tenor.com/OXZ196bUPfoAAAAM/orange-funny.gif}"
DISCORD_CUSTOM_MESSAGE="${DISCORD_CUSTOM_MESSAGE:-Der königliche Sigma hat ein neuen Commit gepushed #Gianluca #Phuc #Luca #Noseryoung #StayGeeked #MichelLetMeIn #Uek223 #223 #NoserYoung #Lehre #City #Boi #TBZ #McDonalds #TenorGIFs #GoofyAhh #223_User_Profile_Backend #223_User_Profile_Frontend #Docker_M223 #Frontend #Backend #Ballin #Seriösitet #Noser2025 #Kreuzfahrt #Springboot #React #thuglife #silly #programmieren."

COMMIT_MSG=$(git log -1 --pretty=%B)
COMMIT_AUTHOR=$(git log -1 --pretty=%an)
COMMIT_HASH=$(git log -1 --pretty=%h)
REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "Docker_M223")

# JSON-Payload mit Embed (Titel = Link, optional Bild + eigene Nachricht)
if command -v python3 >/dev/null 2>&1; then
  export COMMIT_MSG COMMIT_AUTHOR COMMIT_HASH REPO_NAME
  export DISCORD_LINK_URL DISCORD_IMAGE_URL DISCORD_CUSTOM_MESSAGE
  PAYLOAD=$(python3 -c "
import json, os
msg = os.environ.get('COMMIT_MSG', '')
author = os.environ.get('COMMIT_AUTHOR', '')
h = os.environ.get('COMMIT_HASH', '')
repo = os.environ.get('REPO_NAME', '')
link_url = os.environ.get('DISCORD_LINK_URL', '')
img_url = os.environ.get('DISCORD_IMAGE_URL', '')
custom = os.environ.get('DISCORD_CUSTOM_MESSAGE', '')
desc = '**Nachricht:** ' + msg.replace('**', '') + '\n**Autor:** ' + author + '\n**Hash:** ' + h
embed = {'title': 'Neuer Commit in ' + repo, 'url': link_url, 'description': desc}
if img_url:
    embed['image'] = {'url': img_url}
body = {'embeds': [embed]}
if custom:
    body['content'] = custom
print(json.dumps(body))
")
else
  SAFE_MSG=$(echo "$COMMIT_MSG" | head -1 | sed 's/"/\\"/g')
  CUSTOM_ESC=$(echo "$DISCORD_CUSTOM_MESSAGE" | sed 's/"/\\"/g')
  IMG_PART=""
  [ -n "$DISCORD_IMAGE_URL" ] && IMG_PART=",\"image\":{\"url\":\"$DISCORD_IMAGE_URL\"}"
  CONTENT_PART=""
  [ -n "$DISCORD_CUSTOM_MESSAGE" ] && CONTENT_PART="\"content\":\"$CUSTOM_ESC\","
  PAYLOAD="{$CONTENT_PART\"embeds\":[{\"title\":\"Neuer Commit in $REPO_NAME\",\"url\":\"$DISCORD_LINK_URL\",\"description\":\"**Nachricht:** $SAFE_MSG\n**Autor:** $COMMIT_AUTHOR\n**Hash:** $COMMIT_HASH\"$IMG_PART}]}"
fi

curl -s -S -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$DISCORD_WEBHOOK_URL" >/dev/null 2>&1 || true
