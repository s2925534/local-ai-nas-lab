#!/bin/sh
# One-command setup: create folders, start containers, wait for them, pull default models, and
# health-check the result. Safe to re-run — every step here is idempotent and nothing is deleted.

set -u

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
cd "$REPO_ROOT"

if [ ! -f .env ]; then
  echo "No .env found. Copying .env.example to .env with safe LAN-only defaults."
  cp .env.example .env
fi

set -a
# shellcheck disable=SC1091
. ./.env
set +a

OPEN_WEBUI_PORT="${OPEN_WEBUI_PORT:-3000}"
OLLAMA_PORT="${OLLAMA_PORT:-11434}"
AUTO_PULL_MODELS="${AUTO_PULL_MODELS:-true}"
AUTO_PULL_MODELS_ON_BOOTSTRAP="${AUTO_PULL_MODELS_ON_BOOTSTRAP:-true}"

echo "=========================================="
echo " Local AI NAS Lab — bootstrap"
echo "=========================================="

echo ""
echo "Step 1/6: Creating persistent folders..."
"$SCRIPT_DIR/create-folders.sh"

echo ""
echo "Step 2/6: Starting Docker Compose stack..."
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker is not available on PATH." >&2
  exit 1
fi
docker compose up -d

echo ""
echo "Step 3/6: Waiting for Ollama to become available on 127.0.0.1:${OLLAMA_PORT}..."
attempt=0
max_attempts=30
ollama_ready=false
while [ "$attempt" -lt "$max_attempts" ]; do
  if command -v curl >/dev/null 2>&1 && curl -fsS -m 3 "http://127.0.0.1:${OLLAMA_PORT}/api/tags" >/dev/null 2>&1; then
    ollama_ready=true
    break
  fi
  attempt=$((attempt + 1))
  sleep 2
done
if [ "$ollama_ready" = "true" ]; then
  echo "Ollama is up."
else
  echo "WARNING: Ollama did not respond after $((max_attempts * 2))s. Continuing anyway — check 'docker compose logs ollama'." >&2
fi

echo ""
echo "Step 4/6: Waiting for Open WebUI to become available on localhost:${OPEN_WEBUI_PORT}..."
attempt=0
webui_ready=false
while [ "$attempt" -lt "$max_attempts" ]; do
  if command -v curl >/dev/null 2>&1 && curl -fsS -m 3 "http://localhost:${OPEN_WEBUI_PORT}/" >/dev/null 2>&1; then
    webui_ready=true
    break
  fi
  attempt=$((attempt + 1))
  sleep 2
done
if [ "$webui_ready" = "true" ]; then
  echo "Open WebUI is up."
else
  echo "WARNING: Open WebUI did not respond after $((max_attempts * 2))s. Continuing anyway — check 'docker compose logs open-webui'." >&2
fi

echo ""
echo "Step 5/6: Pulling default models..."
if [ "$AUTO_PULL_MODELS" = "true" ] && [ "$AUTO_PULL_MODELS_ON_BOOTSTRAP" = "true" ]; then
  "$SCRIPT_DIR/pull-models.sh" || echo "WARNING: one or more models failed to pull — see output above." >&2
else
  echo "Skipped (AUTO_PULL_MODELS or AUTO_PULL_MODELS_ON_BOOTSTRAP is not 'true'). Run scripts/pull-models.sh manually when ready."
fi

echo ""
echo "Step 6/6: Running health check..."
"$SCRIPT_DIR/health-check.sh" || true

echo ""
echo "=========================================="
echo " Done"
echo "=========================================="
echo "Open WebUI:   http://localhost:${OPEN_WEBUI_PORT}"
nas_ip=$(command -v ipconfig >/dev/null 2>&1 && ipconfig getifaddr en0 2>/dev/null || true)
if [ -n "${nas_ip:-}" ]; then
  echo "On your LAN:  http://${nas_ip}:${OPEN_WEBUI_PORT}"
else
  echo "On your LAN:  http://<this-host-ip>:${OPEN_WEBUI_PORT}"
fi
echo ""
echo "Reminder: public exposure (Cloudflare, DNS, tunnels, certificates) is handled by"
echo "../synology-site-deployer, not by this repo. See docs/reverse-proxy-domain.md."
echo "Reminder: Ollama (port ${OLLAMA_PORT}) must never be exposed publicly. See docs/security.md."
