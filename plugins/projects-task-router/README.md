# projects-task-router

**Model routing for [Claude Projects](https://code.claude.com/docs/en/claude-projects).** In a Claude Project, the coordinator starts a thread for each piece of work, and every thread runs on one project-wide model and effort. This plugin lets each thread split its work up and run every piece on the model and effort it actually needs.

It also works in a plain Claude Code session, where that session acts as the router.

## How it fits into a Claude Project

```
 you ──▶ coordinator ──▶ thread (the router) ──▶ worker subagents
          picks or        plans, designs,          quick · standard · precise
          starts a        delegates, reviews       deep · frontier
          thread
```

- **Coordinator:** reads each message and decides which thread does the work. It can't load plugin agents, so this plugin can only nudge it: paste [`PROJECT_INSTRUCTIONS.md`](./PROJECT_INSTRUCTIONS.md) into the project instructions, and it names a model ("Use Opus." or "Use Fable.") whenever it starts a thread.
- **Thread:** a full Claude Code session that loads the plugin. On multi-step work, the router skill takes over. It plans, keeps design decisions for itself, hands each task to a worker, and checks every result.
- **Workers:** subagents with their model and effort fixed per tier. They do one task from a self-contained brief and report back.

The coordinator decides *which* thread does the work. The router decides *how* a thread splits it up. They work at different levels, so they don't conflict.

## Set it up in a Claude Project

1. **Enable the plugin** under Project settings > Plugins. Each new thread loads the skill and the five workers. A repo's own plugin settings (`enabledPlugins`) don't reach project threads.
2. **Set the thread model** to Opus or Fable at high effort, under Project settings > General. Each thread is the router, so it needs a strong model. The workers handle the cheap work.
3. **Paste the coordinator block** from [`PROJECT_INSTRUCTIONS.md`](./PROJECT_INSTRUCTIONS.md) into Project settings > Memory > Project instructions. Threads already running don't pick up the change.
4. **Enable only one orchestrator.** Leave other routing plugins off in this project, so a thread doesn't switch between systems.

Threads started before the plugin was enabled won't have it. Start a new thread to pick it up.

## Use it in Claude Code

```text
/plugin marketplace add chrisbull/skills
/plugin install projects-task-router@chrisbull
```

The skill starts on its own for multi-step implementation, debugging or refactoring work. You can also run `/projects-task-router <task>`.

## What ships

- **Skill** [`projects-task-router`](./SKILL.md) (model-invoked): the router's playbook.
- **Agents**, one per tier. The router picks the cheapest one that gets the task right the first time:

  | Agent | Model / effort | For |
  | --- | --- | --- |
  | [`worker-quick`](./agents/worker-quick.md) | Opus / low | mechanical edits, config, running builds and tests |
  | [`worker-standard`](./agents/worker-standard.md) | Opus / medium | routine features, fixes with a known cause |
  | [`worker-precise`](./agents/worker-precise.md) | Opus / high | delicate but well-understood changes |
  | [`worker-deep`](./agents/worker-deep.md) | Opus / xhigh | unfamiliar code, unknown root cause |
  | [`worker-frontier`](./agents/worker-frontier.md) | Fable / high | the hardest logic and bugs; design features on request |

- **Coordinator block** [`PROJECT_INSTRUCTIONS.md`](./PROJECT_INSTRUCTIONS.md): text for a Claude Project's instructions.

Without access to Fable, change `model:` in `agents/worker-frontier.md` to `opus`.

## How it routes

- **Kind of difficulty decides the tier, not size.** Insight needed: Deep. Thoroughness needed: Precise. A task that needs both is split in two: Deep investigates and writes the brief, Precise implements it.
- **Torn between two tiers, the router takes the higher one.** Frontier is the exception: a reserve tier, used only when a task plainly fits it.
- **Design and the final call stay with the router.** Workers never make visual or UX decisions unless the user asks for a bounded design feature, which goes to Frontier.
- **Every worker report gets checked.** The router reads the diff, re-runs cheap checks, and accepts the task or returns it with a list of defects, two rounds at most.

## Limits

- Claude Projects is in beta (Pro, Max and Ultra plans) and works only on claude.ai/code.
- The coordinator block is best-effort. The docs only offer one per-task model override: naming a model in the task text.
- The docs don't say whether the project's "Thread effort" setting overrides a worker's own effort.
