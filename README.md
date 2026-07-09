# Local AI NAS Lab

A self-hosted local AI lab for a Synology NAS (or any Docker host): [Ollama](https://ollama.com/)
for local model inference, [Open WebUI](https://github.com/open-webui/open-webui) as the
browser-based chat interface, and Docker Compose to run both. The goal is free, private, local
inference for everyday tasks — brainstorming, rewriting, summarising, app planning, simple coding
help, document Q&A — with a documented path toward memory, feedback capture, and (far future) a
personal fine-tuned model.

## What this project does

- Runs open local models on your own hardware via Ollama.
- Gives you a normal chat UI (Open WebUI) reachable on your LAN, with an optional path to private
  remote access (Tailscale) or public exposure (handled by a separate deployer project).
- Keeps all persistent data — models, chats, documents, prompts, exports, backups, logs — under a
  single configurable base path, so it is portable across a Synology NAS, a plain Linux box, or a
  laptop.
- Ships a small prompt library for recurring tasks (app specs, coding prompts, email replies,
  research summaries, NAS admin help).
- Documents, but does not yet implement, a path toward local memory/feedback capture and a
  far-future personal model.

## What this project does NOT do

- It is **not** a replacement for ChatGPT, Claude, Claude Code, Codex, or other frontier hosted AI
  products. Local open models on NAS-class hardware are smaller and slower. This project exists to
  absorb repetitive, lower-stakes tasks and reduce paid API usage — not to match frontier quality.
- It does **not** implement Cloudflare, DNS, tunnels, certificates, or reverse proxy automation.
  That is the job of the separate [`synology-site-deployer`](../synology-site-deployer) project.
  See [`docs/deployer-integration.md`](docs/deployer-integration.md).
- It does **not** train or fine-tune any model in the MVP. See
  [`docs/learning-and-self-improvement.md`](docs/learning-and-self-improvement.md) for the
  documented (not implemented) future path.
- It does **not** hardcode a Synology volume path (e.g. `/volume1/...`). All persistent storage is
  controlled by a single `LOCAL_AI_BASE_PATH` variable. See
  [`docs/portable-local-mode.md`](docs/portable-local-mode.md) and
  [`docs/deployer-integration.md`](docs/deployer-integration.md).
- It does **not** expose Ollama's API port to the LAN or the internet by default.

## Architecture (text form)

```
                         ┌─────────────────────────────┐
                         │   Browser (you, on LAN)      │
                         └───────────────┬──────────────┘
                                         │ http://<nas-ip>:3000
                                         ▼
                         ┌─────────────────────────────┐
                         │  Open WebUI (container)       │
                         │  port 3000 -> LAN             │
                         └───────────────┬──────────────┘
                                         │ internal Docker network
                                         │ http://ollama:11434
                                         ▼
                         ┌─────────────────────────────┐
                         │  Ollama (container)           │
                         │  port 11434 -> 127.0.0.1 only │
                         └───────────────┬──────────────┘
                                         │
                                         ▼
                         ┌─────────────────────────────┐
                         │  ${LOCAL_AI_BASE_PATH}/...    │
                         │  models, webui data, docs,    │
                         │  prompts, exports, backups,   │
                         │  logs, memory (future)        │
                         └─────────────────────────────┘
```

Public exposure (optional, future, deployer-managed):

```
Internet -> Cloudflare -> synology-site-deployer -> Open WebUI only (never Ollama)
```

See [`docs/architecture.md`](docs/architecture.md) for the full picture, including the portable
local mode, feedback learning loop, and personal-model architectures (all future / documented
only).

## Quick start (LAN-only, MVP)

Requirements: Docker + Docker Compose (or Synology Container Manager), a persistent folder to
store models and data in.

```bash
cp .env.example .env
# edit .env if you want to change ports or LOCAL_AI_BASE_PATH — the defaults work as-is
./scripts/bootstrap-local-ai.sh
```

`bootstrap-local-ai.sh` will:

1. Create the persistent folder structure under `LOCAL_AI_BASE_PATH`.
2. Start Ollama and Open WebUI via Docker Compose.
3. Wait for both services to come up.
4. Pull the default MVP model set if `AUTO_PULL_MODELS=true` (the default).
5. Run a health check and print the local URL to open.

Then open `http://localhost:${OPEN_WEBUI_PORT}` (default `http://localhost:3000`), create the
first admin account (signup is disabled after that by default), and start chatting.

You can also run the steps individually:

```bash
./scripts/create-folders.sh     # create persistent folders only
docker compose up -d            # start containers
./scripts/pull-models.sh        # pull the default model set
./scripts/health-check.sh       # verify everything is up
```

## Recommended first models

Configured by default in `.env.example`, pulled automatically by `scripts/pull-models.sh`:

| Purpose                | Model                |
|-------------------------|-----------------------|
| General, fast, small    | `llama3.2:3b`         |
| General, better quality | `qwen2.5:7b`          |
| Coding                  | `qwen2.5-coder:7b`    |
| Embeddings (future RAG) | `nomic-embed-text`    |

These are chosen to be usable on modest CPU-only NAS hardware. Large models (14B and up) are
explicitly out of scope for the MVP — see [`docs/future-flags.md`](docs/future-flags.md)
(`ENABLE_LARGE_MODELS`).

## Default ports

| Service     | Default bind             | Default port | Notes                                  |
|-------------|---------------------------|--------------|------------------------------------------|
| Open WebUI  | `0.0.0.0` (LAN)            | `3000`       | Only service ever exposed publicly       |
| Ollama      | `127.0.0.1` (host-only)    | `11434`      | Never expose publicly, LAN only if opted in |

## Persistent data (`LOCAL_AI_BASE_PATH`)

Every persistent file this project writes lives under a single variable:
`LOCAL_AI_BASE_PATH`. Nothing in this repo assumes or requires a Synology volume path like
`/volume1/...`.

- Running manually (on a NAS, a Linux box, or a laptop): set `LOCAL_AI_BASE_PATH` in `.env` to any
  folder you control. The safe local default is `./data/local-ai`.
- Running via [`../synology-site-deployer`](../synology-site-deployer): the deployer decides the
  final path on the NAS and provides it. This repo does not need to know or care which volume that
  is. See [`docs/deployer-integration.md`](docs/deployer-integration.md).

## Domain / public exposure

Cloudflare, DNS, tunnels, certificates, and reverse proxy routing are **not** implemented in this
repo. They are handled entirely by the separate
[`synology-site-deployer`](../synology-site-deployer) project. This repo only documents the
expected setup: recommended hostname `ai.veloso.dev` (configurable, not hardcoded), routing only to
Open WebUI, never to Ollama. See [`docs/reverse-proxy-domain.md`](docs/reverse-proxy-domain.md).

## Future directions (documented, not implemented in MVP)

- **Portable local mode** — copy the project folder to any computer and run a `start` script for a
  fully local, no-NAS-required instance. See
  [`docs/portable-local-mode.md`](docs/portable-local-mode.md).
- **Learning / self-improvement** — feedback capture, ratings, corrections, local memory, RAG
  retrieval, prompt refinement, and an evaluation harness, all without retraining model weights.
  See [`docs/learning-and-self-improvement.md`](docs/learning-and-self-improvement.md).
- **Personal model path** — a far-future, explicitly opt-in path toward fine-tuning or distilling a
  small open model using curated local feedback data, once the memory/RAG layer is mature and
  better hardware is available. See the "Far-future personal model path" section of
  [`docs/learning-and-self-improvement.md`](docs/learning-and-self-improvement.md) and
  [`docs/future-flags.md`](docs/future-flags.md).

## Basic commands

```bash
cp .env.example .env                 # first-time setup
./scripts/bootstrap-local-ai.sh      # folders + containers + models + health check
docker compose up -d                 # start containers
docker compose down                  # stop containers
docker compose logs -f               # tail logs
./scripts/pull-models.sh             # (re)pull the default model set
./scripts/health-check.sh            # check service health
```

A backup script (`scripts/backup-local-ai.sh`) is planned but not yet part of this minimal Phase 1
foundation — see `TODO.md` Phase 3.

## Security warning

This stack defaults to **LAN-only**. Read [`docs/security.md`](docs/security.md) before changing
any exposure setting. In short: never expose Ollama's port publicly, never expose DSM/SSH publicly,
disable Open WebUI signup once you've created your account, and treat anything under
`documents/` and the future `memory/` folder as private data.

## Full manual

See [`docs/local-ai-nas-manual.md`](docs/local-ai-nas-manual.md) for the detailed Synology setup
walkthrough, and [`docs/phase-plan.md`](docs/phase-plan.md) / [`TODO.md`](TODO.md) for what's built
vs. planned.
