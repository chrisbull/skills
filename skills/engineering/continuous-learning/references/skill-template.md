# Template for a learned skill

Keep it under about 60 lines. Drop any section with nothing to say.

```markdown
---
name: kebab-case-name
description: <Exact error text or situation first>. Use when <distinct trigger>, or when <distinct trigger>.
metadata:
  created-by: continuous-learning
  verified: YYYY-MM-DD
---

# Title

## Situation
What the agent sees: the exact error text, the symptom, the versions involved.

## Cause
Why it happens. This lets a future agent adapt when the details differ.

## Do this
Numbered steps with the exact commands or code.

## Confirm
The output or state that proves it worked.

## Limits
Where this stops applying, and what looked right but failed. Mark anything taken from docs but not seen in the session.

## References
Official docs consulted.
```
