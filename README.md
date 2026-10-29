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

#### Model-invoked

- **[agent-harness-tuner](./skills/engineering/agent-harness-tuner/SKILL.md)**: Tune an agent's role card and skills against its eval suite (reflect, edit, probe, compose), then validate once on a held-out set. Follows the method of Google Research's [Harness²](https://github.com/google-research/harness2).
- **[skill-finder](./skills/engineering/skill-finder/SKILL.md)**: Search the claude-plugins.dev registry for a skill that fits a niche task and install it with your approval, or write a new one when none fits. From [ckorhonen/claude-skills](https://github.com/ckorhonen/claude-skills) (MIT).

## Contributing

Repo rules for humans and agents are in [AGENTS.md](./AGENTS.md).

## License

[MIT](./LICENSE)
