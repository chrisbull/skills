#!/usr/bin/env bash
# Check that the plugin manifest, READMEs and skill folders agree.
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

while IFS= read -r skill_md; do
  dir="$(dirname "$skill_md")"
  name="$(basename "$dir")"
  bucket="$(basename "$(dirname "$dir")")"

  fm_name="$(sed -n 's/^name: *"\{0,1\}\([^"]*\)"\{0,1\} *$/\1/p' "$skill_md" | head -1)"
  [ "$fm_name" = "$name" ] || err "$skill_md: frontmatter name '$fm_name' does not match folder '$name'"
  grep -q '^description:' "$skill_md" || err "$skill_md: missing description"

  yaml="$dir/agents/openai.yaml"
  if [ ! -f "$yaml" ]; then
    err "$dir: missing agents/openai.yaml"
  else
    user_fm=0; user_yaml=0
    grep -q '^disable-model-invocation: *true' "$skill_md" && user_fm=1
    grep -q 'allow_implicit_invocation: *false' "$yaml" && user_yaml=1
    [ "$user_fm" = "$user_yaml" ] || err "$name: disable-model-invocation and allow_implicit_invocation disagree"
  fi

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

if command -v claude >/dev/null; then
  claude plugin validate . || fail=1
fi

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
