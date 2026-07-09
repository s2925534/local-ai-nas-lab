# Troubleshooting

## Open WebUI cannot connect to Ollama

- Confirm both containers are on the `local_ai_net` Docker network: `docker network inspect
  local_ai_net`.
- Open WebUI must use `OLLAMA_BASE_URL=http://ollama:11434` (the Docker service name, not
  `localhost` and not `127.0.0.1`) — this is set in `docker-compose.yml` already; don't override it
  to a host-local address.
- Check Ollama is actually healthy: `docker compose ps` and `docker compose logs ollama`.
- Run `./scripts/health-check.sh` for a consolidated status.

## Model pull fails

- Check internet connectivity from the NAS/host running the containers — model pulls download from
  Ollama's registry.
- Check disk space on the volume backing `LOCAL_AI_BASE_PATH` — models are multiple GB each.
- Re-run `./scripts/pull-models.sh` — it's safe to re-run and will retry failed models while
  skipping ones already present.
- Check the exact error in the script output; a single model failing doesn't stop the others.

## Bootstrap fails

- Re-run `./scripts/bootstrap-local-ai.sh` — every step is designed to be safe to repeat.
- Check `.env` exists (`cp .env.example .env` if not) and `LOCAL_AI_BASE_PATH` is set and non-empty.
- Check Docker is running and `docker compose version` works.
- Look at which numbered step printed a failure and re-run just that step manually (folder
  creation, `docker compose up -d`, model pull, or health check).

## Start script fails (portable mode, future)

- Portable start/stop scripts are not implemented yet (see
  [`portable-local-mode.md`](portable-local-mode.md)). Until they exist, use
  `scripts/bootstrap-local-ai.sh` with `LOCAL_AI_BASE_PATH` pointed at a local folder.

## Portable mode starts but browser does not open (future)

- Auto-launch isn't implemented yet. Manually open `http://localhost:${OPEN_WEBUI_PORT}` once
  containers are healthy.

## Portable mode cannot find Docker (future)

- Docker Desktop (Mac/Windows) or the Docker Engine (Linux) must be installed and running before
  any start script can succeed. This project does not install Docker for you.

## NAS becomes slow

- CPU-only inference on a NAS is resource-intensive. Avoid running large models (see
  `ENABLE_LARGE_MODELS` in [`future-flags.md`](future-flags.md) — not enabled in the MVP) and avoid
  running multiple concurrent chats against a 7B+ model on constrained hardware.
- Check `docker stats` for per-container CPU/RAM usage.
- Stop the stack (`docker compose down`) if the NAS needs to recover for other services.

## Port 3000 already used

- Set `OPEN_WEBUI_PORT` in `.env` to a free port (e.g. `3001`) and re-run `docker compose up -d`.

## Port 11434 already used

- Set `OLLAMA_PORT` in `.env` to a free port. This only affects the host-mapped port — Open WebUI
  still reaches Ollama via the internal Docker network regardless of this value.

## Login/signup problems

- Signup is disabled by default after the first admin account (`ENABLE_SIGNUP=false`). If you need
  to create a second account, temporarily set `ENABLE_SIGNUP=true`, restart Open WebUI, create the
  account, then set it back to `false` and restart again.
- If you've lost admin access entirely, consult Open WebUI's own documentation for account
  recovery — this repo doesn't add or change Open WebUI's auth system.

## Permissions on `LOCAL_AI_BASE_PATH`

- The container processes need read/write access to the host folder(s) under `LOCAL_AI_BASE_PATH`.
  On Synology, ensure the folder is owned by (or writable by) the user/group Docker runs
  containers as. `scripts/create-folders.sh` creates folders but does not change ownership — fix
  permissions manually if containers report permission-denied errors in their logs.

## Permissions on `PORTABLE_DATA_PATH`

- Same class of issue as above, but local to your machine. Ensure your user account has write
  access to the project folder.

## Containers restart repeatedly

- Check `docker compose logs -f ollama` / `docker compose logs -f open-webui` for the actual crash
  reason — usually a bad `.env` value, a permissions issue on the mounted volume, or insufficient
  memory.
- Confirm the healthcheck in `docker-compose.yml` isn't failing due to Ollama still starting up —
  give it a minute before assuming it's broken.

## DNS / reverse proxy issues

- This repo does not manage DNS or reverse proxy config. If `ai.veloso.dev` (or your configured
  hostname) isn't resolving or routing correctly, that's a
  [`../synology-site-deployer`](../../synology-site-deployer) concern — see its own
  documentation, not this repo's.

## Deployer integration issues

- Confirm the deployer actually generated/copied a valid `.env` before starting the stack.
- Confirm the deployer set `LOCAL_AI_BASE_PATH` to a real, writable, persistent path — this repo
  will refuse to run folder creation if the variable is empty (see `scripts/create-folders.sh`).
- See [`deployer-integration.md`](deployer-integration.md) for the full expected handoff.

## Slow responses on CPU

- Expected for larger models on CPU-only hardware. Prefer `llama3.2:3b` for fast responses; use
  `qwen2.5:7b` / `qwen2.5-coder:7b` when quality matters more than speed and you can tolerate the
  wait. This is a known, documented MVP limitation, not a bug — see the README's "What this project
  does NOT do" section.

## Model too large for available RAM

- If a model fails to load or the container OOMs, pick a smaller model. Don't attempt 14B+ models
  without more RAM or a GPU backend (future Phase 6).

## Disk space concerns

- Models, container images, chat history, and exports all consume disk under
  `LOCAL_AI_BASE_PATH`. Monitor free space on that volume; `scripts/health-check.sh` reports basic
  status but does not currently enforce a disk-space threshold.

## Docker network issues

- If containers can't reach each other, confirm `local_ai_net` exists and both containers are
  attached to it: `docker network inspect local_ai_net`. Recreate the stack with `docker compose
  down && docker compose up -d` if the network looks wrong.

## Deployer did not provide a persistent path

- If `LOCAL_AI_BASE_PATH` is unset or empty, `scripts/create-folders.sh` will refuse to run rather
  than silently creating folders somewhere unexpected. Set it explicitly in `.env` before
  proceeding.

## `.env` not loaded

- All scripts expect `.env` in the repo root. Confirm it exists (`cp .env.example .env` if not) and
  that you're running scripts from the repo root, or with a working directory the scripts can find
  `.env` relative to.

## Auto model pull did not complete

- Check `AUTO_PULL_MODELS` and `AUTO_PULL_MODELS_ON_BOOTSTRAP` are `true` in `.env`.
- Re-run `./scripts/pull-models.sh` directly — it reports failures per-model at the end and is safe
  to re-run.
