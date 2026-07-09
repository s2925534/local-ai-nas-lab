# MVP feature prioritizer

Use this once you already have a rough feature list (e.g. from
[`full-app-spec-generator.md`](full-app-spec-generator.md)) and need help deciding what's actually
MVP versus what can wait.

## Prompt

```
Here is a list of features I'm considering for an app's first version:

<paste feature list>

Context: <one or two sentences on the target user / problem>

For each feature, classify it as:
- MUST (the app doesn't work without it)
- SHOULD (valuable, but the app is usable without it for v1)
- LATER (defer — nice to have, not core)

Then give me a one-paragraph recommendation for what the true MVP scope should be, and flag
anything that looks like scope creep.
```

## Notes

- Good fit for `qwen2.5:7b` — this benefits from more careful reasoning than the small model
  reliably gives.
- Feed the output back into a spec via `full-app-spec-generator.md` if the scope changed
  significantly.
