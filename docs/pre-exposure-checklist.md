# Pre-public-exposure checklist

Status: **standalone checklist, Phase 4.** Use this before pointing any external tool (or manual
reverse proxy / tunnel) at Open WebUI. The underlying rules live in [`security.md`](security.md)
and [`reverse-proxy-domain.md`](reverse-proxy-domain.md); this document exists so there's one place
to run through, top to bottom, immediately before flipping `PUBLIC_EXPOSURE=true` (or equivalent) —
not a new set of rules.

## Checklist

- [ ] `ENABLE_SIGNUP=false` in `.env` — the first admin account already exists, and no one else can
      self-register.
- [ ] The Open WebUI admin account has a strong, unique password. This repo does not generate or
      manage that password — Open WebUI's own database does.
- [ ] `OLLAMA_BIND_HOST` is still `127.0.0.1`. Never route Ollama's port (`11434`) through any
      tunnel, proxy, or DNS record — only Open WebUI is ever meant to be reachable.
- [ ] Only Open WebUI's container/port is configured in whatever external tool (if any) you're
      using — check its routing config directly, don't assume. See
      [`reverse-proxy-domain.md`](reverse-proxy-domain.md) for the intended routing.
- [ ] DSM (Synology admin UI), SSH, and Container Manager are not routed through this hostname or
      any related one.
- [ ] `LOCAL_AI_DOMAIN` is set to the hostname you actually intend to expose — no leftover example
      or placeholder value.
- [ ] You've reviewed what's currently in `${LOCAL_AI_BASE_PATH}/documents/` — anyone who can log
      in to Open WebUI once exposed may be able to reach it. Remove or hold back anything sensitive
      until you're confident in your access controls.
- [ ] If the future `memory/` tree (`memory/rules`, `memory/feedback`, `memory/evals`,
      `memory/datasets` — see [`learning-and-self-improvement.md`](learning-and-self-improvement.md))
      is in use, treat it with the same care as `documents/`.
- [ ] You've considered Tailscale as an alternative to public exposure for anything that's really
      just remote-admin access rather than something you want publicly reachable — see
      [`security.md`](security.md#remote-access-prefer-tailscale).
- [ ] Whatever tool manages DNS/Cloudflare/tunnel/certificates for you (if any) is something you
      trust and understand — this repo has no opinion on which one, and implements none of it
      itself. See [`deployer-integration.md`](deployer-integration.md).

## After exposing

- Periodically re-check that `ENABLE_SIGNUP` hasn't been flipped back to `true` (e.g. after
  temporarily enabling it to create a second account, per
  [`troubleshooting.md`](troubleshooting.md#loginsignup-problems)).
- Periodically re-check that nothing besides Open WebUI's port is routed, especially after changing
  or reconfiguring whatever external tool you use for exposure.

## What this checklist is not

It is not a substitute for reading [`security.md`](security.md) once, in full, before your first
exposure decision. It's a fast pass to run every time you're about to (re-)expose the instance,
after you already understand the reasoning behind each item.
