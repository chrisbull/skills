# task-router

A Claude Code plugin that sorts work by kind of difficulty and runs each piece on the model that fits it. The session (or a Claude Projects thread) acts as the router: it plans, owns design, hands each task to a worker subagent, and reviews what comes back.

## What ships

- **Skill** [`task-router`](./skills/task-router/SKILL.md) (model-invoked): the router's playbook. Claude starts it for multi-step implementation, debugging or refactoring work; you can also run `/task-router <task>`.
- **Agents**, one per tier. The router picks the cheapest one that gets the task right the first time:

  | Agent | Model / effort | For |
  | --- | --- | --- |
  | [`worker-quick`](./agents/worker-quick.md) | Sonnet / low | mechanical edits, config, running builds and tests |
  | [`worker-standard`](./agents/worker-standard.md) | Sonnet / medium | routine features, fixes with a known cause |
  | [`worker-precise`](./agents/worker-precise.md) | Opus / high | delicate but well-understood changes |
  | [`worker-deep`](./agents/worker-deep.md) | Opus / xhigh | unfamiliar code, unknown root cause |
  | [`worker-frontier`](./agents/worker-frontier.md) | Fable / high | the hardest logic and bugs; design features on request |

- **Coordinator block** [`PROJECT_INSTRUCTIONS.md`](./PROJECT_INSTRUCTIONS.md): text to paste into a Claude Project's instructions, so the coordinator names a model when it starts a thread.

## Install

In Claude Code:

```text
/plugin install task-router --marketplace chrisbull/skills
```

In **Claude Projects**, enable it under Project settings > Plugins. Repo settings (`enabledPlugins`) don't reach project threads. Each new thread then loads the skill and the five workers. Set the project's thread model to Opus or Fable, since the thread is the router. Then paste the coordinator block into the project instructions.

Without access to Fable, change `model:` in `agents/worker-frontier.md` to `opus`.

## How it routes

- **Kind of difficulty decides the tier, not size.** Insight needed: Deep. Thoroughness needed: Precise. A task that needs both is split in two: Deep investigates and writes the brief, Precise implements it.
- **Torn between two tiers, the router takes the higher one.** Frontier is the exception: a reserve tier, used only when a task plainly fits it.
- **Design and the final call stay with the router.** Workers never make visual or UX decisions unless the user asks for a bounded design feature, which goes to Frontier.
- **Every worker report gets checked.** The router reads the diff, re-runs cheap checks, and accepts the task or returns it with a list of defects, two rounds at most.
