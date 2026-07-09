# Future flags

This document lists every forward-looking capability considered for this project, as an
environment-variable-style flag name plus a one- or two-line description. **All of these are
documentation only unless explicitly listed in `.env.example` and wired into a script or compose
file.** As of Phase 1, the flags that actually exist in `.env.example` are:

```
ENABLE_FEEDBACK_LEARNING_LOOP=false
ENABLE_LOCAL_MEMORY_STORE=false
ENABLE_PROMPT_OPTIMIZER=false
ENABLE_EVALUATION_HARNESS=false
ENABLE_FINE_TUNING_EXPERIMENTS=false
ENABLE_PERSONAL_MODEL_PATH=false
ENABLE_MODEL_DISTILLATION_EXPERIMENTS=false
```

Every other flag below is a **planning placeholder** — a name reserved for a future `.env` entry,
not something currently read by any script. Adding real behavior behind any of these is future
work, tracked in `TODO.md` phases 5–9.

## Domain / exposure

**`ENABLE_PUBLIC_DOMAIN`**
Expose Open WebUI at `ai.veloso.dev` (or your configured `LOCAL_AI_DOMAIN`) through a
deployer-managed reverse proxy or tunnel. Actual routing is implemented in
`../synology-site-deployer`, never here.

**`ENABLE_DEPLOYER_DOMAIN_MANAGEMENT`**
Allow `../synology-site-deployer` to manage DNS, Cloudflare, tunnel, reverse proxy, certificates,
and hostname exposure for this project's Open WebUI instance.

**`ENABLE_TAILSCALE_ONLY_MODE`**
Restrict UI access so only Tailscale clients can reach it (e.g. bind only to the Tailscale
interface, or gate behind a Tailscale-aware proxy).

**`ENABLE_MODEL_VERSION_PINNING`**
Pin `ollama/ollama` and `ghcr.io/open-webui/open-webui` image tags to specific versions instead of
`latest`/`main`, for reproducible deployments.

## Data / retrieval

**`ENABLE_RAG_PIPELINE`**
Add a more formal document ingestion and vector database pipeline, beyond Open WebUI's built-in
document Q&A.

## Local API

**`ENABLE_LOCAL_AI_API`**
Create a local API wrapper around Ollama with task-specific endpoints:
`POST /rewrite`, `POST /summarise`, `POST /generate-app-spec`, `POST /generate-codex-prompt`,
`POST /ask-documents`, `POST /code-helper`. See Phase 5 in [`phase-plan.md`](phase-plan.md).

**`ENABLE_API_KEY_AUTH`**
Protect the future local AI API with API keys.

## Assistants / prompt library

**`ENABLE_APP_IDEAS_ASSISTANT`**
Structured prompts and document folders for an App Ideas project
(`prompts/app-specs/`, `documents/app-ideas/`).

**`ENABLE_RESEARCH_ASSISTANT`**
Structured prompts and document folders for research/MPhil-style material
(`prompts/research/`, `documents/research/`).

**`ENABLE_CODEBASE_ASSISTANT`**
Safe codebase indexing workflow for coding-assistant prompts.

**`ENABLE_MOBILE_APP_BACKEND`**
Prepare endpoints for a future private mobile app that connects to the NAS AI backend.

## Hardware expansion

**`ENABLE_GPU_REMOTE_BACKEND`**
Let Open WebUI connect to a future GPU workstation running Ollama remotely, while the NAS remains
the storage/UI/orchestration layer. See Phase 6.

**`ENABLE_MULTI_MODEL_ROUTER`**
Choose a model automatically based on task type — rewrite → small model, coding → coder model,
research → stronger general model, documents → RAG + embedding model.

**`ENABLE_LARGE_MODELS`**
Document/support 14B, 32B, 70B, or larger models, only once hardware is upgraded or a GPU backend
is added. Not part of the MVP model set.

## Operations

**`ENABLE_BACKUP_AUTOMATION`**
Schedule automatic backups of Open WebUI data, prompts, documents, and exports (beyond the manual
`scripts/backup-local-ai.sh`).

**`ENABLE_MONITORING`**
Resource monitoring, container health checks, logs, and alerts beyond `scripts/health-check.sh`.

**`ENABLE_AUDIT_LOGS`**
Track local AI usage, especially relevant if the instance is ever shared with other users.

**`ENABLE_SSO`**
SSO integration, if Open WebUI and a chosen identity provider support it.

**`ENABLE_OPENAI_COMPATIBLE_GATEWAY`**
An OpenAI-compatible API gateway, for apps/tools that expect OpenAI-style endpoints to talk to
local models instead.

**`ENABLE_HYBRID_CLOUD_MODE`**
Allow optional paid APIs for tasks local models handle poorly, while keeping local models the
default — a cost/quality escape hatch, not a replacement of the local-first approach.

## Portable local mode

**`ENABLE_PORTABLE_LOCAL_MODE`**
Self-contained portable mode: copy the project folder to any computer, run a `start` command,
get a working local browser instance. No NAS, domain, Cloudflare, or deployer dependency. Uses
`PORTABLE_DATA_PATH` and localhost bindings by default. See
[`portable-local-mode.md`](portable-local-mode.md).

**`ENABLE_PORTABLE_START_STOP_SCRIPTS`**
Cross-platform `start`/`stop` scripts (Mac/Linux `.sh`, Windows `.ps1`) for the portable stack.

**`ENABLE_PORTABLE_SQLITE_METADATA`**
If a custom local app layer is added later, use SQLite for portable local metadata so state moves
between computers as a single file.

**`ENABLE_PORTABLE_DESKTOP_LAUNCHER`**
A future Electron or Tauri launcher that starts the stack, opens the browser or an embedded UI, and
hides Docker details from the user.

**`ENABLE_OFFLINE_MODEL_PACKS`**
Carry pre-downloaded models and container images with the project for offline setup. Possible but
not part of the MVP — models and images can be very large (see
[`portable-local-mode.md`](portable-local-mode.md)).

**`ENABLE_IMPORT_EXPORT_PORTABLE_STATE`**
Import/export tools for documents, prompts, Open WebUI state, settings, and local metadata, so a
portable instance can move between computers more easily.

## Feedback learning loop (Phase 8)

**`ENABLE_FEEDBACK_LEARNING_LOOP`** *(present in `.env.example`, default `false`)*
Let the system improve over time from user feedback without retraining model weights: store
ratings, corrections, accepted/rejected answers, preferred formats, project rules, and reusable
prompt improvements in local files or SQLite, then use that as retrieval context for future
responses. See [`learning-and-self-improvement.md`](learning-and-self-improvement.md).

**`ENABLE_LOCAL_MEMORY_STORE`** *(present in `.env.example`, default `false`)*
A local memory store for durable project rules, user preferences, corrections, examples, and
reusable knowledge.

**`ENABLE_PROMPT_OPTIMIZER`** *(present in `.env.example`, default `false`)*
Analyse accepted outputs and user corrections to improve prompt templates over time.

**`ENABLE_EVALUATION_HARNESS`** *(present in `.env.example`, default `false`)*
Test prompts and expected behaviours so local model or prompt changes can be evaluated before
being trusted.

## Personal model path (Phase 9, far future)

**`ENABLE_FINE_TUNING_EXPERIMENTS`** *(present in `.env.example`, default `false`)*
Experimental only. Use curated feedback data to create fine-tuning datasets for small open models.
Not part of the MVP, not recommended on NAS hardware, and not recommended until the memory/RAG
system is mature.

**`ENABLE_PERSONAL_MODEL_PATH`** *(present in `.env.example`, default `false`)*
Document and later experiment with a personal model that learns from local project data, feedback,
corrections, prompt templates, and curated examples — built on open models plus curated local
datasets, not trained from scratch.

**`ENABLE_MODEL_DISTILLATION_EXPERIMENTS`** *(present in `.env.example`, default `false`)*
Far-future experiments comparing, curating, and using outputs from multiple local models as
training/evaluation material for a smaller personal model. Must respect licenses, privacy, and
model terms. Not part of the MVP.

**`ENABLE_DATASET_CURATOR`**
Tools to review, approve, clean, tag, and export feedback/memory examples into datasets suitable
for evaluation or future fine-tuning.

**`ENABLE_MODEL_REGISTRY`**
Track installed models, their purpose, performance notes, hardware requirements, context limits,
strengths/weaknesses, and suitability for future feedback/fine-tuning experiments.

**`ENABLE_MODEL_EVALUATION_SCORECARD`**
Compare local models using repeatable prompts, ratings, speed notes, memory use, and task
suitability, before deciding which model to use for which workflow.
