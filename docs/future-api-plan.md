# Future private AI API (plan only)

Status: **documented concept for Phase 5, not implemented in the MVP.** `ENABLE_LOCAL_AI_API` and
`ENABLE_API_KEY_AUTH` are planning placeholders only — neither appears in `.env.example` yet (see
[`future-flags.md`](future-flags.md)). This document exists so the wrapper has a clear shape to
build later, without re-deriving the design, and so it is explicitly scoped down to avoid
overbuilding.

## Why this exists

Open WebUI already provides a full chat interface. The gap this plan addresses is programmatic,
task-specific access — from a future private mobile app, a script, or another tool on the LAN —
without exposing Ollama directly and without reimplementing Open WebUI's own chat API.

## Design

- A thin HTTP wrapper that sits in front of Ollama, not a replacement for Open WebUI. It calls
  Ollama the same way Open WebUI does, over the internal Docker network
  (`http://ollama:11434`) — it never exposes Ollama's port itself.
- Task-specific endpoints, not a generic passthrough — each endpoint bakes in a prompt template
  from `prompts/` and picks an appropriate model (small/general/coding/embedding), so callers don't
  need to know Ollama's request format or which model to use.
- Stateless by default. Endpoints that need memory (feedback, corrections, prompt history) depend on
  the Phase 8 local memory store existing first — see
  [`learning-and-self-improvement.md`](learning-and-self-improvement.md) and decision
  [0007](decision-log.md#0007--feedbackmemory-before-fine-tuning).
- LAN-only by default, same as Open WebUI — the API would bind to `127.0.0.1` or the LAN interface
  depending on `.env`, never require public exposure, and never be the thing that's routed through a
  public hostname unless a user deliberately chooses to (Open WebUI stays the recommended public
  surface; see [`security.md`](security.md)).

## Planned endpoints

Task-specific endpoints (Phase 5 core):

```
POST /rewrite               — rewrite/improve a piece of text
POST /summarise              — summarise a document or block of text
POST /generate-app-spec      — turn a rough app idea into a structured spec (prompts/app-specs/)
POST /generate-codex-prompt  — turn a bug/feature description into a coding-agent-ready prompt
POST /ask-documents          — document Q&A over uploaded files (RAG)
POST /code-helper            — coding assistance using the coding model
```

Feedback/memory endpoints (Phase 8, gated on the local memory store existing — sketched in detail in
[`learning-and-self-improvement.md`](learning-and-self-improvement.md#future-api-ideas-phase-8-not-implemented)):

```
POST /feedback                 — record a rating/comment on a response
POST /remember                 — store a durable rule or fact
POST /rate-answer               — quick thumbs up/down on a response
POST /accept-correction         — record a user's correction to a response
POST /generate-improved-prompt  — propose a refined prompt template from feedback history
POST /search-memory             — retrieve relevant rules/feedback/examples for a query
```

None of these exist yet. Endpoint names above are a naming convention to build toward, not a
committed API contract.

## Authentication plan

- API key auth (`ENABLE_API_KEY_AUTH`), not full user accounts — this API is meant for the
  instance owner's own tools (a mobile app, a script), not multi-user access. Open WebUI already
  handles multi-user chat access.
- Keys would be generated locally and stored the same way any other secret in this project is
  handled: never committed, never in `.env.example`, following the same rule already stated in
  [`security.md`](security.md#secrets).
- No key management UI planned for the MVP of this feature — a key would be a generated value placed
  in `.env` (or a dedicated gitignored file) and checked on every request via a header.
- No OAuth, SSO, or third-party identity provider integration planned here — see
  `ENABLE_SSO` and `ENABLE_OPENAI_COMPATIBLE_GATEWAY` in [`future-flags.md`](future-flags.md) for
  those explicitly separate, lower-priority ideas.

## Explicitly out of scope (do not overbuild)

- No generic passthrough to raw Ollama endpoints — every endpoint stays task-specific and templated.
- No mobile app itself — this plan only covers the API a future mobile/web client would call
  (`ENABLE_MOBILE_APP_BACKEND` in [`future-flags.md`](future-flags.md) is a separate, later idea).
- No OpenAI-compatible gateway as part of this plan — that's a distinct, lower-priority idea
  (`ENABLE_OPENAI_COMPATIBLE_GATEWAY`).
- No multi-model auto-routing logic bundled in by default — `ENABLE_MULTI_MODEL_ROUTER` is a
  separate future idea (see [`hardware-expansion.md`](hardware-expansion.md)) that this API could
  eventually call into, not something this plan needs to implement itself.
- Build only when there's an actual caller (a real mobile app, a real script) that needs it — not
  speculatively ahead of that need.

## What this document is not

It is not a spec for an implementation that exists today. No route, server, or API key logic ships
in this repository yet. See [`phase-plan.md`](phase-plan.md) Phase 5 for how this fits the overall
roadmap.
