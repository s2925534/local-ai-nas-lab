# Phase plan

This project is built in small, independently-shippable phases. Each phase has a corresponding
section in [`TODO.md`](../TODO.md) with checkboxes. Do not start a later phase's *implementation*
before the earlier phase's acceptance criteria are met — documentation may reference future phases
freely, since the whole point is to plan ahead.

| Phase | Name                              | Status      |
|-------|------------------------------------|-------------|
| 0     | Planning and documentation foundation | In progress |
| 1     | MVP foundation                     | Not started |
| 2     | Deployer integration readiness     | Not started |
| 3     | Local usefulness                   | Not started |
| 4     | Domain exposure readiness          | Not started |
| 5     | Future private AI API              | Not started (planning only) |
| 6     | Future hardware expansion          | Not started (planning only) |
| 7     | Future portable local mode         | Not started (planning only) |
| 8     | Future feedback learning loop      | Not started (planning only) |
| 9     | Future model self-learning / personal model | Not started (planning only) |

## Phase 0 — Planning and documentation foundation

Markdown only. No executable code. Produces the files listed in the repository root and `docs/`,
plus `TODO.md`. Acceptance: docs describe the project clearly, divide work into phases, distinguish
MVP vs. near-future vs. far-future, and state the deployer/volume-path constraints explicitly.

## Phase 1 — MVP foundation

Smallest possible working local stack: `.env.example`, `.gitignore`, `docker-compose.yml` for
Ollama + Open WebUI, and four scripts (`create-folders.sh`, `bootstrap-local-ai.sh`,
`pull-models.sh`, `health-check.sh`). No API wrapper, no learning engine, no fine-tuning, no
Cloudflare automation. LAN-only by default.

## Phase 2 — Deployer integration readiness

Document (not implement) how `../synology-site-deployer` should consume this repo: clone/pull it,
provide `.env` (with a deployer-chosen `LOCAL_AI_BASE_PATH`), run `docker compose up -d` or this
repo's bootstrap script, and separately configure Cloudflare Tunnel / DNS to route only to Open
WebUI. See [`deployer-integration.md`](deployer-integration.md).

## Phase 3 — Local usefulness

Grow the prompt library and add usage notes (document upload/RAG via Open WebUI's built-in
features, app-ideas/research/coding assistant prompts, a model performance test log template).
Still no code beyond Markdown prompt files.

## Phase 4 — Domain exposure readiness

Documentation-only phase confirming `LOCAL_AI_DOMAIN` as a fully user-configurable hostname (no
domain hardcoded), restating that only Open WebUI is ever exposed, and providing a pre-exposure
validation checklist. Actual exposure
work happens in `../synology-site-deployer`, not here.

## Phase 5 — Future private AI API (planning only)

Design (do not build, unless explicitly requested later) a thin local API wrapper around Ollama
with task-specific endpoints (rewrite, summarise, app spec, code helper, document Q&A) and API key
auth, so a future private mobile/web app could call it.

## Phase 6 — Future hardware expansion (planning only)

Document how this architecture extends to a GPU workstation or remote Ollama backend, with the NAS
staying as the storage/UI/orchestration layer, and what changes for large models.

## Phase 7 — Future portable local mode (planning only, minimal safe scaffolding allowed)

Document a fully self-contained portable mode (copy the folder anywhere, run `start`), separate
from NAS deployment, localhost-bound by default. Add placeholder `start`/`stop` scripts only if
that can be done safely and simply without expanding MVP scope.

## Phase 8 — Future feedback learning loop (planning only)

Document how ratings, corrections, accepted/rejected answers, and project rules would be captured
and retrieved as context, using Markdown/JSONL now and SQLite later. No implementation, no model
retraining.

## Phase 9 — Future model self-learning / personal model path (planning only)

Document the far-future path from curated feedback data to fine-tuning/distillation experiments on
small open models, gated on better hardware and a mature memory/RAG layer, with explicit attention
to model licenses and data provenance. Not implemented, not started, no uncontrolled
self-modification.

## What's realistic now vs. not

**Realistic now (MVP):** local chat UI, local inference, a handful of small models, prompt
library, LAN-only access, manual document upload/Q&A via Open WebUI's own features, clean
persistent storage layout, documented deployer handoff.

**Realistic near-future:** structured feedback capture, local memory/rules store, retrieval of that
memory as prompt context, a small evaluation harness, prompt-template refinement based on feedback.

**Not realistic now:** an OpenAI-compatible API gateway, a mobile app backend, SSO, monitoring/
alerting, backup automation, a formal RAG/vector-database pipeline, multi-model routing.

**Far future / explicitly out of scope for a long time:** fine-tuning or distilling a personal
model, uncontrolled self-modification, running large (14B+) models without better hardware.
