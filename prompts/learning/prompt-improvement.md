# Prompt improvement (future — not implemented)

This prompt template is a placeholder for the future prompt-optimizer feature described in
[`docs/learning-and-self-improvement.md`](../../docs/learning-and-self-improvement.md)
(`ENABLE_PROMPT_OPTIMIZER`). Nothing in this repo currently analyses feedback automatically — this
file exists so the eventual implementation has a starting template, and so you can run the same
idea manually today.

## Intended shape (future / usable manually now)

```
Here is a prompt template I've been using, plus some examples of where it worked well and where it
didn't:

Template:
<paste the prompt template>

Good outputs (what made them good):
<examples>

Bad outputs (what went wrong):
<examples>

Suggest a revised version of the template that keeps what worked and fixes what didn't. Explain
the changes briefly.
```

Once implemented, this would run automatically against accumulated feedback in
`${LOCAL_AI_BASE_PATH}/memory/feedback/` rather than requiring you to paste examples by hand.
