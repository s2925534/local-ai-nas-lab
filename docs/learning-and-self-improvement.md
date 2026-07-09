# Learning and self-improvement

Status: **documented concept for Phases 8–9, not implemented in the MVP.** All flags referenced
here default to `false` in `.env.example`. This document exists so the near-term and far-future
directions are planned before any of it is built, per the project's "start small and stable"
constraint.

## Why this exists

The realistic near-term "learning" this project can do is **not** retraining a model. It is capturing
what worked, what didn't, and what you corrected, then feeding that back in as context and better
prompts. Actual model training is a separate, far-future, hardware-gated track (Phase 9).

## Near-term realistic learning (Phase 8)

What gets captured:

- User feedback logs (free-text notes on a response).
- Ratings (e.g. thumbs up/down, or a simple scale).
- Corrections (what the user changed the answer to).
- Accepted answers (used as-is, positive signal).
- Rejected answers (negative signal, ideally with a reason).
- Preferred formats (e.g. "always answer in bullet points for research summaries").
- Project rules (durable statements like "never use em dashes", "always ask before assuming a
  library version").
- Prompt improvements (a refined version of a prompt template that worked better).

How it would be used:

- RAG/memory retrieval: relevant rules/feedback/examples surfaced as context before a new prompt is
  sent to the model.
- Evaluation harness: a fixed set of test prompts with expected qualities, run after any prompt
  template or model change to catch regressions.

## Storage ideas (Phase 8, future)

| Data | Format | Why |
|---|---|---|
| Project rules | Markdown (`memory/rules/*.md`) | Human-readable, human-editable, diff-friendly |
| Feedback log | JSONL (`memory/feedback/*.jsonl`) | Append-only, simple, streams well |
| Structured metadata (later) | SQLite | Queryable once volume grows past what grep/jq handles well |
| Semantic memory (later) | Vector search | Needed once retrieval-by-similarity beats retrieval-by-keyword |
| Versioning | Git | Rules and prompt templates are just files — history for free |

`${LOCAL_AI_BASE_PATH}/memory/` already has placeholder subfolders (`rules/`, `feedback/`,
`evals/`, `datasets/`) created by `scripts/create-folders.sh` in the MVP — the folders exist, the
logic that writes to them does not yet.

## Future API ideas (Phase 8, not implemented)

Sketched only, so a future local API wrapper (Phase 5,
`ENABLE_LOCAL_AI_API`) has a natural place to add these:

```
POST /feedback               — record a rating/comment on a response
POST /remember                — store a durable rule or fact
POST /forget                  — remove a stored rule or fact
POST /rate-answer              — quick thumbs up/down on a response
POST /accept-correction        — record a user's correction to a response
POST /generate-improved-prompt — propose a refined prompt template from feedback history
POST /search-memory            — retrieve relevant rules/feedback/examples for a query
```

None of these endpoints exist yet — see [`future-flags.md`](future-flags.md) for the flags that
would gate their implementation.

## Far-future personal model path (Phase 9, not implemented)

This is explicitly **far future**, opt-in, and gated behind better hardware than the NAS. In order:

1. Curate feedback data — review what's in `memory/feedback/` and `memory/rules/` for quality and
   relevance.
2. Build datasets from accepted corrections and high-quality outputs (`ENABLE_DATASET_CURATOR`).
3. Evaluate datasets before using them for anything — check for bias, duplication, and
   provenance issues.
4. Fine-tune a small open model, on hardware better than the NAS (`ENABLE_FINE_TUNING_EXPERIMENTS`,
   Phase 6 hardware expansion).
5. Explore model distillation carefully — comparing outputs across the multiple local models this
   project already runs, and using high-quality examples as training/evaluation material
   (`ENABLE_MODEL_DISTILLATION_EXPERIMENTS`).
6. Build toward a "personal model" that does not start from scratch — it builds on an open base
   model plus this project's feedback data, prompt library, memory store, and curated examples
   (`ENABLE_PERSONAL_MODEL_PATH`).

Explicit constraints on this path, regardless of when it's picked up:

- **Do not assume a locally fine-tuned model can copy proprietary model capabilities.** Training on
  your own corrections and accepted outputs is not the same as replicating a frontier model's
  behavior, and this project should not claim otherwise.
- **Respect model licenses, output provenance, and privacy** for every model and every dataset
  involved. Don't use outputs in ways their license disallows, and don't include content you don't
  have the right to use in a training set.
- **Do not implement uncontrolled self-modification.** Every step above is a manual, reviewed,
  evaluated action taken by you — not an automatic loop that retrains itself on its own outputs
  without oversight.
- **Training/fine-tuning requires hardware beyond the NAS.** A Synology DS1525+ is not a training
  device; this track assumes a future GPU workstation or similar (see Phase 6 in
  [`phase-plan.md`](phase-plan.md)).

## What this document is not

It is not a spec for an implementation that exists today. `ENABLE_FEEDBACK_LEARNING_LOOP`,
`ENABLE_LOCAL_MEMORY_STORE`, `ENABLE_PROMPT_OPTIMIZER`, `ENABLE_EVALUATION_HARNESS`,
`ENABLE_FINE_TUNING_EXPERIMENTS`, `ENABLE_PERSONAL_MODEL_PATH`, and
`ENABLE_MODEL_DISTILLATION_EXPERIMENTS` all default to `false` in `.env.example` precisely because
none of this is built yet.
