#!/bin/sh
# Create the persistent folder structure under LOCAL_AI_BASE_PATH.
#
# Safe to run multiple times: only creates missing folders, never deletes or overwrites anything.
# Never assumes a Synology volume path — LOCAL_AI_BASE_PATH must be set explicitly (in .env or the
# environment) or this script refuses to run.

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
cd "$REPO_ROOT"

# Load .env if present, without clobbering variables already set in the environment.
if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
fi

# Local-development-only fallback. Anything deployer-managed or NAS-manual should set this
# explicitly in .env — see docs/deployer-integration.md and docs/portable-local-mode.md.
LOCAL_AI_BASE_PATH="${LOCAL_AI_BASE_PATH:-./data/local-ai}"

if [ -z "$LOCAL_AI_BASE_PATH" ]; then
  echo "ERROR: LOCAL_AI_BASE_PATH is empty. Refusing to create folders without a target path." >&2
  echo "Set LOCAL_AI_BASE_PATH in .env (see .env.example) before running this script." >&2
  exit 1
fi

echo "Using LOCAL_AI_BASE_PATH=$LOCAL_AI_BASE_PATH"

# Folder list, relative to LOCAL_AI_BASE_PATH. Memory folders are created now so future
# feedback/learning features (see docs/learning-and-self-improvement.md) don't need a migration
# step later — no learning logic reads or writes them yet.
folders="
ollama
open-webui
documents
documents/app-ideas
documents/research
documents/nas-admin
documents/coding
documents/quantainer
prompts
prompts/app-specs
prompts/coding
prompts/email
prompts/research
prompts/nas-admin
prompts/learning
exports
exports/chats
exports/summaries
backups
logs
memory
memory/rules
memory/feedback
memory/evals
memory/datasets
"

created=0
existed=0

for rel in $folders; do
  target="$LOCAL_AI_BASE_PATH/$rel"
  if [ -d "$target" ]; then
    existed=$((existed + 1))
  else
    mkdir -p "$target"
    echo "Created: $target"
    created=$((created + 1))
  fi
done

echo ""
echo "Done. $created folder(s) created, $existed already existed."
