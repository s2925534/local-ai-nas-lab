# Model performance test log

A running log for comparing local models on the same prompts. Copy the table template below each
time you test a new model or re-test after a config change. This is a manual template for now —
an automated evaluation harness is future work (`ENABLE_EVALUATION_HARNESS`, see
[`../docs/future-flags.md`](../docs/future-flags.md)).

## Standard test prompts

Run these against each model you're evaluating:

1. **Rewrite:** "Rewrite this in a more professional tone: `hey can u send that file when u get a sec`"
2. **Summarise:** paste a few paragraphs of documentation and ask for a 3-bullet summary.
3. **App spec:** use [`../prompts/app-specs/full-app-spec-generator.md`](../prompts/app-specs/full-app-spec-generator.md) with a simple idea.
4. **Coding:** "Write a Python function that dedupes a list while preserving order, with a docstring."
5. **Document Q&A:** upload a short document in Open WebUI and ask a factual question about it.

## Log template

| Date | Model | Prompt # | Response quality (1-5) | Speed (subjective) | Notes |
|------|-------|----------|--------------------------|----------------------|-------|
|      |       |          |                          |                      |       |

## Notes

- This is a personal log, not a benchmark suite — the goal is to know which local model to reach
  for a given task, not to publish comparative scores.
- If a model performs poorly across the board, check `docs/troubleshooting.md` for CPU/RAM-related
  causes before concluding the model itself is the problem.
