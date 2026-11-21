# Repo rules

This repo holds my agent skills and ships them as a Claude Code plugin (`chrisbull-skills`), plus standalone plugins under `plugins/`.

## Layout

Skills live in bucket folders under `skills/`. Each skill is a folder with a `SKILL.md` and an `agents/openai.yaml`.

- `engineering/`: code and agent work
- `productivity/`: non-code workflow tools
- `in-progress/`: drafts, not shipped in the plugin
- `deprecated/`: retired, not shipped in the plugin

Create a bucket folder (with its own `README.md`) the first time a skill goes in it.

## Standalone plugins

Work that needs more than skills (subagent definitions, hooks) ships as its own plugin under `plugins/<plugin-name>/`, so it can be installed or enabled (for example in a Claude Project) without the rest of `chrisbull-skills`.

- Layout: `.claude-plugin/plugin.json`, a `README.md`, `agents/<agent-name>.md` for subagents, and skills. A plugin with one skill keeps it at the plugin root (`SKILL.md`, `agents/openai.yaml`, manifest `"skills": ["./"]`), so its skill name matches the plugin folder and skillshare can link the whole plugin as one skill folder, which Claude Code loads as `<name>@skills-dir`. A plugin with several skills uses `skills/<skill-name>/SKILL.md`. Each skill follows the same rules as above.
- The manifest's `name` matches the folder. Its `skills` and `agents` arrays list every skill folder and agent file in the plugin.
- Add the plugin to `.claude-plugin/marketplace.json` with `source: "./plugins/<plugin-name>"`, and list it under **Plugins** in the top-level `README.md`, linked to its `README.md`.
- Each plugin keeps its own `version`; bump it when it changes behaviour.

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

Install through skillshare, which shares skills with the other Mac. Here, skillshare's source holds `_chrisbull` as a symlink to this checkout (`skillshare link ~/projects/skills --name _chrisbull --enable`), so uncommitted edits load in the next session without a commit. Its tracked-repo record in skillshare's `.metadata.json` makes other machines clone `chrisbull/skills` instead (`skillshare pull`, then `skillshare install`). Run `skillshare sync` after adding, removing, or renaming a skill. Don't write symlinks into `~/.claude/skills` or `~/.agents/skills` by hand, and don't use `npx skills`: skillshare treats both as unmanaged.
