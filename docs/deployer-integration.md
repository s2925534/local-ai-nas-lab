# Deployer integration

This project is standalone and does not require
[`../synology-site-deployer`](../../synology-site-deployer) to work — LAN-only mode with plain
`docker compose up -d` is fully self-sufficient. This document explains how the deployer *could*
consume this repo later, and what assumptions each side makes. Nothing described here is
implemented as automation inside this repo; it's a documented handoff contract.

## Division of responsibility

| Concern | Owner |
|---|---|
| Ollama + Open WebUI containers, compose file | This repo |
| Persistent folder layout under `LOCAL_AI_BASE_PATH` | This repo defines the layout; whoever sets `LOCAL_AI_BASE_PATH` (you, or the deployer) decides the real path |
| Prompt library, docs, scripts | This repo |
| Cloning/pulling this repo onto the NAS | `../synology-site-deployer` (or you, manually) |
| Providing/generating `.env` on the NAS | `../synology-site-deployer` (or you, manually, from `.env.example`) |
| Starting the compose stack on the NAS | `../synology-site-deployer` (or you, via `scripts/bootstrap-local-ai.sh`) |
| DNS, Cloudflare Tunnel, certificates, reverse proxy | `../synology-site-deployer` only |
| Deciding the final NAS volume/path | `../synology-site-deployer` only |

## How `../synology-site-deployer` could consume this repo

Based on inspecting that project (see its `README.md`): it already has a `deploy` command that
"uploads an existing project's own Compose file (+ optional `.env`) and starts it — any framework,
since it doesn't generate app code," plus a `cloudflare-route` command that "points one hostname at
a fixed port via the Cloudflare API directly." Both map cleanly onto this repo without needing new
deployer features:

1. The deployer clones or pulls this repo to a location on the NAS (or copies just the files it
   needs — `docker-compose.yml`, `.env`, `scripts/`).
2. The deployer generates or supplies `.env`, setting at minimum:
   - `LOCAL_AI_BASE_PATH` to whatever persistent path it manages (e.g. something under its own
     `NAS_DOCKER_ROOT` convention) — this repo does not need or want to know that path in advance.
   - `OPEN_WEBUI_BIND_HOST=0.0.0.0` (LAN) or a value appropriate to how the deployer's reverse
     proxy reaches containers.
   - `OLLAMA_BIND_HOST=127.0.0.1` — the deployer should never override this to make Ollama
     reachable from outside the host.
3. The deployer runs `docker compose up -d` (its own `deploy` command, or equivalent), or invokes
   `scripts/bootstrap-local-ai.sh` for the folder-creation + model-pull + health-check convenience.
4. If public exposure is wanted, the deployer separately runs its own Cloudflare/DNS/tunnel
   automation (e.g. `cloudflare-route`) pointed at the Open WebUI container's port
   (`OPEN_WEBUI_PORT`, default `3000`) on whatever hostname you've set as `LOCAL_AI_DOMAIN` (see
   [`reverse-proxy-domain.md`](reverse-proxy-domain.md)). It must never route Ollama's port.

## Assumptions this repo makes about the deployer

- The deployer (or a human) provides a valid `.env` before starting the stack — this repo ships
  only `.env.example`, never a real `.env`.
- The deployer is responsible for choosing a `LOCAL_AI_BASE_PATH` that is persistent across
  container restarts and NAS reboots. This repo does not validate that the path is "correct" for
  Synology conventions — it only refuses to run if the variable is empty (see
  `scripts/create-folders.sh`).
- The deployer is responsible for all Cloudflare/DNS/reverse-proxy state. This repo has no
  Cloudflare credentials, environment variables, or logic, beyond the informational
  `REVERSE_PROXY_PROVIDER=deployer_managed` and `CLOUDFLARE_TUNNEL_ENABLED=false` values in
  `.env.example`, which exist purely as documentation/signaling, not automation.
- The deployer routes only to Open WebUI's port. This repo assumes that constraint is honored and
  documents it repeatedly (README, security.md, reverse-proxy-domain.md) rather than enforcing it
  in code, since enforcement is out of scope for this repo.

## Managing multiple sites from one clone

If this repo is being reused to deploy the same stack to more than one site (your own NAS, a
friend's NAS, a test box, etc.), keep each site's specific configuration — domain, display name,
persistent path — in `workspaces/<name>/site.env` instead of editing the tracked `.env.example` or
overwriting a single `.env` back and forth. See [`workspaces/README.md`](../workspaces/README.md).
This mirrors `../synology-site-deployer`'s own workspace convention
(`secrets/<workspace>/{cloudflare.env,nas.env}`); using the same `<name>` in both repos is a useful
convention, but the two are not mechanically linked — this repo's `workspaces/` only affects this
repo's `.env` values.

## What this repo will never do

- Implement Cloudflare API calls, DNS record management, or tunnel configuration.
- Assume or require a specific Synology volume path.
- Modify `../synology-site-deployer` itself.
- Route or expose Ollama's port through any mechanism.

## Optional future metadata for deployer consumption

Not implemented yet (see `TODO.md` Phase 2): a small `deploy.meta.json` or similar file describing
this repo's service names, default ports, and required `.env` keys, so the deployer could
auto-discover them instead of a human reading this document. Deferred because the current
documentation-based handoff is sufficient for MVP scale and adding a metadata format prematurely
risks needing to change it once real deployer usage patterns are known.
