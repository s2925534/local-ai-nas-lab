#!/bin/sh
# Pull the MVP-friendly default model set into the running Ollama container.
#
# Continues past individual model failures and reports them at the end, so one bad pull doesn't
# block the rest. Only pulls the small, NAS-friendly default models below (or whatever is
# configured in .env) — this project does not pull 14B/32B/70B+ models automatically. See
# docs/future-flags.md (ENABLE_LARGE_MODELS) for the large-model path.

set -u

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
cd "$REPO_ROOT"

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
fi

MODEL_GENERAL_SMALL="${MODEL_GENERAL_SMALL:-llama3.2:3b}"
MODEL_GENERAL_MEDIUM="${MODEL_GENERAL_MEDIUM:-qwen2.5:7b}"
MODEL_CODING="${MODEL_CODING:-qwen2.5-coder:7b}"
MODEL_EMBEDDING="${MODEL_EMBEDDING:-nomic-embed-text}"

CONTAINER_NAME="localai-ollama"

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker is not available on PATH. Install/start Docker before pulling models." >&2
  exit 1
fi

if ! docker inspect -f '{{.State.Running}}' "$CONTAINER_NAME" >/dev/null 2>&1; then
  echo "ERROR: container '$CONTAINER_NAME' was not found." >&2
  echo "Start the stack first: docker compose up -d" >&2
  exit 1
fi

running=$(docker inspect -f '{{.State.Running}}' "$CONTAINER_NAME" 2>/dev/null || echo "false")
if [ "$running" != "true" ]; then
  echo "ERROR: container '$CONTAINER_NAME' exists but is not running." >&2
  echo "Start the stack first: docker compose up -d" >&2
  exit 1
fi

echo "This project intentionally sticks to small/medium models for NAS-class hardware."
echo "Large models (14B, 32B, 70B, 120B+) are out of scope for the MVP — see docs/future-flags.md."
echo ""

models="$MODEL_GENERAL_SMALL $MODEL_GENERAL_MEDIUM $MODEL_CODING $MODEL_EMBEDDING"

failed=""
succeeded=""

for model in $models; do
  echo "Pulling $model ..."
  if docker exec "$CONTAINER_NAME" ollama pull "$model"; then
    succeeded="$succeeded $model"
  else
    echo "WARNING: failed to pull $model — continuing with the rest." >&2
    failed="$failed $model"
  fi
  echo ""
done

echo "----------------------------------------"
echo "Model pull summary:"
if [ -n "$succeeded" ]; then
  echo "  Succeeded:$succeeded"
fi
if [ -n "$failed" ]; then
  echo "  Failed:   $failed"
  echo ""
  echo "Re-run this script to retry — already-pulled models are skipped by Ollama itself."
  exit 1
fi

echo "All models pulled successfully."
