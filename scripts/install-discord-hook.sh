#!/bin/sh
# Richtet den Discord-Webhook Post-Commit-Hook ein.
# Einmal ausführen: sh scripts/install-discord-hook.sh

REPO_ROOT=$(git rev-parse --show-toplevel)
HOOK_DST="$REPO_ROOT/.git/hooks/post-commit"
HOOK_SRC="$REPO_ROOT/scripts/discord-webhook-post-commit.sh"

if [ ! -f "$HOOK_SRC" ]; then
  echo "Skript nicht gefunden: $HOOK_SRC"
  exit 1
fi

cat > "$HOOK_DST" << 'HOOK_EOF'
#!/bin/sh
# Discord-Webhook bei jedem Commit
REPO_ROOT=$(git rev-parse --show-toplevel)
sh "$REPO_ROOT/scripts/discord-webhook-post-commit.sh"
HOOK_EOF

chmod +x "$HOOK_DST" 2>/dev/null || true
echo "Discord Post-Commit-Hook installiert: .git/hooks/post-commit"
echo "Bei jedem Commit wird eine Nachricht an Discord gesendet."
