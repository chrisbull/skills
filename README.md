# Chris Bull's Skills

The agent skills I use day to day. Each one is small, does one job, and can be read and changed in a few minutes. Take them, adapt them, make them yours.

## Install

Each skill installs on its own, so you call it by name (`/skill-finder`).

```bash
npx skills@latest add chrisbull/skills -g -a claude-code
```

Drop `-a claude-code` to pick other agents (Codex, Cursor and more). Add `-s <skill-name>` to install only some skills. Update with `npx skills@latest update`.

## Skills

### Engineering

Full list: [skills/engineering](./skills/engineering/README.md).

#### User-invoked

- **[crawl4ai-setup](./skills/engineering/crawl4ai-setup/SKILL.md)**: Run a local Crawl4AI Docker server and connect it to Claude Code over MCP.

#### Model-invoked

- **[agent-harness-tuner](./skills/engineering/agent-harness-tuner/SKILL.md)**: Tune an agent's role card and skills against its eval suite (reflect, edit, probe, compose), then validate once on a held-out set. Follows the method of Google Research's [Harness²](https://github.com/google-research/harness2).
- **[continuous-learning](./skills/engineering/continuous-learning/SKILL.md)**: Autonomously turn hard-won session knowledge into new skills, saved locally and reported in one line.
- **[skill-finder](./skills/engineering/skill-finder/SKILL.md)**: Search the claude-plugins.dev registry for a skill that fits a niche task and install it with your approval, or write a new one when none fits. From [ckorhonen/claude-skills](https://github.com/ckorhonen/claude-skills) (MIT).

## Plugins

Standalone Claude Code plugins, each installed on its own from this repo's marketplace (`/plugin install <plugin-name> --marketplace chrisbull/skills`).

- **[task-router](./plugins/task-router/README.md)**: Plans work, sorts it into tasks by kind of difficulty, and hands each one to a worker subagent on the right model (Sonnet, Opus or Fable) and effort, then reviews the results. Built for Claude Projects threads, with a block for the coordinator's project instructions.

## Contributing

Repo rules for humans and agents are in [AGENTS.md](./AGENTS.md).

## License

[MIT](./LICENSE)
