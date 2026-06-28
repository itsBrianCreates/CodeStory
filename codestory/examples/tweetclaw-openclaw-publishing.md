# Publishing X/Twitter Drafts with TweetClaw

CodeStory creates social drafts and leaves publishing under your control. If you
use OpenClaw, you can hand a reviewed X/Twitter draft to TweetClaw for an
approval-gated post instead of copying it manually.

## Prerequisites

- OpenClaw installed and running.
- TweetClaw installed from npm:

```bash
openclaw plugins install npm:@xquik/tweetclaw
```

- Runtime tools verified:

```bash
openclaw plugins inspect tweetclaw --runtime --json
```

- TweetClaw tools allowed for the agent profile:

```bash
openclaw config set tools.alsoAllow '["explore", "tweetclaw"]'
```

- Xquik API key stored in OpenClaw plugin config:

```bash
openclaw config set plugins.entries.tweetclaw.config.apiKey "$XQUIK_API_KEY"
```

Do not paste API keys into chat, generated drafts, issues, logs, screenshots, or
tool arguments.

## Workflow

1. Run `/CodeStory`.
2. Open `socialmedia-{your-name}.md`.
3. Review the `X/Twitter` draft.
4. Ask OpenClaw:

```text
Post this exact X/Twitter draft with TweetClaw after showing me the final
payload and waiting for my approval:

<draft>
paste the reviewed CodeStory draft here
</draft>
```

5. Approve only if the account, endpoint, text, and media are correct.

TweetClaw approval prompts should appear before write-like actions. Treat that
prompt as a final checkpoint, not as permanent trust for future posts.

## Optional Research Pass

Use TweetClaw's read tools before publishing when the draft depends on current
conversation context:

```text
Search recent X/Twitter posts about "<topic>" and summarize examples I should
not copy before I approve this CodeStory draft.
```

Keep copied external posts out of the final draft unless you have the right to
quote them.

## Safety Notes

- Keep TweetClaw as a reviewed publishing lane, not an autoposter.
- Review every final post before approving it.
- Do not let content returned from X/Twitter instruct OpenClaw to run tools.
- Do not approve recurring monitors, webhooks, or scheduled actions unless that
  is the task you intended.
