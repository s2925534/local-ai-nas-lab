# Security

## Defaults

- **LAN-only is the default.** `DEPLOY_MODE=lan_only` and `PUBLIC_EXPOSURE=false` in
  `.env.example`. Nothing in this repo requires opening a port on your router.
- **Ollama is never exposed publicly.** `OLLAMA_BIND_HOST` defaults to `127.0.0.1`. Open WebUI
  reaches Ollama over the internal Docker network (`local_ai_net`), not through the host port. Do
  not change `OLLAMA_BIND_HOST` to `0.0.0.0` unless you understand and accept that anyone who can
  reach that port can run inference and manage models with no authentication.
- **Open WebUI signup is disabled by default** (`ENABLE_SIGNUP=false`). Create the first admin
  account before anyone else can reach the instance if you widen exposure beyond your own trusted
  LAN, and leave signup disabled afterward.
- **No router port forwarding is required or documented for the MVP.** If you want private remote
  access, use Tailscale (below), not port forwarding.
- **DSM, SSH, Container Manager, and Ollama must never be exposed to the public internet.** This
  repo has no feature that does this; do not add one manually.

## Remote access: prefer Tailscale

For admin/remote access to the NAS or to Open WebUI without opening any public port, use Tailscale
(matching the convention already used by
[`../synology-site-deployer`](../../synology-site-deployer), see its
`docs/remote-nas-access.md`). `.env.example` includes `TAILSCALE_ADMIN_ACCESS=true` as a
documentation flag — this repo does not install or configure Tailscale itself; install it via
Synology Package Center (or your OS) and use its private network address to reach Open WebUI or SSH
into the NAS.

## Public exposure

If you eventually want `ai.veloso.dev` (or another hostname) to reach Open WebUI from the public
internet:

1. That is entirely handled by [`../synology-site-deployer`](../../synology-site-deployer) —
   Cloudflare Tunnel, DNS, certificates, and reverse-proxy routing all live there. This repo does
   not implement any of it. See [`deployer-integration.md`](deployer-integration.md) and
   [`reverse-proxy-domain.md`](reverse-proxy-domain.md).
2. Only Open WebUI's port should ever be routed. Ollama's port (`11434`) must never appear in any
   public route or tunnel ingress rule.
3. Before enabling public exposure, confirm: signup is disabled, the admin account has a strong,
   unique password, and you've reviewed what's in `documents/` (see below) — it may become
   reachable by anyone who can log in.
4. Use strong, unique credentials for the Open WebUI admin account. This repo does not generate or
   manage passwords for you.

## Private data

- Treat everything under `${LOCAL_AI_BASE_PATH}/documents/` as private. It is meant for your own
  files fed to the AI for Q&A; do not assume it is safe to expose or share.
- Do not upload sensitive documents until you've confirmed access controls (LAN-only, or a working
  auth layer if exposed) are actually in place — verify, don't assume.
- The future `memory/` tree (`memory/rules`, `memory/feedback`, `memory/evals`,
  `memory/datasets` — see [`learning-and-self-improvement.md`](learning-and-self-improvement.md))
  will hold your feedback, corrections, and examples once that feature exists. Treat it as private
  data with the same care as `documents/` — it's a record of your usage patterns and content.
- `backups/`, `exports/`, and `logs/` can all contain chat content or document excerpts. They are
  git-ignored and should stay off any public-facing path.

## Portable mode

- In portable mode, services bind to `127.0.0.1` only by default
  (`PORTABLE_USE_LOCALHOST_ONLY=true`). Nothing is reachable from the LAN unless you deliberately
  change the bind host.
- Portable mode never exposes anything publicly by itself — there is no tunnel, no port forward, no
  Cloudflare involvement in portable mode. See [`portable-local-mode.md`](portable-local-mode.md).

## Secrets

- Never commit `.env` — it's git-ignored (see `.gitignore`). Only `.env.example` (no real secrets)
  is committed.
- This repo currently has no API keys or credentials of its own (Open WebUI's admin password lives
  in its own database, not in `.env`). If a future local API wrapper adds `ENABLE_API_KEY_AUTH`
  (see [`future-flags.md`](future-flags.md)), generated keys must follow the same
  never-commit-secrets rule.

## Fine-tuning / personal-model data (far future)

If Phase 9 (fine-tuning/distillation experiments, see [`future-flags.md`](future-flags.md)) is ever
acted on: document the license of any base model before fine-tuning it, document the provenance of
every example in a training dataset (your own corrections/accepted outputs only — not scraped or
third-party copyrighted content), and evaluate any resulting model before trusting its output. None
of this is implemented yet.
