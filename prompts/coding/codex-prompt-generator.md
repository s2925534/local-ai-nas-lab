# Coding prompt generator

Use this with `qwen2.5-coder:7b` to turn a spec or a vague coding request into a well-scoped prompt
you can hand to a stronger coding assistant (Claude Code, Codex, etc.) later.

## Prompt

```
I need to turn this into a clear, scoped coding task for an AI coding assistant.

Context: <paste relevant spec, code snippet, or description>
Goal: <what you actually want built or fixed>

Write the task as:
1. Objective (one sentence)
2. Relevant files/context the assistant should look at first
3. Constraints (language, framework, style, things not to change)
4. Acceptance criteria (how to know it's done)
5. Explicitly out of scope

Keep it tight enough that a coding assistant with no other context could start immediately.
```

## Notes

- This local model is meant to help you *scope* work, not necessarily write the final
  production code — use it to save time drafting the task description, then hand the result to
  whichever coding assistant you're paying for (or another local model) to implement.
