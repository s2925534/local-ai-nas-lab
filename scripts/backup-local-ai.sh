#!/bin/sh
# Back up persistent data under LOCAL_AI_BASE_PATH into a timestamped tar.gz under
# LOCAL_AI_BASE_PATH/backups. Read-only with respect to source data — never deletes or modifies
# anything it backs up, and never deletes old backups (that's a manual/future decision, see
# docs/future-flags.md ENABLE_BACKUP_AUTOMATION for a scheduled version of this).
#
# Intentionally excludes ollama/ — model weights are large and re-downloadable via
# scripts/pull-models.sh, so backing them up would be slow and mostly wasted space. Everything
# that represents your own data (chats, documents, prompts, exports, memory, logs) is included.

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
cd "$REPO_ROOT"

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
fi

LOCAL_AI_BASE_PATH="${LOCAL_AI_BASE_PATH:-./data/local-ai}"

if [ -z "$LOCAL_AI_BASE_PATH" ]; then
  echo "ERROR: LOCAL_AI_BASE_PATH is empty. Refusing to back up without a source path." >&2
  exit 1
fi

if [ ! -d "$LOCAL_AI_BASE_PATH" ]; then
  echo "ERROR: $LOCAL_AI_BASE_PATH does not exist. Run scripts/create-folders.sh first." >&2
  exit 1
fi

backup_dir="$LOCAL_AI_BASE_PATH/backups"
mkdir -p "$backup_dir"

timestamp=$(date +%Y%m%d-%H%M%S)
archive_name="local-ai-backup-${timestamp}.tar.gz"
archive_path="$backup_dir/$archive_name"

# Only include folders that exist, so this doesn't fail on a fresh setup that hasn't used every
# folder yet.
targets=""
for rel in open-webui documents prompts exports memory logs; do
  if [ -d "$LOCAL_AI_BASE_PATH/$rel" ]; then
    targets="$targets $rel"
  fi
done

if [ -z "$targets" ]; then
  echo "Nothing to back up yet — no data folders found under $LOCAL_AI_BASE_PATH." >&2
  exit 1
fi

echo "Backing up:$targets"
echo "Excluding: ollama (model weights — re-downloadable via scripts/pull-models.sh)"
echo "Excluding: backups (avoid nesting previous backups inside a new one)"

# shellcheck disable=SC2086
tar -czf "$archive_path" -C "$LOCAL_AI_BASE_PATH" $targets

echo ""
echo "Backup written to: $archive_path"
echo "Old backups are never deleted automatically — clean up $backup_dir manually when needed."
