#!/usr/bin/env bash
# Symlink every skill in this repo (except deprecated/), including the skills
# of the standalone plugins under plugins/, into the local harness skill
# directories, and those plugins' agents into ~/.claude/agents, so `git pull`
# keeps them current.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DESTS=("$HOME/.claude/skills" "$HOME/.agents/skills")
AGENT_DEST="$HOME/.claude/agents"

link() {
  local src="$1" target="$2"
  mkdir -p "$(dirname "$target")"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "skip $(basename "$src"): $target exists and is not a symlink" >&2
    return
  fi
  ln -sfn "$src" "$target"
  echo "linked $(basename "$src") -> $target"
}

while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  for dest in "${SKILL_DESTS[@]}"; do
    link "$src" "$dest/$(basename "$src")"
  done
done < <(find "$REPO/skills" "$REPO/plugins" -name SKILL.md -not -path '*/deprecated/*' -print0 2>/dev/null)

while IFS= read -r -d '' agent; do
  link "$agent" "$AGENT_DEST/$(basename "$agent")"
done < <(find "$REPO/plugins" -path '*/agents/*.md' -not -path '*/skills/*' -print0 2>/dev/null)
