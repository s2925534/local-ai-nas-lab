# Docker/NAS troubleshooting assistant

## Prompt

```
Help me troubleshoot a Docker/Synology NAS issue.

Symptom: <what's happening>
What I've already checked: <logs, commands run, etc.>
Relevant output/logs:
<paste output>

Give me a short list of likely causes ranked by probability, and the next command(s) I should run
to narrow it down. Don't suggest destructive commands (deleting volumes, force-removing containers)
unless there's no safer diagnostic step left.
```

## Notes

- Good fit for `qwen2.5-coder:7b` — it tends to be stronger on shell/Docker specifics than the
  general small model.
- For issues specific to this project's own stack, check
  [`docs/troubleshooting.md`](../../docs/troubleshooting.md) first — it may already have the
  answer without needing a model call.
