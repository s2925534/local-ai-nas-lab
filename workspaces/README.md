# Workspaces

This repo is meant to be cloned and reused by anyone — no domain, hostname, or NAS path is
hardcoded anywhere (see [`docs/decision-log.md`](../docs/decision-log.md)). If you only ever run
one instance, you don't need this folder at all: just use `.env` at the repo root, as described in
the main [`README.md`](../README.md).

`workspaces/` exists for the case where you maintain **more than one** site/deployment from the
same clone of this repo — for example, your own NAS, a friend's NAS you help manage, and a local
test box — each with its own hostname, display name, and persistent data path. This mirrors the
"workspace" concept already used by
[`../synology-site-deployer`](../../synology-site-deployer) (see that project's README,
"Workspaces (Multiple Cloudflare Accounts, Multiple NAS Targets)"), so the same `<name>` can mean
the same site in both projects if you use both together — the two are not mechanically linked,
this is purely a naming convention for your own clarity.

## Convention

```
workspaces/
  <name>/
    site.env       # your real, gitignored config for that site — never committed
  example/
    site.env.example   # tracked template showing which keys a workspace typically overrides
```

Only files matching `*.env` are gitignored (see `.gitignore`); `site.env.example` files are
tracked so the convention itself is documented, without ever committing anyone's real domain or
path.

## Usage

Create your own workspace file from the template:

```bash
mkdir -p workspaces/my-site
cp workspaces/example/site.env.example workspaces/my-site/site.env
# edit workspaces/my-site/site.env with that site's real domain, base path, etc.
```

Then either:

- Use it as your active `.env` for that site: `cp workspaces/my-site/site.env .env`, or
- Point Docker Compose at it directly, layered on top of the root `.env` for anything a workspace
  file doesn't override (Compose applies later `--env-file` values on top of earlier ones):
  ```bash
  docker compose --env-file .env --env-file workspaces/my-site/site.env up -d
  ```

A workspace file only needs to contain the keys that differ from `.env.example`'s defaults —
typically `LOCAL_AI_DOMAIN`, `WEBUI_NAME`, and `LOCAL_AI_BASE_PATH` at minimum. See
[`workspaces/example/site.env.example`](example/site.env.example).
