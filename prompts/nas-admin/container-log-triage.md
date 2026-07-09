# Container log triage

For quickly making sense of noisy `docker compose logs` output.

## Prompt

```
Here are logs from a container that's misbehaving. Help me find the actual problem.

Container: <name>
Symptom: <e.g. keeps restarting, slow, not responding on its port>
Logs:
<paste last 50-100 lines>

Tell me:
1. The specific line(s) that indicate the real error (ignore routine/info-level noise)
2. What that error most likely means
3. The next diagnostic command to run, if the logs alone aren't conclusive
```

## Notes

- Good fit for `qwen2.5-coder:7b`.
- For this project's own containers specifically, check
  [`docs/troubleshooting.md`](../../docs/troubleshooting.md) first — it may already cover the
  symptom without needing a model call.
