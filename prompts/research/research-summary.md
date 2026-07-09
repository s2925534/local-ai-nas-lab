# Research summary

## Prompt

```
Summarise the following source(s) for my own research notes.

Source(s):
<paste text, or upload the document via Open WebUI's document feature and reference it>

Produce:
1. One-paragraph summary
2. Key claims/findings (bulleted)
3. Methodology notes, if applicable
4. Anything that seems weak, unsupported, or worth double-checking
5. How this relates to: <your research question/topic, if any>

Be precise about what the source actually says versus what you're inferring.
```

## Notes

- Better fit for `qwen2.5:7b` than the small model — summarisation quality matters more here.
- For document-grounded Q&A (as opposed to a pasted excerpt), use Open WebUI's built-in document
  upload/RAG feature so answers stay grounded in the uploaded file. A more formal RAG pipeline is
  a documented future flag (`ENABLE_RAG_PIPELINE`), not required for this to work today.
