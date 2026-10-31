# Worked example

## The session

A test suite failed with `ReferenceError: Cannot access 'UserService' before initialization`, although the app ran fine. Two attempts at reordering imports moved the failure elsewhere. `npx madge --circular --extensions ts,tsx src/` then showed a cycle through a barrel file. Importing the module directly removed the cycle, and the tests passed.

## Judging it

"When a TypeScript import fails at runtime with 'before initialization' and reordering imports only moves the error, look for a cycle with madge, because the module was read before it finished loading."

- Recurring: any TypeScript project.
- Costly to rediscover: the error never mentions a cycle, and it cost two failed attempts.
- Recognisable: exact error text.
- Verified: the tests passed after the fix.

Result: write a user-level skill.

## The result

```markdown
---
name: typescript-before-initialization-cycle
description: "ReferenceError: Cannot access 'X' before initialization" in TypeScript that moves when imports are reordered. Use when an import is undefined at runtime or tests fail while the app runs.
metadata:
  created-by: continuous-learning
  verified: 2026-10-30
---

# Circular imports behind "before initialization"

## Situation
`ReferenceError: Cannot access 'X' before initialization`. Type-checking passes, and reordering imports moves the error.

## Cause
A module is read before it finishes loading, because of an import cycle. Barrel files often hide the cycle.

## Do this
1. Run `npx madge --circular --extensions ts,tsx src/`.
2. Break the cycle: import from the module rather than its barrel, use `import type` for types, or move shared code into a new module.

## Confirm
madge reports no cycles and the original failure is gone.
```

## Lessons that fail

| Lesson | Result | Why |
|---|---|---|
| "Run `npm test` to run the tests here" | Drop | One lookup in `package.json` |
| "`Array.map` returns a new array" | Drop | Not costly to rediscover |
| "The fix is probably to raise the timeout" | Drop | Never verified |
| "This team chose Postgres over MySQL for its JSON support" | Project notes | A record of a choice, with nothing to trigger on |
| "Generate migrations here with `make migration`, because it updates a checksum CI verifies" | Project skill | One project, but it changes what an agent does |
| "Restart my laptop's VPN when staging times out" | Drop | One machine's quirk, so not recurring |
