# Document upload and Q&A (RAG) usage notes

Status: **usable today via Open WebUI's built-in features. No custom RAG pipeline is implemented
in this repo.** This document explains what works out of the box and what a future, more formal
pipeline (`ENABLE_RAG_PIPELINE`, see [`future-flags.md`](future-flags.md)) would add on top.

## What works today (no extra setup)

Open WebUI ships its own document upload and retrieval-augmented generation (RAG) feature:

1. In a chat, use the document/paperclip upload control (or `#` to reference a previously uploaded
   file, depending on your Open WebUI version) to attach a file.
2. Ask questions about it directly in the chat. Open WebUI chunks and embeds the document itself
   and retrieves relevant passages as context for the model — you don't need to configure anything
   in this repo for this to work.
3. `MODEL_EMBEDDING` (default `nomic-embed-text`, see `.env.example`) is pulled by
   `scripts/pull-models.sh` specifically so an embedding model is available if you configure Open
   WebUI to use it for document retrieval instead of its own default. Check Open WebUI's own admin
   settings (Documents / RAG section) to confirm which embedding model it's actually using.

## Where uploaded documents live

- Files you upload through Open WebUI's UI are stored inside Open WebUI's own data directory,
  which is bind-mounted from `${LOCAL_AI_BASE_PATH}/open-webui`.
- The separate `${LOCAL_AI_BASE_PATH}/documents/` tree (with `app-ideas/`, `research/`,
  `nas-admin/`, `coding/`, `quantainer/` subfolders) is **not** automatically ingested by Open
  WebUI — it's a plain filesystem location for your own reference copies, backups, or for a future
  ingestion pipeline to read from. Today, if you want a document searchable in chat, upload it
  through Open WebUI directly.

## Practical tips

- Smaller, more focused documents retrieve better than one huge file — split large references if
  answers seem to miss relevant sections.
- Open WebUI's default chunking/retrieval settings are a reasonable starting point; only tune them
  in its admin settings if you notice retrieval quality problems.
- Treat uploaded documents as private data — see [`security.md`](security.md). Don't upload
  sensitive material until you've confirmed your exposure settings (LAN-only vs. any wider access).

## What a future formal RAG pipeline would add

`ENABLE_RAG_PIPELINE` (see [`future-flags.md`](future-flags.md)) is a placeholder for a more
deliberate ingestion pipeline — for example, automatically indexing everything under
`${LOCAL_AI_BASE_PATH}/documents/` into a vector store, with more control over chunking strategy,
re-indexing on file changes, and cross-document search. Not implemented; Open WebUI's built-in
feature is sufficient for the MVP's document Q&A use case.
