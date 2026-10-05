# Future hardware expansion (plan only)

Status: **documented concept for Phase 6, not implemented in the MVP.** `ENABLE_GPU_REMOTE_BACKEND`,
`ENABLE_LARGE_MODELS`, and `ENABLE_MULTI_MODEL_ROUTER` are planning placeholders only — none appear
in `.env.example` yet (see [`future-flags.md`](future-flags.md)). This document exists so the
architecture has a clear shape to grow into once better hardware is available, without re-deriving
it.

## Why this exists

A Synology DS1525+ (or similar NAS-class hardware) is CPU-only and RAM-constrained. It comfortably
runs the MVP model set (`llama3.2:3b`, `qwen2.5:7b`, `qwen2.5-coder:7b`, `nomic-embed-text`) but not
larger models. This document plans how the architecture extends when a user adds a GPU workstation,
without requiring one for the MVP and without changing anything about how the NAS itself is used
today.

## NAS as storage/UI/orchestration layer

The core idea: the NAS keeps its current job — Open WebUI, persistent storage
(`LOCAL_AI_BASE_PATH`), prompt library, backups — and stops being the thing that necessarily runs
inference. Inference can move to a separate, more capable machine while everything else stays where
it is.

```
                 ┌─────────────────────────────┐
                 │   Browser (you, on LAN)      │
                 └───────────────┬──────────────┘
                                 │ http://<nas-ip>:3000  (unchanged)
                                 ▼
                 ┌─────────────────────────────┐
                 │  Open WebUI (on the NAS)      │
                 │  storage, UI, orchestration   │
                 └───────────────┬──────────────┘
                                 │ OLLAMA_BASE_URL points at a
                                 │ remote host instead of the local
                                 │ `ollama` container
                                 ▼
                 ┌─────────────────────────────┐
                 │  Ollama (on a GPU workstation) │
                 │  private network only          │
                 └─────────────────────────────┘
```

The NAS never needs a GPU itself under this model. It stays the stable, always-on storage/UI layer;
the GPU machine can be turned on only when needed for heavier inference.

## GPU backend option (`ENABLE_GPU_REMOTE_BACKEND`)

- A GPU-equipped machine (workstation, gaming PC, dedicated server) runs its own Ollama instance.
- Open WebUI on the NAS points `OLLAMA_BASE_URL` at that machine's private address instead of the
  local `ollama` Docker service name.
- The GPU machine's Ollama port must be reachable from the NAS but still **never** exposed publicly
  or bound to `0.0.0.0` on an untrusted network — same rule as the local case in
  [`security.md`](security.md), just applied to a different host. Prefer a private LAN segment or
  Tailscale between the NAS and the GPU machine over opening a port on either.
- Model pulls (`scripts/pull-models.sh`) would need to target the GPU machine's Ollama instance for
  any model meant to run there, not the NAS's local one.

## Remote Ollama backend option

More generally than "a GPU workstation specifically": Ollama does not have to run on the same host
as Open WebUI at all. Any machine capable of running Ollama — a GPU workstation, a beefier home
server, eventually a cloud GPU instance if ever desired — can be the inference backend, as long as:

- It's reachable only over a trusted private network (LAN, VPN, or Tailscale) from the NAS.
- Its Ollama port is never exposed to the public internet, for the same reasons as the local case.
- `LOCAL_AI_BASE_PATH` and Open WebUI's own data stay on the NAS regardless of where inference runs
  — this keeps chat history, documents, and backups in one predictable place even if the inference
  backend changes over time.

This is a configuration change (`OLLAMA_BASE_URL`, network reachability), not an architecture
rewrite — `docker-compose.yml`'s Open WebUI service is already the only thing that needs to know
where Ollama lives.

## Large model notes (14B / 32B / 70B+)

- Not part of the MVP model set and not recommended on NAS-class CPU-only hardware — see the
  README's "What this project does NOT do" section and
  [`troubleshooting.md`](troubleshooting.md#model-too-large-for-available-ram).
- Rough sizing intuition (quantized GGUF-style weights, actual requirements vary by quantization):
  - **7B and under** — the current MVP tier. Runs adequately on CPU-only NAS hardware.
  - **13B–14B** — noticeably slower on CPU; usable with patience, generally still not recommended
    without more RAM than typical NAS defaults.
  - **32B** — needs either substantially more RAM (CPU-only) or a GPU with enough VRAM to hold the
    model; not realistic on NAS-class hardware.
  - **70B+** — realistically requires a GPU (or multi-GPU) backend with enough VRAM, or heavy
    quantization plus a lot of system RAM. Treat as a GPU-backend-only tier.
- `ENABLE_LARGE_MODELS` is the flag reserved for opting into this tier once a GPU backend
  (`ENABLE_GPU_REMOTE_BACKEND`) is actually in place — the two are meant to be adopted together, not
  independently.
- Larger models change which tasks make sense to route where — see multi-model routing below.

## Multi-model routing (`ENABLE_MULTI_MODEL_ROUTER`, related idea)

Once more than one backend or model tier exists, a router could pick a model automatically by task
type — small model for quick rewrites, coding model for code, a larger remote model for research or
harder reasoning, the embedding model for document Q&A — rather than the user manually choosing
every time. This is a natural companion to hardware expansion but is its own, separate future flag;
it is not required to use a GPU backend or large models manually.

## What this document is not

It is not a spec for an implementation that exists today. No remote-backend configuration, GPU
support, large-model defaults, or routing logic ships in this repository yet. See
[`phase-plan.md`](phase-plan.md) Phase 6 for how this fits the overall roadmap.
