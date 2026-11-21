#!/usr/bin/env bash
# Check that the plugin manifests, marketplace, READMEs and skill folders agree.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"
fail=0
err() { echo "error: $*" >&2; fail=1; }

manifest="$(node -e 'console.log(require("./.claude-plugin/plugin.json").skills.join("\n"))')"

# Every manifest entry exists and sits in a shipped bucket.
while IFS= read -r path; do
  [ -f "$path/SKILL.md" ] || err "plugin.json lists $path but $path/SKILL.md is missing"
  case "$path" in
    ./skills/engineering/*|./skills/productivity/*) ;;
    *) err "plugin.json lists $path, which is not in a shipped bucket" ;;
  esac
done <<< "$manifest"

fm_name() { sed -n 's/^name: *"\{0,1\}\([^"]*\)"\{0,1\} *$/\1/p' "$1" | head -1; }

# Frontmatter name, description, openai.yaml and invocation settings agree.
check_skill_files() {
  local dir="$1" skill_md="$1/SKILL.md" name yaml user_fm=0 user_yaml=0
  name="$(basename "$dir")"
  [ "$(fm_name "$skill_md")" = "$name" ] || err "$skill_md: frontmatter name '$(fm_name "$skill_md")' does not match folder '$name'"
  grep -q '^description:' "$skill_md" || err "$skill_md: missing description"

  yaml="$dir/agents/openai.yaml"
  if [ ! -f "$yaml" ]; then
    err "$dir: missing agents/openai.yaml"
    return
  fi
  grep -q '^disable-model-invocation: *true' "$skill_md" && user_fm=1
  grep -q 'allow_implicit_invocation: *false' "$yaml" && user_yaml=1
  [ "$user_fm" = "$user_yaml" ] || err "$name: disable-model-invocation and allow_implicit_invocation disagree"
}

while IFS= read -r skill_md; do
  dir="$(dirname "$skill_md")"
  name="$(basename "$dir")"
  bucket="$(basename "$(dirname "$dir")")"

  check_skill_files "$dir"

  grep -q "($name/SKILL.md)\|(./$name/SKILL.md)" "skills/$bucket/README.md" 2>/dev/null \
    || err "$name: not listed in skills/$bucket/README.md"

  case "$bucket" in
    engineering|productivity)
      grep -qx "$dir" <<< "$manifest" || err "$name: missing from plugin.json skills"
      grep -q "($dir/SKILL.md)" README.md || err "$name: not listed in README.md"
      ;;
    *)
      grep -qx "$dir" <<< "$manifest" && err "$name: in $bucket/ but listed in plugin.json"
      grep -q "($dir/SKILL.md)" README.md && err "$name: in $bucket/ but listed in README.md"
      ;;
  esac
done < <(find ./skills -name SKILL.md | sort)

# Standalone plugins under plugins/<name>/: manifest, files on disk, marketplace and README agree.
marketplace_sources="$(node -e 'console.log(require("./.claude-plugin/marketplace.json").plugins.map(p => p.source).join("\n"))')"
for manifest_file in ./plugins/*/.claude-plugin/plugin.json; do
  [ -f "$manifest_file" ] || continue
  pdir="$(dirname "$(dirname "$manifest_file")")"
  pname="$(basename "$pdir")"

  [ "$(node -e 'console.log(require(process.argv[1]).name)' "$manifest_file")" = "$pname" ] \
    || err "$manifest_file: name does not match folder '$pname'"
  grep -qx "$pdir" <<< "$marketplace_sources" || err "$pname: missing from marketplace.json"
  grep -q "($pdir/README.md)\|($pdir)" README.md || err "$pname: not listed in README.md"
  [ -f "$pdir/README.md" ] || err "$pname: missing README.md"

  # Skill paths normalised to "." (plugin root) or "./sub/dir", no trailing slash.
  listed_skills="$(node -e '
    const s = require(process.argv[1]).skills || [];
    console.log(s.map(p => p.replace(/\/+$/, "") || ".").join("\n"));
  ' "$manifest_file")"
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    sdir="$pdir/${rel#./}"; [ "$rel" = "." ] && sdir="$pdir"
    [ -f "$sdir/SKILL.md" ] || { err "$pname lists $rel but $rel/SKILL.md is missing"; continue; }
    check_skill_files "$sdir"
  done <<< "$listed_skills"
  while IFS= read -r skill_md; do
    rel="$(dirname "$skill_md")"
    if [ "$rel" = "$pdir" ]; then rel="."; else rel="./${rel#"$pdir"/}"; fi
    grep -qx "$rel" <<< "$listed_skills" || err "$pname: $rel is not in its plugin.json skills"
  done < <(find "$pdir" -name SKILL.md | sort)

  listed_agents="$(node -e 'console.log((require(process.argv[1]).agents || []).join("\n"))' "$manifest_file")"
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    agent="$pdir/${rel#./}"
    [ -f "$agent" ] || { err "$pname lists $rel but it is missing"; continue; }
    [ "$(fm_name "$agent")" = "$(basename "$agent" .md)" ] || err "$agent: frontmatter name does not match file name"
    grep -q '^description:' "$agent" || err "$agent: missing description"
    grep -q '^model:' "$agent" || err "$agent: missing model"
  done <<< "$listed_agents"
  for agent in "$pdir"/agents/*.md; do
    [ -f "$agent" ] || continue
    grep -qx "./agents/$(basename "$agent")" <<< "$listed_agents" || err "$pname: $agent is not in its plugin.json agents"
  done

  if command -v claude >/dev/null; then
    claude plugin validate "$pdir" || fail=1
  fi
done

if command -v claude >/dev/null; then
  claude plugin validate . || fail=1
fi

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
