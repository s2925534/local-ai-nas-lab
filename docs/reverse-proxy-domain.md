# Reverse proxy / domain

**This repo does not implement Cloudflare, DNS, tunnel, certificate, or reverse-proxy automation,
and does not require any tool that does.** LAN-only is a complete, fully supported way to run this
project forever. If you do want public exposure, that's handled entirely by an external tool of
your choice — the maintainer uses
[`synology-site-deployer`](../../synology-site-deployer), but any equivalent deployer, reverse
proxy, or tunnel tool works the same way. This document exists so that tool (or you, manually)
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
| DNS records | your chosen external tool (e.g. `../synology-site-deployer`), if any |
| Cloudflare Tunnel / Access | your chosen external tool, if any |
| TLS certificates | your chosen external tool, if any (typically via Cloudflare) |
| Reverse proxy ingress rules | your chosen external tool, if any |
| Which container/port gets routed | This repo documents it; your chosen external tool configures it |
| NAS volume / persistent path | Your chosen external tool decides at deploy time, if used; this repo never assumes one |

This repo's job is to stay predictable: a fixed service name (`localai-open-webui`) and a
configurable port (`OPEN_WEBUI_PORT`, default `3000`) that any tunnel/reverse-proxy tool can point
at. See [`deployer-integration.md`](deployer-integration.md) for how that handoff is expected to
work, illustrated with `../synology-site-deployer` as one example.

## Before enabling public exposure

See [`pre-exposure-checklist.md`](pre-exposure-checklist.md) for the full standalone checklist —
disable signup, set a strong admin password, confirm only Open WebUI is routed, and review what's
in `documents/` before it becomes reachable by anyone with valid login credentials.
