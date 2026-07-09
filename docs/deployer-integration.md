# Deployer integration

This project is standalone and does not require any external deployment tool to work — LAN-only
mode with plain `docker compose up -d` is fully self-sufficient. If you want to automate deployment
or public exposure, you can optionally pair this repo with whatever tool you already use for that:
a Synology deployment tool, a general-purpose reverse proxy, Cloudflare Tunnel directly, or
something else entirely. This document explains the pattern using the maintainer's own tool,
[`synology-site-deployer`](../../synology-site-deployer), as one concrete worked example — nothing
here is specific to it, and nothing in this repo changes if you use a different tool or none at
all.

## Division of responsibility

| Concern | Owner |
|---|---|
| Ollama + Open WebUI containers, compose file | This repo |
| Persistent folder layout under `LOCAL_AI_BASE_PATH` | This repo defines the layout; whoever sets `LOCAL_AI_BASE_PATH` (you, manually, or your chosen external tool) decides the real path |
| Prompt library, docs, scripts | This repo |
| Cloning/pulling this repo onto the NAS | Your chosen external tool, or you, manually |
| Providing/generating `.env` on the NAS | Your chosen external tool, or you, manually, from `.env.example` |
| Starting the compose stack on the NAS | Your chosen external tool, or you, via `scripts/bootstrap-local-ai.sh` |
| DNS, Cloudflare Tunnel, certificates, reverse proxy | Your chosen external tool only — this repo never touches it |
| Deciding the final NAS volume/path | Your chosen external tool only — this repo never assumes one |

## Worked example: `../synology-site-deployer`

This section illustrates the pattern with one specific tool. Any tool that can (a) copy files to a
NAS, (b) write an `.env` file, (c) run `docker compose up -d`, and (d) optionally route a hostname
to a container port can integrate the same way.

Based on inspecting that project's `README.md`: it has a `deploy` command that "uploads an
existing project's own Compose file (+ optional `.env`) and starts it — any framework, since it
doesn't generate app code," plus a `cloudflare-route` command that "points one hostname at a fixed
port via the Cloudflare API directly." Both map cleanly onto this repo without needing new features
in either project:

1. The tool clones or pulls this repo to a location on the NAS (or copies just the files it needs —
   `docker-compose.yml`, `.env`, `scripts/`).
2. The tool generates or supplies `.env`, setting at minimum:
   - `LOCAL_AI_BASE_PATH` to whatever persistent path it manages (e.g. something under its own
     Docker-root convention) — this repo does not need or want to know that path in advance.
   - `OPEN_WEBUI_BIND_HOST=0.0.0.0` (LAN) or a value appropriate to how its reverse proxy reaches
     containers.
   - `OLLAMA_BIND_HOST=127.0.0.1` — never override this to make Ollama reachable from outside the
     host, regardless of which tool you use.
3. The tool runs `docker compose up -d` (its own deploy command, or equivalent), or invokes
   `scripts/bootstrap-local-ai.sh` for the folder-creation + model-pull + health-check convenience.
4. If public exposure is wanted, the tool separately runs its own Cloudflare/DNS/tunnel automation
   pointed at the Open WebUI container's port (`OPEN_WEBUI_PORT`, default `3000`) on whatever
   hostname you've set as `LOCAL_AI_DOMAIN` (see [`reverse-proxy-domain.md`](reverse-proxy-domain.md)).
   It must never route Ollama's port, no matter which tool is doing the routing.

## Assumptions this repo makes about whatever tool you use (if any)

- Something — a tool, or you, manually — provides a valid `.env` before starting the stack. This
  repo ships only `.env.example`, never a real `.env`.
- Whatever chooses `LOCAL_AI_BASE_PATH` is responsible for it being persistent across container
  restarts and reboots. This repo does not validate that the path is "correct" for any particular
  platform's conventions — it only refuses to run if the variable is empty (see
  `scripts/create-folders.sh`).
- Whatever manages exposure is responsible for all Cloudflare/DNS/reverse-proxy state. This repo
  has no Cloudflare credentials, environment variables, or logic of its own, beyond the
  informational `REVERSE_PROXY_PROVIDER` and `CLOUDFLARE_TUNNEL_ENABLED` values in `.env.example`,
  which exist purely as documentation/signaling for whoever reads the config, not automation.
- Whatever manages exposure routes only to Open WebUI's port. This repo assumes that constraint is
  honored and documents it repeatedly (README, security.md, reverse-proxy-domain.md) rather than
  enforcing it in code, since enforcement of an external tool's behavior is out of scope for this
  repo.

## Managing multiple sites from one clone

If this repo is being reused to deploy the same stack to more than one site (your own NAS, a
friend's NAS, a test box, etc.), keep each site's specific configuration — domain, display name,
persistent path — in `workspaces/<name>/site.env` instead of editing the tracked `.env.example` or
overwriting a single `.env` back and forth. See [`workspaces/README.md`](../workspaces/README.md).
This mirrors the workspace convention used by tools like `../synology-site-deployer`
(`secrets/<workspace>/{cloudflare.env,nas.env}`); using the same `<name>` in both is a useful
convention if you happen to use that specific tool, but the two are not mechanically linked — this
repo's `workspaces/` only affects this repo's own `.env` values, and works the same regardless of
which (if any) external deployment tool you pair it with.

## What this repo will never do

- Implement Cloudflare API calls, DNS record management, or tunnel configuration, regardless of
  which external tool (if any) you use.
- Assume or require a specific Synology volume path.
- Depend on, or require the presence of, any particular external deployment tool.
- Modify `../synology-site-deployer` (or any other external project) itself.
- Route or expose Ollama's port through any mechanism.

## Optional future metadata for external-tool consumption

Not implemented yet (see `TODO.md` Phase 2): a small `deploy.meta.json` or similar file describing
this repo's service names, default ports, and required `.env` keys, so an external tool could
auto-discover them instead of a human reading this document. Deferred because the current
documentation-based handoff is sufficient for MVP scale and adding a metadata format prematurely
risks needing to change it once real integration patterns (across different tools) are known.
