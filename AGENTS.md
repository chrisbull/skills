# Repo rules

This repo holds my agent skills and ships them as one Claude Code plugin (`chrisbull-skills`).

## Layout

Skills live in bucket folders under `skills/`. Each skill is a folder with a `SKILL.md` and an `agents/openai.yaml`.

- `engineering/`: code and agent work
- `productivity/`: non-code workflow tools
- `in-progress/`: drafts, not shipped in the plugin
- `deprecated/`: retired, not shipped in the plugin

Create a bucket folder (with its own `README.md`) the first time a skill goes in it.

## Adding or changing a skill

1. Put the skill at `skills/<bucket>/<skill-name>/SKILL.md`. The folder name must match the `name` in the frontmatter.
2. Add `agents/openai.yaml` beside it with `interface.display_name` and `interface.short_description`.
3. For a shipped bucket (`engineering/`, `productivity/`), add the skill path to the `skills` array in `.claude-plugin/plugin.json`, and list it in both the bucket `README.md` and the top-level `README.md`, with the name linked to its `SKILL.md`.
4. Skills in `in-progress/` and `deprecated/` appear in neither the plugin manifest nor the top-level `README.md`.
5. Run `scripts/check.sh`. It must pass before committing.

## Invocation

Every skill is one of two kinds. Keep the two harness settings in sync.

- **Model-invoked** (default): the model or the user can fire it. The `description` is written for the model, with trigger phrasing ("Use when...").
- **User-invoked**: only the user can fire it, by typing its name. Set `disable-model-invocation: true` in the `SKILL.md` frontmatter and `policy.allow_implicit_invocation: false` in `agents/openai.yaml`. The `description` is a one-line human summary.

READMEs group skills under **User-invoked** and **Model-invoked**.

When one skill depends on another, write an explicit instruction to call the Skill tool with the named skill. A user-invoked skill can't be called that way; tell the user to run it instead.

## Versioning

`version` in `.claude-plugin/plugin.json` follows semver. Bump it when a shipped skill is added, removed, or changes behaviour.

## Local install

`scripts/link-skills.sh` symlinks every skill outside `deprecated/` into `~/.claude/skills` and `~/.agents/skills`, so a `git pull` keeps them current. Re-run it after adding, removing, or renaming a skill.
