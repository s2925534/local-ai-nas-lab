# Reverse proxy / domain

**This repo does not implement Cloudflare, DNS, tunnel, certificate, or reverse-proxy automation.**
All of that is handled by the separate [`synology-site-deployer`](../../synology-site-deployer)
project. This document exists so the deployer (or you, manually) knows exactly what to route and
what not to route.

## Recommended hostname

`ai.veloso.dev`

`LOCAL_AI_DOMAIN` in `.env` is a plain configuration value, not a hardcoded constant — the default
in `.env.example` is the generic placeholder `ai.example.com`, with `ai.veloso.dev` shown as a
commented personal example. Nothing in the code assumes `veloso.dev` specifically.

## Why `ai.veloso.dev` over the alternatives

Alternatives considered: `chat.veloso.dev`, `llm.veloso.dev`, `localai.veloso.dev`.

`ai.veloso.dev` is recommended because:

- It's not tied to "chat" — this project is meant to grow into document Q&A, coding help, a future
  private API, and eventually a personal-model backend, not just a chat window. `chat.` would need
  renaming later; `ai.` already covers all of that.
- It's shorter and cleaner than `llm.` or `localai.` for something you'll type or bookmark
  regularly.
- `llm.` is technically accurate but more implementation-detail-flavored than user-facing; `ai.`
  reads better as the name of "my personal AI thing."
- `localai.` stutters conceptually once this is reachable outside the LAN (it says "local" in a
  hostname meant for remote access).

You're free to use any of the alternatives — the project does not require `ai.veloso.dev`
specifically, and `LOCAL_AI_DOMAIN` is fully configurable per deployment.

## Intended public routing

```
https://ai.veloso.dev  ->  Open WebUI (container port from OPEN_WEBUI_PORT)
```

That's the only route. Specifically:

- **Do not** route port `11434` (Ollama) through any tunnel, proxy, or DNS record.
- **Do not** expose Ollama's API under any path or subdomain, public or otherwise.
- **Do not** route DSM (Synology's admin UI) through this hostname or any related one.
- Only the Open WebUI container/port should ever be reachable from a public hostname.

## Division of responsibility

| Concern | Owner |
|---|---|
| DNS records | `../synology-site-deployer` |
| Cloudflare Tunnel / Access | `../synology-site-deployer` |
| TLS certificates | `../synology-site-deployer` (via Cloudflare) |
| Reverse proxy ingress rules | `../synology-site-deployer` |
| Which container/port gets routed | This repo documents it; the deployer configures it |
| NAS volume / persistent path | `../synology-site-deployer` decides at deploy time; this repo never assumes one |

This repo's job is to stay predictable: a fixed service name (`localai-open-webui`) and a
configurable port (`OPEN_WEBUI_PORT`, default `3000`) that the deployer's tunnel/reverse-proxy
config can point at. See [`deployer-integration.md`](deployer-integration.md) for how that handoff
is expected to work, and [`../../synology-site-deployer/docs/remote-nas-access.md`](../../synology-site-deployer/docs/remote-nas-access.md)
for that project's own Tailscale/Cloudflare mechanics (informational only — this repo does not
depend on that file existing).

## Before enabling public exposure

See the checklist in [`security.md`](security.md) — disable signup, set a strong admin password,
confirm only Open WebUI is routed, and review what's in `documents/` before it becomes reachable by
anyone with valid login credentials.
