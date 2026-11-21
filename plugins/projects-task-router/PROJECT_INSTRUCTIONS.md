# Project instructions for the coordinator

Paste the block below into **Project settings > Memory > Project instructions** in Claude Projects. It tells the coordinator to size each thread before starting it. Threads started before you paste it don't pick it up.

The coordinator can't load plugin agents. Thread model and effort are project-wide settings, and the docs only offer one per-task override: naming a model in the task text. So this block is best-effort. The routing that always works happens inside each thread, through the projects-task-router skill and its workers.

```text
Sizing threads: before starting a thread for implementation work, decide what it needs and say so in the task text.

1. Many steps or files (a feature, a refactor, a bug hunt across modules): the thread plans and delegates, so it needs a strong model. Open the task text with "Use Opus." ("Use Fable." for the hardest problems, see 2) and end it with "Use the projects-task-router skill to plan, delegate to workers and review."

2. One focused task: open the task text with "Use Opus." Open it with "Use Fable." instead only for the hardest work: subtle algorithms, concurrency, many interacting states, bugs that beat earlier attempts. Pick Fable only when the task plainly fits it.

3. Questions, reviews of a plan, and one-line changes: no sizing, handle them as usual.

Design decisions (anything a user sees) belong to the thread that owns the work, never to a worker it delegates to, unless the user asks for that.
```
