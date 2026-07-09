# TODO

Status legend: `[ ]` not started, `[x]` done.

This file is the single source of truth for project progress. Update it in the same commit as the
work it describes.

## Phase 0 — Planning and documentation foundation

- [x] Create `README.md`
- [x] Create `docs/architecture.md`
- [x] Create `docs/phase-plan.md`
- [x] Create `docs/decision-log.md`
- [x] Create `docs/deployer-integration.md`
- [x] Create `docs/security.md`
- [x] Create `docs/reverse-proxy-domain.md`
- [x] Create `docs/portable-local-mode.md`
- [x] Create `docs/learning-and-self-improvement.md`
- [x] Create `docs/future-flags.md`
- [x] Create `docs/local-ai-nas-manual.md`
- [x] Create `docs/troubleshooting.md`
- [x] Create `TODO.md` with phases and checkboxes
- [x] Validate Markdown structure and internal links
- [x] Commit Phase 0 planning docs
- [x] Push Phase 0 to GitHub

## Phase 1 — MVP foundation

- [x] `.env.example` with safe, LAN-only defaults
- [x] `.gitignore` (no `.env`, no runtime data, no `.idea`-sensitive files)
- [x] `docker-compose.yml` for Ollama + Open WebUI
- [x] `scripts/create-folders.sh`
- [x] `scripts/bootstrap-local-ai.sh`
- [x] `scripts/pull-models.sh`
- [x] `scripts/health-check.sh`
- [x] `LICENSE`
- [x] Minimal starter prompt files (`prompts/`)
- [x] Starter sample envs (`examples/sample-envs/`) and model test log template (`examples/test-prompts.md`)
- [x] Validate shell syntax (`bash -n` / `sh -n`) on all scripts, plus a functional idempotency test of `create-folders.sh`
- [x] Validate Docker Compose file structure (no Docker daemon available in this environment — `docker compose config` deferred to a real Docker host; see `docs/local-ai-nas-manual.md` validation checklist)
- [x] Confirm `.env.example` variables match script usage
- [x] Confirm no runtime data / `.env` staged
- [x] Commit Phase 1 foundation
- [x] Push Phase 1 to GitHub

## Phase 2 — Deployer integration readiness

- [x] Document how `../synology-site-deployer` should consume this repo (`docs/deployer-integration.md`)
- [ ] Add optional deployer-facing metadata file if useful (e.g. `deploy.meta.json`) — deferred, not required for MVP
- [x] Confirm deployer-managed persistent path expectation (`LOCAL_AI_BASE_PATH`)
- [x] Confirm deployer-managed Cloudflare/domain expectation
- [x] Confirm this repo avoids direct Cloudflare implementation

## Phase 3 — Local usefulness

- [x] Starter prompt library (`prompts/app-specs`, `prompts/coding`, `prompts/email`, `prompts/research`, `prompts/nas-admin`)
- [x] Expand prompt library with more task-specific templates (`mvp-feature-prioritizer`, `code-review-assistant`, `bug-to-fix-plan`, `meeting-follow-up`, `literature-comparison`, `container-log-triage`)
- [x] Document upload/RAG usage notes for Open WebUI (`docs/document-qa-and-rag.md`)
- [x] App Ideas assistant prompts (expanded — `mvp-feature-prioritizer.md`)
- [x] Research assistant prompts (expanded — `literature-comparison.md`)
- [x] Coding assistant prompts (expanded — `code-review-assistant.md`, `bug-to-fix-plan.md`)
- [x] `scripts/backup-local-ai.sh` (backup assistance — tested end-to-end, excludes re-downloadable model weights)
- [ ] Model performance test log template (`examples/test-prompts.md` seed exists; further expansion left for when real usage data accumulates)

## Phase 4 — Domain exposure readiness

- [x] Document `ai.veloso.dev` as recommended hostname (`docs/reverse-proxy-domain.md`)
- [x] Document that Cloudflare/DNS is handled by `../synology-site-deployer`
- [x] Document that only Open WebUI should ever be exposed
- [x] Document that Ollama must remain private
- [ ] Add a pre-public-exposure validation checklist as a standalone doc (currently embedded in `docs/security.md` / `docs/reverse-proxy-domain.md`; consider splitting out)

## Phase 5 — Future private AI API

- [ ] Plan local API wrapper around Ollama
- [ ] Plan API key authentication
- [ ] Plan endpoints: rewrite, summarise, app spec, code helper, document Q&A, feedback, memory, prompt improvement
- [ ] Do not overbuild unless explicitly requested

## Phase 6 — Future hardware expansion

- [ ] Document GPU backend option
- [ ] Document remote Ollama backend option
- [ ] Document NAS-as-storage/UI/orchestration-layer model
- [ ] Document large-model notes (14B/32B/70B+)

## Phase 7 — Future portable local mode

- [ ] Self-contained portable local setup that can be copied to any computer
- [ ] `start`/`stop` scripts for Mac/Linux
- [ ] `start`/`stop` scripts for Windows
- [ ] Portable data folder inside the project
- [ ] Local browser auto-launch
- [ ] SQLite or file-based local metadata where appropriate
- [ ] Keep NAS mode and portable mode clearly separate
- [ ] Document what can/cannot be truly portable (model size)

## Phase 8 — Future feedback learning loop

- [ ] Feedback capture plan and format
- [ ] Store ratings, corrections, accepted/rejected answers, preferred formats
- [ ] Store project rules and user corrections
- [ ] Markdown + JSONL now, SQLite later
- [ ] Retrieve memory as context for future prompts
- [ ] Improve prompt templates based on feedback
- [ ] Evaluation harness for recurring tests
- [ ] Explicitly do not retrain model weights in MVP

## Phase 9 — Future model self-learning / personal model path

- [ ] Plan fine-tuning experiments for small open models
- [ ] Plan dataset creation from accepted corrections and high-quality outputs
- [ ] Plan model evaluation before using any fine-tuned model
- [ ] Plan knowledge distillation / teacher-student experiments
- [ ] Plan learning from multiple models' outputs, respecting licenses/provenance
- [ ] Document future "personal model" path built on open models + curated data
- [ ] Document that training/fine-tuning needs better hardware than the NAS
- [ ] Document that the goal is optional future experimentation, not uncontrolled self-modification

## Notes

- NAS validation (containers actually starting on a Synology DS1525+, model pulls over real
  network, etc.) cannot be executed from this IDE environment. See the "Validation performed vs.
  deferred" section in `docs/local-ai-nas-manual.md` and the checklist in `docs/troubleshooting.md`
  for what to check manually on the NAS.
