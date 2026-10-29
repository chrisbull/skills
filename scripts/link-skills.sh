#!/usr/bin/env bash
# Symlink every skill in this repo (except deprecated/) into the local
# harness skill directories, so `git pull` keeps installed skills current.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DESTS=("$HOME/.claude/skills" "$HOME/.agents/skills")

while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  for dest in "${DESTS[@]}"; do
    mkdir -p "$dest"
    target="$dest/$name"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "skip $name: $target exists and is not a symlink" >&2
      continue
    fi
    ln -sfn "$src" "$target"
    echo "linked $name -> $target"
  done
done < <(find "$REPO/skills" -name SKILL.md -not -path '*/deprecated/*' -print0)
