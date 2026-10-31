---
name: crawl4ai-setup
description: Run a local Crawl4AI Docker server and connect it to Claude Code over MCP. Pass --update to move to the latest image.
disable-model-invocation: true
---

# Crawl4AI setup

Claude Code only: Codex and other agents are untested, so stop and tell the user if you are running in one.

The script is safe to re-run, so it also repairs a broken setup. It needs Docker and the `claude` CLI, and does not need the pip package.

## Steps

1. Run `scripts/setup.sh` from this skill's folder, adding `--update` if the user asked to update or a failure message calls for it.

   Done when it exits 0 after printing `setup verified`. On a non-zero exit, follow its `error:` line, and ask before freeing a port or removing anything the script refused to touch.

2. Check a real crawl through MCP. The current session can't see a newly added server, so use a new one, started from a temporary directory:

   ```bash
   cd "$(mktemp -d)" && claude -p "Call the crawl4ai MCP md tool on https://example.com and quote the first sentence it returns. If the tool is unavailable or errors, say so." --allowedTools mcp__crawl4ai__md
   ```

   Done when the reply quotes text from the page. A reply reporting that the tool is unavailable or errored means setup failed: report it as failed.

3. Tell the user:
   - Restart Claude Code to get the tools in this session.
   - Docker has to start at login for the server to come back after a reboot.
   - The token is in `~/.crawl4ai/docker-server.env` and `~/.claude.json`, so neither file should be shared or committed.

## Why the script differs from Crawl4AI's docs

- **Token on MCP:** the docs' `claude mcp add` command sends no token, but the server answers 401 without one. The script adds an `Authorization` header.
- **Local only:** the port is published on `127.0.0.1`, because this server drives a browser for whoever holds the token and only this machine needs it.
- **Per-machine token:** each machine generates its own and keeps it out of the repo, so a leak stays on one machine.
