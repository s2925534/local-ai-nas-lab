# Decision log

Lightweight Architecture Decision Record (ADR) style log. Newest decisions at the bottom. Each
entry: context, decision, consequences.

## 0001 — Use Ollama as the local model runtime

**Context:** Need a simple, self-hostable way to run open-weight models on modest NAS hardware
with minimal operational overhead.
**Decision:** Use Ollama for model serving.
**Consequences:** Simple model pull/run UX, wide model support, CPU-friendly for small models. Its
API must never be exposed publicly (see [`security.md`](security.md)).

## 0002 — Use Open WebUI as the chat interface

**Context:** Need a browser-based UI that talks to Ollama, supports multiple users/admin accounts,
and has a reasonable document-upload/Q&A story out of the box.
**Decision:** Use Open WebUI as the only user-facing, potentially publicly-exposed service.
**Consequences:** Only one service ever needs a public route. Signup must be disabled after the
first admin account is created.

## 0003 — Use `LOCAL_AI_BASE_PATH` for all persistent storage

**Context:** This repo must run identically on a Synology NAS, a plain Linux box, a laptop
(portable mode), and eventually under deployer automation, without knowing which storage layout
each environment uses.
**Decision:** Every persistent folder is expressed relative to a single environment variable,
`LOCAL_AI_BASE_PATH`, with a portable local default of `./data/local-ai`.
**Consequences:** No script or compose file needs to change between environments — only `.env`
does. See [`portable-local-mode.md`](portable-local-mode.md) and
[`deployer-integration.md`](deployer-integration.md).

## 0004 — Never hardcode a Synology volume path

**Context:** `/volume1` is a Synology-specific convention. Hardcoding it would break portability
and would also duplicate a concern the deployer project already owns.
**Decision:** No file in this repo references `/volume1`, `/volume2`, or any specific NAS volume
as a required default. `.env.example` uses `./data/local-ai`; documentation shows
`/path/managed/by/deployer/local-ai` only as an illustrative example of a deployer-provided path.
**Consequences:** The deployer project is free to choose and change its NAS path convention without
this repo needing updates.

## 0005 — Do not implement Cloudflare/DNS/reverse proxy automation in this repo

**Context:** `../synology-site-deployer` already implements Cloudflare Tunnel + DNS automation,
workspaces, and reverse-proxy routing. Duplicating that here would create two sources of truth for
domain/certificate state.
**Decision:** This repo only documents the expected exposure model (Open WebUI only, hostname fully
configurable via `LOCAL_AI_DOMAIN`, no domain hardcoded) and leaves all Cloudflare/DNS/tunnel/
certificate work to the deployer project.
**Consequences:** This repo has zero Cloudflare API credentials, zero DNS logic, and stays usable
standalone (LAN-only) even if the deployer project is never involved.

## 0006 — Keep Ollama private by default

**Context:** Ollama's API has no built-in authentication. Exposing it directly (LAN or public)
would let anyone with network access run inference, pull/delete models, and consume resources.
**Decision:** Ollama's container port binds to `127.0.0.1` by default (`OLLAMA_BIND_HOST`); Open
WebUI reaches it only over the internal Docker network; no documented public route ever includes
Ollama's port `11434`.
**Consequences:** Slightly less convenient for direct CLI/API access from other LAN machines unless
a user deliberately changes `OLLAMA_BIND_HOST` and accepts the risk (documented, not default).

## 0007 — Feedback/memory before fine-tuning

**Context:** The long-term ambition includes a personal model, but jumping straight to fine-tuning
without a mature feedback/memory layer would produce low-quality training data and require hardware
this project doesn't have yet.
**Decision:** Order the roadmap so that feedback capture, local memory, and an evaluation harness
(Phase 8) come before any fine-tuning or distillation experiments (Phase 9).
**Consequences:** No shortcuts to "train my own model" in the near term; the roadmap explicitly
gates Phase 9 on Phase 8 being mature and on better hardware being available.

## 0008 — Treat personal model training as far-future, opt-in, hardware-gated

**Context:** Fine-tuning, distillation, and "personal model" framing can imply automatic
self-modification, which is explicitly not a goal.
**Decision:** Document fine-tuning/distillation/personal-model work as far-future, manual,
evaluated, and gated behind future flags (`ENABLE_FINE_TUNING_EXPERIMENTS`,
`ENABLE_PERSONAL_MODEL_PATH`, `ENABLE_MODEL_DISTILLATION_EXPERIMENTS`) that default to `false` and
are not implemented in the MVP.
**Consequences:** No training code ships in this repository until those flags are deliberately
acted on in a future, explicitly-scoped piece of work.

## 0009 — Keep the repo generic; isolate any personal branding to `workspaces/`

**Context:** This repo needs to be clonable by anyone and paired with their own instance of a
Synology deployer (not necessarily `../synology-site-deployer` specifically), so no example
hostname (e.g. an early draft used a personal `ai.<domain>` example throughout the docs) should
read as "the" configuration. The only appropriate personal reference is developer attribution.
**Decision:** Every domain/hostname example in docs and sample files uses a fully generic
placeholder (`ai.example.com`, `ai.yourdomain.com`). The only personal information anywhere in the
repo is the "Developer" section in `README.md` (name + contact email) and the LICENSE copyright
line, both standard OSS attribution, not configuration. Multi-site users keep their own real
domain/name/path in gitignored `workspaces/<name>/site.env` files (see
[`workspaces/README.md`](../workspaces/README.md)), never in a tracked file.
**Consequences:** A first-time cloner sees only generic examples and one clearly-labeled
attribution section; nothing needs to be scrubbed or overridden before reuse. The `workspaces/`
convention mirrors `../synology-site-deployer`'s own workspace pattern
(`secrets/<workspace>/*.env`) so the two projects compose naturally for anyone managing multiple
sites, without being mechanically coupled.
