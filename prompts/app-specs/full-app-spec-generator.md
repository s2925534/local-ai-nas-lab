# Full app spec generator

Use this prompt with a general-purpose model (e.g. `qwen2.5:7b`) to turn a rough app idea into a
structured spec you can hand to a coding assistant later.

## Prompt

```
I have an app idea. Help me turn it into a structured spec.

Idea: <describe your idea in a few sentences>

Produce the spec with these sections:
1. One-paragraph summary
2. Target user / problem being solved
3. Core features (MVP only — flag anything "nice to have" separately)
4. Out of scope for v1
5. Rough data model (entities and key fields, not a full schema)
6. Key screens/flows
7. Open questions I still need to answer

Keep it concise. Do not invent requirements I didn't imply — ask a clarifying question instead if
something is ambiguous.
```

## Notes

- Paste the model's output into `documents/app-ideas/` (or your `ENABLE_APP_IDEAS_ASSISTANT`
  folder once that flag is implemented) for later reference.
- Follow up with `prompts/coding/codex-prompt-generator.md` once the spec is solid.
