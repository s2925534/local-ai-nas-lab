#!/bin/sh
# Check the health of the local AI stack: .env, folders, Docker, containers, and HTTP endpoints.
# Prints a pass/fail line per check and a summary at the end. Exits non-zero if anything failed.

set -u

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
cd "$REPO_ROOT"

pass_count=0
fail_count=0
warn_count=0

pass() { echo "  [PASS] $1"; pass_count=$((pass_count + 1)); }
fail() { echo "  [FAIL] $1"; fail_count=$((fail_count + 1)); }
warn() { echo "  [WARN] $1"; warn_count=$((warn_count + 1)); }

echo "== Environment =="
if [ -f .env ]; then
  pass ".env found"
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
else
  warn ".env not found — using .env.example-equivalent defaults (copy .env.example to .env for real use)"
fi

LOCAL_AI_BASE_PATH="${LOCAL_AI_BASE_PATH:-./data/local-ai}"
OPEN_WEBUI_PORT="${OPEN_WEBUI_PORT:-3000}"
OLLAMA_PORT="${OLLAMA_PORT:-11434}"
OLLAMA_BIND_HOST="${OLLAMA_BIND_HOST:-127.0.0.1}"
OPEN_WEBUI_BIND_HOST="${OPEN_WEBUI_BIND_HOST:-0.0.0.0}"
PORTABLE_MODE="${PORTABLE_MODE:-false}"

if [ -n "$LOCAL_AI_BASE_PATH" ]; then
  pass "LOCAL_AI_BASE_PATH is set ($LOCAL_AI_BASE_PATH)"
else
  fail "LOCAL_AI_BASE_PATH is empty"
fi

echo ""
echo "== Docker =="
if command -v docker >/dev/null 2>&1; then
  pass "docker CLI available"
else
  fail "docker CLI not found on PATH"
fi

if docker compose version >/dev/null 2>&1; then
  pass "docker compose available"
else
  warn "docker compose not available (or Docker daemon not running)"
fi

echo ""
echo "== Containers =="
for name in localai-ollama localai-open-webui; do
  state=$(docker inspect -f '{{.State.Running}}' "$name" 2>/dev/null || echo "")
  if [ "$state" = "true" ]; then
    pass "$name is running"
  elif [ "$state" = "false" ]; then
    fail "$name exists but is not running"
  else
    fail "$name not found (has the stack been started with 'docker compose up -d'?)"
  fi
done

echo ""
echo "== HTTP endpoints =="
if command -v curl >/dev/null 2>&1; then
  if curl -fsS -m 5 "http://localhost:${OPEN_WEBUI_PORT}/" >/dev/null 2>&1; then
    pass "Open WebUI responds on http://localhost:${OPEN_WEBUI_PORT}/"
  else
    fail "Open WebUI did not respond on http://localhost:${OPEN_WEBUI_PORT}/"
  fi

  if curl -fsS -m 5 "http://127.0.0.1:${OLLAMA_PORT}/api/tags" >/dev/null 2>&1; then
    pass "Ollama responds on http://127.0.0.1:${OLLAMA_PORT}/"
    models=$(curl -fsS -m 5 "http://127.0.0.1:${OLLAMA_PORT}/api/tags" 2>/dev/null | grep -o '"name":"[^"]*"' | wc -l | tr -d ' ')
    if [ -n "$models" ] && [ "$models" -gt 0 ] 2>/dev/null; then
      pass "Ollama reports $models model(s) available"
    else
      warn "Ollama is up but no models are pulled yet (run scripts/pull-models.sh)"
    fi
  else
    fail "Ollama did not respond on http://127.0.0.1:${OLLAMA_PORT}/ (only checked host-local, matching the default bind)"
  fi
else
  warn "curl not available — skipping HTTP endpoint checks"
fi

echo ""
echo "== Persistent folders =="
required_top="ollama open-webui documents prompts exports backups logs memory"
for rel in $required_top; do
  if [ -d "$LOCAL_AI_BASE_PATH/$rel" ]; then
    pass "folder exists: $LOCAL_AI_BASE_PATH/$rel"
  else
    fail "folder missing: $LOCAL_AI_BASE_PATH/$rel (run scripts/create-folders.sh)"
  fi
done

memory_sub="rules feedback evals datasets"
for rel in $memory_sub; do
  if [ -d "$LOCAL_AI_BASE_PATH/memory/$rel" ]; then
    pass "memory folder exists: memory/$rel"
  else
    warn "memory folder missing: memory/$rel (run scripts/create-folders.sh)"
  fi
done

echo ""
echo "== Exposure sanity =="
if [ "$OLLAMA_BIND_HOST" = "0.0.0.0" ]; then
  warn "OLLAMA_BIND_HOST=0.0.0.0 — Ollama's port would be reachable beyond localhost. Not recommended; see docs/security.md."
else
  pass "OLLAMA_BIND_HOST is not 0.0.0.0 ($OLLAMA_BIND_HOST)"
fi

if [ "$PORTABLE_MODE" = "true" ]; then
  if [ "$OPEN_WEBUI_BIND_HOST" != "127.0.0.1" ] && [ "$OPEN_WEBUI_BIND_HOST" != "localhost" ]; then
    warn "PORTABLE_MODE=true but OPEN_WEBUI_BIND_HOST=$OPEN_WEBUI_BIND_HOST (expected 127.0.0.1) — portable mode should stay localhost-only by default. See docs/portable-local-mode.md."
  else
    pass "portable mode bind host is localhost-only"
  fi
fi

echo ""
echo "========================================"
echo "Summary: $pass_count passed, $warn_count warning(s), $fail_count failed"

if [ "$fail_count" -gt 0 ]; then
  echo "Overall: FAIL"
  exit 1
fi

echo "Overall: PASS"
