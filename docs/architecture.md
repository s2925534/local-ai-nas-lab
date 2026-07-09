# Architecture

This document describes the MVP architecture plus four future architectures. Only the MVP
architecture is implemented; the rest are documented intent, gated behind the flags in
[`future-flags.md`](future-flags.md).

## 1. MVP architecture (implemented)

```
                         ┌─────────────────────────────┐
                         │   Browser (LAN client)        │
                         └───────────────┬──────────────┘
                                         │ http://<host>:${OPEN_WEBUI_PORT}
                                         ▼
                         ┌─────────────────────────────┐
                         │  open-webui container         │
                         │  (ghcr.io/open-webui/open-webui)│
                         │  bind: ${OPEN_WEBUI_BIND_HOST} │
                         └───────────────┬──────────────┘
                                         │ Docker network "local_ai_net"
                                         │ http://ollama:11434
                                         ▼
                         ┌─────────────────────────────┐
                         │  ollama container              │
                         │  (ollama/ollama)               │
                         │  bind: 127.0.0.1 (host-only)   │
                         └───────────────┬──────────────┘
                                         │ bind mounts
                                         ▼
        ${LOCAL_AI_BASE_PATH}/ollama, /open-webui, /documents, /prompts,
        /exports, /backups, /logs, /memory (folders created, not yet used)
```

Key properties:

- Two containers, one Docker network (`local_ai_net`), no external services required.
- Open WebUI talks to Ollama only over the internal Docker network — the host-mapped Ollama port
  exists for local debugging/CLI use, not for Open WebUI's traffic.
- All state is bind-mounted from `LOCAL_AI_BASE_PATH`. Deleting the containers and re-running
  `docker compose up -d` does not lose data.
- No reverse proxy, no TLS, no public exposure. LAN-only by default.

## 2. Deployer-managed public exposure architecture (future, documented only)

```
Internet
   │
   ▼
Cloudflare (DNS + Tunnel/Access) ── managed entirely by your deployer (e.g. ../synology-site-deployer)
   │
   ▼
deployer's reverse proxy / tunnel connector on the NAS
   │  routes only https://${LOCAL_AI_DOMAIN} -> open-webui:${OPEN_WEBUI_PORT}
   ▼
open-webui container (same as MVP)
   │
   ▼
ollama container — never reachable from the tunnel, LAN/host-only
```

This repo's only responsibility toward this architecture is to expose a predictable service name
and port for the deployer to point at, and to document that Ollama must never be included in any
public route. See [`deployer-integration.md`](deployer-integration.md) and
[`reverse-proxy-domain.md`](reverse-proxy-domain.md).

## 3. Portable local future architecture (future, documented only)

```
Any computer (Mac/Linux/Windows)
   │
   ▼
scripts/start.sh or scripts/start.ps1
   │
   ▼
Docker Compose (same compose file) with:
   LOCAL_AI_BASE_PATH=${PORTABLE_DATA_PATH}   (inside the project folder)
   OPEN_WEBUI_BIND_HOST=127.0.0.1
   OLLAMA_BIND_HOST=127.0.0.1
   │
   ▼
Browser opened automatically at http://localhost:${OPEN_WEBUI_PORT}
```

No NAS, no domain, no deployer involvement. Entirely localhost-bound by default. See
[`portable-local-mode.md`](portable-local-mode.md).

## 4. Feedback learning future architecture (future, documented only)

```
User interaction in Open WebUI
   │
   ▼
Feedback capture (rating, correction, accept/reject) — future flag ENABLE_FEEDBACK_LEARNING_LOOP
   │
   ▼
${LOCAL_AI_BASE_PATH}/memory/feedback/*.jsonl   (append-only log)
${LOCAL_AI_BASE_PATH}/memory/rules/*.md          (durable project rules, human-edited or promoted)
   │
   ▼
Retrieval layer (future ENABLE_RAG_PIPELINE) surfaces relevant memory/rules as
context for future prompts
   │
   ▼
Prompt templates in prompts/ improved over time (future ENABLE_PROMPT_OPTIMIZER)
   │
   ▼
Evaluation harness (future ENABLE_EVALUATION_HARNESS) checks that changes don't regress
```

No model weights change in this architecture. See
[`learning-and-self-improvement.md`](learning-and-self-improvement.md).

## 5. Personal model / fine-tuning future architecture (far future, documented only)

```
${LOCAL_AI_BASE_PATH}/memory/feedback + /memory/datasets (curated, evaluated)
   │
   ▼
Dataset curation (future ENABLE_DATASET_CURATOR): review, clean, tag, export
   │
   ▼
Fine-tuning / distillation experiments on a small open model
   (future ENABLE_FINE_TUNING_EXPERIMENTS / ENABLE_MODEL_DISTILLATION_EXPERIMENTS)
   — requires hardware beyond the NAS, e.g. a GPU workstation (see Phase 6)
   │
   ▼
Evaluation against the harness before any fine-tuned model is trusted
   (future ENABLE_PERSONAL_MODEL_PATH)
```

This is explicitly far-future, opt-in, and not part of the MVP. See the "Far-future personal model
path" section of [`learning-and-self-improvement.md`](learning-and-self-improvement.md).
