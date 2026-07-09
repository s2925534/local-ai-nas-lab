# Reverse proxy / domain

**This repo does not implement Cloudflare, DNS, tunnel, certificate, or reverse-proxy automation.**
All of that is handled by the separate [`synology-site-deployer`](../../synology-site-deployer)
project (or your own equivalent deployer). This document exists so the deployer (or you, manually)
knows exactly what to route and what not to route.

## Choosing a hostname

`LOCAL_AI_DOMAIN` in `.env` is a plain configuration value — the default in `.env.example` is the
generic placeholder `ai.example.com`. Nothing in this repo's code or scripts assumes any specific
domain; pick whatever hostname you own and want to use.

A naming convention worth considering, purely as a suggestion: an `ai.<yourdomain>` style hostname
(e.g. `ai.example.com`) tends to age better than a `chat.<yourdomain>` one, since this project is
meant to grow into document Q&A, coding help, and eventually a private API — not just a chat
window. That's just a naming preference, not a requirement; `llm.`, `localai.`, or anything else
you prefer works identically as far as this repo is concerned.

## Intended public routing

```
https://<your-chosen-hostname>  ->  Open WebUI (container port from OPEN_WEBUI_PORT)
```

That's the only route. Specifically:

- **Do not** route port `11434` (Ollama) through any tunnel, proxy, or DNS record.
- **Do not** expose Ollama's API under any path or subdomain, public or otherwise.
- **Do not** route DSM (Synology's admin UI) through this hostname or any related one.
- Only the Open WebUI container/port should ever be reachable from a public hostname.

## Division of responsibility

| Concern | Owner |
|---|---|
| DNS records | your deployer (e.g. `../synology-site-deployer`) |
| Cloudflare Tunnel / Access | your deployer |
| TLS certificates | your deployer (typically via Cloudflare) |
| Reverse proxy ingress rules | your deployer |
| Which container/port gets routed | This repo documents it; the deployer configures it |
| NAS volume / persistent path | Your deployer decides at deploy time; this repo never assumes one |

This repo's job is to stay predictable: a fixed service name (`localai-open-webui`) and a
configurable port (`OPEN_WEBUI_PORT`, default `3000`) that a deployer's tunnel/reverse-proxy config
can point at. See [`deployer-integration.md`](deployer-integration.md) for how that handoff is
expected to work with `../synology-site-deployer` specifically.

## Before enabling public exposure

See the checklist in [`security.md`](security.md) — disable signup, set a strong admin password,
confirm only Open WebUI is routed, and review what's in `documents/` before it becomes reachable by
anyone with valid login credentials.
