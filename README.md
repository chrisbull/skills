<h1 align="center">Chris Bull's Skills</h1>

<p align="center">
  <em>Small skills. Sharp agents. No ceremony.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Claude%20Code-plugin-111111?style=flat-square" alt="Claude Code plugin">
  <img src="https://img.shields.io/badge/works%20with-Codex%20%C2%B7%20Cursor%20%C2%B7%20more-111111?style=flat-square" alt="Works with Codex, Cursor and more">
  <img src="https://img.shields.io/github/license/chrisbull/skills?style=flat-square&color=111111" alt="MIT license">
</p>

---

These are the agent skills I run every day. Each one fixes a specific way coding agents let me down: they forget what they learned, they guess at niche domains, they burn Opus on a rename, and they get tuned by vibes instead of evals.

No framework owns your process. Every skill is one folder you can read in a few minutes, and nothing breaks when you change it. Fork them, bend them, make them yours.

## Install in 30 seconds

Pick one route per agent. Installing two routes gives you every skill twice.

<details open>
<summary><strong>Claude Code</strong></summary>

```text
/plugin install chrisbull-skills --marketplace chrisbull/skills
```

The plugin keeps itself up to date. Skills show up namespaced, like `/chrisbull-skills:crawl4ai-setup`.

</details>

<details>
<summary><strong>skillshare</strong> (one source, every agent, every machine)</summary>

```bash
skillshare install chrisbull/skills --track --name chrisbull -g
skillshare sync
```

Pull new commits later with `skillshare update _chrisbull`.

</details>

<details>
<summary><strong>Any other agent, or editable copies</strong></summary>

```bash
npx skills@latest add chrisbull/skills -g
```

Choose your agents when prompted (Codex, Cursor, OpenCode and 70+ more). Add `-s <skill-name>` to take only some. Update with `npx skills@latest update`.

</details>

## Why these exist

### 1. Your agent forgets everything it figured out

It spends forty minutes cracking a misleading error, then the next session hits the same wall.

**[continuous-learning](./skills/engineering/continuous-learning/SKILL.md)** watches for hard-won knowledge (a workaround nobody documented, a correction you had to make twice, a workflow that keeps coming back) and turns it into a new skill on its own. You get one line telling you what it saved.

### 2. Your agent guesses at things it doesn't know

Unfamiliar API, niche domain, obscure tool. The agent improvises and sounds confident doing it.

**[skill-finder](./skills/engineering/skill-finder/SKILL.md)** searches the [claude-plugins.dev](https://claude-plugins.dev) registry for a skill that already knows the territory and installs it once you approve. If nothing fits, it writes one. From [ckorhonen/claude-skills](https://github.com/ckorhonen/claude-skills) (MIT).

### 3. Your agent's prompts get tuned by vibes

You tweak the role card, it feels better, and you have no idea whether it is.

**[agent-harness-tuner](./skills/engineering/agent-harness-tuner/SKILL.md)** tunes an agent's role card and skills against its eval suite: reflect, edit, probe, compose. Then it checks the result once on a held-out set so the score means something. Follows Google Research's [Harness²](https://github.com/google-research/harness2).

### 4. Your agent can't read the web properly

Half the pages it fetches come back as boilerplate, cookie banners and nav menus.

**[crawl4ai-setup](./skills/engineering/crawl4ai-setup/SKILL.md)** stands up a local [Crawl4AI](https://github.com/unclecode/crawl4ai) Docker server and wires it into Claude Code over MCP, so pages come back as clean markdown. Run `/crawl4ai-setup --update` to move to the latest image.

### 5. Your agent throws the same effort at every task

Max effort on a rename. Low effort on a race condition. Either way you pay for it.

**[projects-task-router](./plugins/projects-task-router/README.md)** makes the session a router. It plans the work, sorts each task by *kind* of difficulty, and hands it to a worker with the model and effort that fit:

```
                         ┌──────────────────────────┐
   your request  ──────▶ │  router: plan · design   │ ──────▶  reviewed, verified result
                         │  · review every result   │
                         └────────────┬─────────────┘
          ┌──────────────┬────────────┼──────────────┬──────────────┐
          ▼              ▼            ▼              ▼              ▼
       quick         standard      precise         deep          frontier
      Opus·low     Opus·medium    Opus·high      Opus·xhigh     Fable·high
     mechanical      routine      delicate      unfamiliar      hardest
```

Design calls and the final say never leave the router, and every worker report gets checked against the diff. It's built for [Claude Projects](https://code.claude.com/docs/en/claude-projects), where every thread otherwise runs on one project-wide model and effort. It also ships a block for the coordinator's project instructions, so new threads start on the right model too.

```text
/plugin install projects-task-router --marketplace chrisbull/skills
```

## The full list

### Skills

Everything in [skills/engineering](./skills/engineering/README.md), included in the `chrisbull-skills` plugin.

**User-invoked** (you type the name):

- **[crawl4ai-setup](./skills/engineering/crawl4ai-setup/SKILL.md)**: Run a local Crawl4AI Docker server and connect it to Claude Code over MCP.

**Model-invoked** (the agent reaches for them on its own):

- **[agent-harness-tuner](./skills/engineering/agent-harness-tuner/SKILL.md)**: Tune an agent's role card and skills against its eval suite, then validate once on a held-out set.
- **[continuous-learning](./skills/engineering/continuous-learning/SKILL.md)**: Turn hard-won session knowledge into new skills, saved locally and reported in one line.
- **[skill-finder](./skills/engineering/skill-finder/SKILL.md)**: Find and install a registry skill for a niche task, or write a new one when none fits.

### Plugins

Standalone, so you can install or enable one without the rest (`/plugin install <plugin-name> --marketplace chrisbull/skills`).

- **[projects-task-router](./plugins/projects-task-router/README.md)**: Model routing for Claude Projects. Route each task to a worker subagent on the right model and effort (Opus at low to xhigh, or Fable), then review the results.

## Contributing

House rules for humans and agents live in [AGENTS.md](./AGENTS.md). Run `scripts/check.sh` before you open a PR.

## License

[MIT](./LICENSE). Take what's useful.
