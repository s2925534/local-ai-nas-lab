# Portable local mode (future)

Status: **documented concept, not implemented in the MVP.** `PORTABLE_MODE=false` by default in
`.env.example`. This document describes the intended design so it can be picked up later without
re-deriving it.

## Goal

Let the entire project folder be copied to any computer (Mac, Linux, or Windows) and started with a
single command, producing a fully working local AI chat instance with no NAS, no domain, and no
external deployment tool involvement of any kind.

## Design

- Same `docker-compose.yml` used for NAS deployment — portable mode is a different `.env`
  configuration, not a different stack.
- `LOCAL_AI_BASE_PATH` is set to `PORTABLE_DATA_PATH` (default `./data/portable-local-ai`), a
  folder inside the project itself, so the whole thing — code, data, models — travels together if
  you copy the directory (subject to the size caveat below).
- `OPEN_WEBUI_BIND_HOST` and `OLLAMA_BIND_HOST` default to `127.0.0.1`
  (`PORTABLE_USE_LOCALHOST_ONLY=true`) — nothing is reachable from the LAN unless a user
  deliberately opts in.
- `PORTABLE_OPEN_BROWSER=true` — a future `start` script would open the default browser at
  `http://localhost:${OPEN_WEBUI_PORT}` once Open WebUI responds, so there's no URL to remember or
  type.
- Future `scripts/start.sh` / `scripts/stop.sh` (Mac/Linux) and `scripts/start.ps1` /
  `scripts/stop.ps1` (Windows) would wrap the same bootstrap logic as
  `scripts/bootstrap-local-ai.sh`, pointed at the portable `.env` values.

## What is and isn't truly portable

- **Portable:** the project code, prompt library, docker-compose definition, and scripts. These are
  small and copy instantly.
- **Not cheaply portable:** downloaded model weights and container images. Even the small MVP model
  set (`llama3.2:3b`, `qwen2.5:7b`, `qwen2.5-coder:7b`, `nomic-embed-text`) totals several GB, and
  Ollama/Open WebUI images add more. Copying the project folder does not mean copying a few
  kilobytes — plan for multi-GB transfers if you move a portable instance with its data.
- A future `ENABLE_OFFLINE_MODEL_PACKS` flag (see [`future-flags.md`](future-flags.md)) documents
  the idea of carrying pre-downloaded models/images for offline setup, but this is explicitly out
  of MVP scope because of that size.

## Relationship to NAS deployment mode

Portable mode and NAS deployment mode are kept **separate configurations of the same stack**, never
mixed:

| | NAS mode | Portable mode |
|---|---|---|
| `LOCAL_AI_BASE_PATH` | externally-provided (if using a deployment tool) or a manually chosen persistent folder | `PORTABLE_DATA_PATH`, inside the project folder |
| Bind hosts | Open WebUI on LAN, Ollama on `127.0.0.1` | both on `127.0.0.1` by default |
| Public exposure | optional, via whatever external tool you choose | never |
| Started via | `scripts/bootstrap-local-ai.sh` | future `scripts/start.sh` / `start.ps1` |

Do not point a portable instance's `.env` at a NAS path, and don't point a NAS instance's `.env` at
`PORTABLE_DATA_PATH` — pick the config that matches where the container is actually running.

## Future local metadata

If a custom local app layer is added later (beyond Open WebUI's own storage), portable mode would
use SQLite for local metadata (`ENABLE_PORTABLE_SQLITE_METADATA`) specifically because a single
file is trivial to move between computers, unlike a networked database.

## Not implemented in MVP

No `start`/`stop` scripts, no auto-browser-launch, no SQLite metadata layer, and no offline model
packing exist yet. `PORTABLE_MODE`, `PORTABLE_DATA_PATH`, `PORTABLE_OPEN_BROWSER`, and
`PORTABLE_USE_LOCALHOST_ONLY` are reserved in `.env.example` so the eventual implementation doesn't
need an `.env` schema change.
