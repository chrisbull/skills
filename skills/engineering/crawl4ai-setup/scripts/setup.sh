#!/usr/bin/env bash
# Run a local Crawl4AI server and register it with Claude Code. Safe to re-run.
# Usage: setup.sh [--update]
set -euo pipefail

NAME=crawl4ai
IMAGE=unclecode/crawl4ai:latest
PORT=11235
BIND="127.0.0.1:$PORT"
BASE="http://$BIND"
MCP_URL="$BASE/mcp/sse"
TOKEN_FILE="$HOME/.crawl4ai/docker-server.env"

die() { echo "error: $*" >&2; exit 1; }
say() { echo "- $*"; }

update=0
case "${1:-}" in
  "") ;;
  --update) update=1 ;;
  *) die "unknown argument '$1'. Usage: setup.sh [--update]" ;;
esac

for cmd in docker claude curl openssl; do
  command -v "$cmd" >/dev/null || die "$cmd is not installed"
done
docker info >/dev/null 2>&1 || die "Docker is not running. Start it and re-run"

# Refuse to overwrite an MCP entry that points somewhere else, such as the hosted API.
if existing="$(claude mcp get "$NAME" 2>/dev/null)"; then
  case "$existing" in
    *"$MCP_URL"*) ;;
    *) die "an MCP server named '$NAME' already points elsewhere. Remove it with 'claude mcp remove $NAME' and re-run" ;;
  esac
fi

exists=0
if docker container inspect "$NAME" >/dev/null 2>&1; then
  exists=1
  image="$(docker inspect -f '{{.Config.Image}}' "$NAME")"
  case "$image" in
    unclecode/crawl4ai*) ;;
    *) die "a container named '$NAME' runs a different image ($image). Rename or remove it and re-run" ;;
  esac
fi

( umask 077; mkdir -p "$(dirname "$TOKEN_FILE")" )
if [ ! -e "$TOKEN_FILE" ]; then
  ( umask 077; printf 'CRAWL4AI_API_TOKEN=%s\n' "$(openssl rand -hex 32)" > "$TOKEN_FILE" )
  say "created token file $TOKEN_FILE"
fi
chmod 600 "$TOKEN_FILE"
TOKEN="$(sed -n 's/^CRAWL4AI_API_TOKEN=//p' "$TOKEN_FILE" | head -n 1)"
[ -n "$TOKEN" ] || die "$TOKEN_FILE has no CRAWL4AI_API_TOKEN value. Delete the file and re-run with --update"

port_busy() { (exec 3<>"/dev/tcp/127.0.0.1/$PORT") 2>/dev/null; }

start_new() {
  port_busy && die "port $PORT is in use by something other than the '$NAME' container"
  docker run -d -p "$BIND:$PORT" --name "$NAME" --shm-size=1g \
    --restart unless-stopped --env-file "$TOKEN_FILE" "$IMAGE" >/dev/null
}

if [ "$update" = 1 ]; then
  say "pulling $IMAGE"
  docker pull -q "$IMAGE" >/dev/null
  if [ "$exists" = 1 ]; then docker rm -f "$NAME" >/dev/null; fi
  start_new
  say "started the latest image"
elif [ "$exists" = 0 ]; then
  say "pulling $IMAGE"
  docker pull -q "$IMAGE" >/dev/null
  start_new
  say "started container"
elif [ "$(docker inspect -f '{{.State.Running}}' "$NAME")" != true ]; then
  port_busy && die "port $PORT is in use by something other than the '$NAME' container"
  docker start "$NAME" >/dev/null
  say "started existing container"
else
  say "container already running"
fi

published="$(docker port "$NAME" "$PORT/tcp" 2>/dev/null || true)"
[ "$published" = "$BIND" ] \
  || die "container is published on '${published:-nothing}', expected $BIND. Re-run with --update to recreate it"

healthy=0
for _ in $(seq 1 30); do
  if curl -fsS -m 3 "$BASE/health" >/dev/null 2>&1; then healthy=1; break; fi
  sleep 2
done
[ "$healthy" = 1 ] || die "server not healthy after 60s. Check: docker logs $NAME"
say "server healthy"

md() { curl -s -m 90 -X POST "$BASE/md" -H 'Content-Type: application/json' -d '{"url":"https://example.com"}' "$@"; }

code="$(md -o /dev/null -w '%{http_code}' || true)"
[ "$code" = 401 ] || die "expected 401 without a token, got '$code'. The server's auth behaviour may have changed"
say "server rejects requests without a token"

code="$(md -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $TOKEN" || true)"
case "$code" in
  200) ;;
  401|403) die "container's token differs from $TOKEN_FILE. Re-run with --update to recreate it" ;;
  *) die "test crawl returned '$code'. Check: docker logs $NAME" ;;
esac
say "test crawl succeeded"

# Re-add every run so a stale token gets replaced.
claude mcp remove --scope user "$NAME" >/dev/null 2>&1 || true
claude mcp add --scope user --transport sse "$NAME" "$MCP_URL" \
  --header "Authorization: Bearer $TOKEN" >/dev/null

listed="$(claude mcp list 2>&1 || true)"
case "$(printf '%s\n' "$listed" | grep "^$NAME:" || true)" in
  *Connected*) ;;
  *) die "Claude Code could not connect to '$NAME'. Check: claude mcp list" ;;
esac
say "Claude Code connected"

echo "setup verified"
