---
name: continuous-learning
description: Autonomously turn hard-won session knowledge into new skills. Use after a task involving a misleading error, repeated failed attempts, or an undocumented workaround; when the user corrects how something is done or the same workflow recurs; when a skill misled you; or when asked to "save this as a skill" or run a retrospective.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash(ls:*)
  - Bash(grep:*)
  - WebSearch
  - WebFetch
---

# Continuous Learning

You keep the skill library growing without being asked: spot a lesson, judge it, write it, report it in one line. The user's attention is the budget, so routine work ends silently and real lessons arrive as finished skills.

## 1. Spot the lesson

Name what this session taught you that you did not know at the start, as one sentence: "When <recognisable situation>, <what to do>, because <cause>." If nothing qualifies, end here and say nothing about this skill.

## 2. Judge it

The lesson earns a skill only if all four hold:

- **Recurring**: it applies to future work beyond this exact task.
- **Costly to rediscover**: starting from the symptom, docs, `--help` or a quick search would not have led straight to the answer. Separately documented facts that had to be connected through investigation count.
- **Recognisable**: a future agent could spot the situation from an error message, symptom or request.
- **Verified**: you saw it work in this session, through a passing test, a command's output or the user's confirmation.

A lesson that fails ends here, silently, with one exception: a **record** of a choice and its reason is not an instruction a future agent can trigger on, so it fails Recognisable. If the project has a memory or notes system, save the record there in that system's format and report it. A project-specific rule that changes what an agent does is still a skill.

See [the worked example](references/example.md) for calibration.

Credentials, personal data, private URLs and internal endpoints stay out of everything you save. Replace them with placeholders, or drop the lesson if it means nothing without them. If a live-looking credential appeared in the session, tell the user so they can rotate it.

## 3. Find its home

Search the skills listed in your context, then the user-level and project skills folders, with `grep -Rli` for the lesson's error text and key terms. Run `ls -la` on the folders to see which entries are symlinks. A missing folder holds no skills.

| What you find | What to do |
|---|---|
| Nothing covering this lesson | Create a new skill |
| A skill whose frontmatter has `metadata.created-by: continuous-learning`, and its entry is a real directory | Update it in place |
| Any other skill covering this lesson, or a symlink entry | Leave it unchanged, propose the edit, and create no duplicate |

Those other skills belong to someone else, and a symlink usually leads into a repo that the edit would silently change. A skill that only shares a topic with the lesson does not cover it.

Save new skills here, creating the folder if needed:

- **Lesson applies across projects**: `skills/` in the current harness's user config, such as `~/.claude/skills/` or `~/.agents/skills/`.
- **Lesson applies to this project**: `.claude/skills/` in the project, or wherever its instruction file says skills belong.

## 4. Check the facts

When the lesson depends on a library, tool or API, confirm it against the official docs, for the version in use if you know it, and link them under References. If the docs contradict what you saw, keep your observation and record the version. Lessons about this codebase alone need no research.

## 5. Write it

Follow [the template](references/skill-template.md). The description decides whether the skill ever fires, so lead with the exact error text or situation a future agent will have in front of it. The folder name and `name` must match.

An update to an existing skill states the new knowledge in the place it belongs, then bumps `metadata.verified`.

Read the saved file back to confirm the frontmatter and name are correct before reporting.

## 6. Report it

Writing to a skills folder or the project's notes is the limit of what you do on your own: committing, pushing and publishing wait for the user to ask. Close your reply with one line per outcome:

- `Learned: <name> (<path>): <the lesson>. Delete the folder to undo.`
- `Updated: <name> (<path>): <what changed>.`
- `Noted: <path>: <the record>.`
- `Proposed for <name>: <the exact text to add or change, and why>.`

## Retrospectives

When asked to review a session or "what did we learn", run steps 1 to 6 across the whole session. Write up to three skills, strongest first. List each rejected candidate with the criterion it failed, then close with the outcome lines. If nothing passed, say the session held nothing worth keeping.

## When a skill misled you

If a skill you followed in this session was wrong, stale or missing the fact that mattered, treat the correction as the lesson. It needs only the Verified criterion, because the misleading skill will keep costing time until it changes. Go to step 3. A skill you created gets fixed in place, or removed if its cause no longer exists. Anything else gets a proposed edit.
