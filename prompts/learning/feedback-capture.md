# Feedback capture (future — not implemented)

This prompt template is a placeholder for the future feedback-capture feature described in
[`docs/learning-and-self-improvement.md`](../../docs/learning-and-self-improvement.md)
(`ENABLE_FEEDBACK_LEARNING_LOOP`). Nothing in this repo currently reads or writes structured
feedback — this file exists so the eventual implementation has a starting template.

## Intended shape (future)

```
Response being rated:
<the AI's response>

Rating: <accept / reject / partial>
What was right:
What was wrong or missing:
Preferred version (if you have one):
Reusable rule this implies (if any):
```

Once implemented, this would be appended as a structured record (e.g. JSONL) under
`${LOCAL_AI_BASE_PATH}/memory/feedback/`, per the storage design in
[`docs/learning-and-self-improvement.md`](../../docs/learning-and-self-improvement.md). For now,
feel free to use this template manually and save notes yourself wherever convenient.
