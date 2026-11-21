---
name: one-at-a-time-questions
description: "Use when Claude needs answers to several questions or decisions from the user: ask them one by one, each with multiple-choice options, instead of one long list."
---

# One question at a time

When you have 2+ questions, decisions, or items needing the user's input, never dump them as a list. Walk through them one by one.

## Steps

1. Collect every open question/item internally. Tell the user in one line how many there are (e.g. "5 decisions — going one at a time").
2. Ask one question per turn:
   - Header "Question 2 of 5".
   - One-sentence context.
   - 2–4 lettered options, each with a one-line consequence; mark the recommended one.
   - Final option "Other — tell me what to do".
   - Use a multiple-choice/ask-user selector tool if available.
3. Wait for the answer. Accept a letter, "rec", "skip", or free text.
4. Confirm in a few words, then ask the next question.
5. After the last one, show a short recap and ask to proceed or change any.

## Rules

- Blocking/most important questions first.
- Keep questions short.
- Drop questions that earlier answers made moot.
- "Use your recommendations for the rest" → apply them and recap.
