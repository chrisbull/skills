#!/bin/sh
# Adds a pointer to the router skill to the session's context. Claude Code cuts
# skill descriptions when many skills are installed, and a skill without one
# never gets matched, so this keeps the router reachable either way.
cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"projects-task-router is installed. When a request needs several steps or files of implementation, debugging, refactoring or building, call the Skill tool with projects-task-router before starting: it plans the work, hands each task to a worker subagent on the right model and effort, and reviews the results. Skip it for questions, reading or explaining code, and single small edits."}}
JSON
