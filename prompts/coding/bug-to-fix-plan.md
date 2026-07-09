# Bug report to fix plan

Turns a rough bug description into a scoped investigation/fix plan — useful before handing a bug
off to a coding assistant or fixing it yourself.

## Prompt

```
Help me turn this bug report into an investigation plan.

Symptom: <what's happening>
Expected behavior: <what should happen instead>
Relevant code/logs/error messages:
<paste>

Give me:
1. Most likely root causes, ranked by probability
2. What to check first for each (specific file/function/log to look at)
3. A suggested fix approach once the cause is confirmed
4. Anything that would need a regression test afterward
```

## Notes

- Good fit for `qwen2.5-coder:7b`.
- Pairs well with [`docker-troubleshooting.md`](../nas-admin/docker-troubleshooting.md) when the
  bug is infrastructure-related rather than application code.
