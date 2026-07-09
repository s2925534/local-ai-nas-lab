# Local AI NAS manual

Manual setup walkthrough for running this project on a Synology NAS (developed against a DS1525+,
but nothing here is model-specific beyond "runs Docker via Container Manager"). No specific
Synology volume is referenced anywhere below — see [`portable-local-mode.md`](portable-local-mode.md)
and [`deployer-integration.md`](deployer-integration.md) for why.

## Prerequisites

- DSM with **Container Manager** (or the older Docker package) installed.
- SSH access to the NAS (optional but convenient for running the shell scripts directly; Container
  Manager's UI alone can also start the compose stack).
- A persistent folder you control on the NAS, for `LOCAL_AI_BASE_PATH`.

## Manual steps

1. **Install or open Container Manager** from Package Center / the DSM main menu.
2. **Get this repository onto the NAS.** Either:
   - Clone it directly on the NAS if `git` is available over SSH, or
   - Copy the files over (e.g. via File Station, `scp`, or Synology Drive), or
   - Let [`../synology-site-deployer`](../../synology-site-deployer) deploy it later (see
     [`deployer-integration.md`](deployer-integration.md)) — in that case, skip to step 5 once the
     deployer has placed the files and `.env`.
3. **Copy `.env.example` to `.env`**:
   ```bash
   cp .env.example .env
   ```
4. **Set `LOCAL_AI_BASE_PATH`** — only if running manually (not via the deployer). Point it at any
   folder you control and want models/chat data/documents to persist in, for example a shared
   folder you've created for this purpose. Do not assume a specific volume; choose whatever path
   exists on your NAS. If using `../synology-site-deployer`, skip this — the deployer manages the
   path for you (see step 5).
5. **If using `../synology-site-deployer`**, let it manage the deployment path and `.env`
   generation instead of setting these yourself. See [`deployer-integration.md`](deployer-integration.md).
6. **Run the bootstrap script** to create folders, start containers, pull models, and health-check
   in one step:
   ```bash
   ./scripts/bootstrap-local-ai.sh
   ```
   (Or, without SSH access, start the stack from Container Manager's Project view pointed at this
   repo's `docker-compose.yml`, then run `scripts/create-folders.sh` / `pull-models.sh` /
   `health-check.sh` manually over SSH, or accept that model pulling can also be done from within
   Open WebUI's own model-management UI.)
7. **Open Open WebUI locally** — `http://<nas-ip>:${OPEN_WEBUI_PORT}` (default port `3000`) from a
   browser on the same LAN.
8. **Create the Open WebUI admin user** — the first account created becomes the admin. Signup is
   disabled for everyone else by default (`ENABLE_SIGNUP=false`).
9. **Test prompts** — try the starter prompts in `prompts/` (e.g.
   `prompts/coding/codex-prompt-generator.md`) or just chat directly to confirm inference works.
10. **Confirm containers restart** — reboot the NAS (or `docker compose restart`) and confirm both
    `localai-ollama` and `localai-open-webui` come back automatically
    (`restart: unless-stopped` in `docker-compose.yml` handles this).
11. **Keep LAN-only** until secure public access is ready through
    [`../synology-site-deployer`](../../synology-site-deployer). Do not port-forward or expose
    Ollama in the meantime — see [`security.md`](security.md).

## Validation performed vs. deferred

This manual was written and the Phase 1 scripts/compose file were validated for syntax
(`bash -n`, `docker compose config` where a Docker daemon was available) from a development
machine, **not** from the actual Synology NAS — the NAS is not reachable from this IDE
environment. The following require manual verification directly on the NAS or another real Docker
host, and are tracked as a checklist rather than claimed as done:

- [ ] Container Manager successfully starts the compose stack from this repo's `docker-compose.yml`.
- [ ] `scripts/bootstrap-local-ai.sh` completes end-to-end on the NAS (folder creation through
      health check).
- [ ] Model pulls succeed over the NAS's actual internet connection within reasonable time.
- [ ] Open WebUI is reachable from another LAN device at `http://<nas-ip>:3000`.
- [ ] Ollama's port is confirmed **not** reachable from another LAN device (only `127.0.0.1`).
- [ ] Containers survive a NAS reboot and come back healthy automatically.
- [ ] Folder permissions under the chosen `LOCAL_AI_BASE_PATH` allow the containers to read/write
      without manual `chmod`/`chown` intervention beyond what's documented in
      [`troubleshooting.md`](troubleshooting.md).

If you run through this checklist on real hardware, update this section (and `TODO.md`) with the
results.
