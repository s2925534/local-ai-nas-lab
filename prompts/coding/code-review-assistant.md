# Code review assistant

## Prompt

```
Review this code for correctness bugs and obvious risks. Don't comment on style unless it hides a
real bug.

Code:
<paste code or diff>

Context: <what this code is supposed to do>

For each issue found, give:
1. The specific line(s) or snippet
2. What's wrong and the concrete input/scenario that triggers it
3. A suggested fix (brief, not a full rewrite unless necessary)

If you don't find any real issues, say so plainly instead of inventing minor nitpicks.
```

## Notes

- Best fit for `qwen2.5-coder:7b`.
- This is a lightweight second pair of eyes for local/low-stakes changes — for anything going into
  production, still get a real review (human, or a stronger paid coding assistant) on top of this.
