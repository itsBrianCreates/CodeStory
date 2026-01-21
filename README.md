# CodeStory

Turn your Claude Code sessions into social media content. Perfect for "build in public" developers and designers.

## Quick Install

Run this in your project root:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/CodeStory/main/install.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/YOUR_USERNAME/CodeStory.git
cd your-project
bash path/to/CodeStory/install.sh
```

## How It Works

### 1. Automatic Session Tracking

As you work with Claude Code, it automatically tracks notable moments:

- Technical wins and clever solutions
- Progress milestones and features completed
- Debugging adventures and "aha" moments
- Architecture decisions and tradeoffs

These notes are saved to `.social-draft-{your-name}.md` as you work.

### 2. Generate Content with `/social`

When you're ready to post, just type:

```
/social
```

Claude will:
1. Review your session notes
2. Check recent git activity
3. Generate polished drafts for your configured platforms

### 3. Copy, Paste, Post

Your content appears in `socialmedia-{your-name}.md` with:

- **Raw Notes:** Bullet points of what happened
- **Polished Drafts:** Ready-to-post content for each platform

## Configuration

The installer creates `.social-config.md` in your project:

```markdown
# Social Media Config

## Platforms
- [x] LinkedIn
- [x] X/Twitter
- [ ] Threads
- [ ] Bluesky

## Tone
casual
<!-- Options: casual, professional, educational -->

## Length
medium
<!-- Options: short, medium, long -->

## Author
Your Name

## Voice Notes
<!-- Add examples of how you write, your vibe -->
<!-- I tend to be self-deprecating -->
<!-- I use "honestly" and "turns out" a lot -->
```

### Tone Options

| Tone | Description |
|------|-------------|
| `casual` | Like texting a friend about your work |
| `professional` | Polished but still personable |
| `educational` | Teaching focused, explains the why |

### Length Options

| Length | Description |
|--------|-------------|
| `short` | 1-2 sentences, punchy |
| `medium` | A small paragraph, tells a mini story |
| `long` | Multiple paragraphs, detailed narrative |

## Example Output

Here's what generated content looks like:

**X/Twitter:**
> spent 2 hours debugging an auth issue
>
> turns out the token was being URL encoded twice before hitting the API
>
> one line fix
>
> also refactored 400 lines of validation code down to 120 while I was in there. sometimes the best code you write is the code you delete

**LinkedIn:**
> Spent my afternoon hunting a bug that turned out to be hilariously simple.
>
> Users were randomly getting logged out. Checked the auth flow, the token storage, the session handling. Everything looked fine. Took me two hours to realize the token was being URL-encoded twice before hitting the API.
>
> One line fix. Two hours of detective work.
>
> While I was in there, I noticed our validation layer had gotten out of hand. 400 lines of spaghetti accumulated over months of "quick fixes." Took another hour to refactor it down to 120 lines.
>
> Sometimes the best code you write is the code you delete.

See more examples in [examples/socialmedia-example.md](examples/socialmedia-example.md).

## Writing Style

Content is generated with these rules:

**Never includes:**
- Hashtags (ever)
- Dashes or em-dashes
- Corporate speak ("excited to announce", "game-changer")
- AI-sounding phrases

**Always includes:**
- Conversational, human tone
- Specific numbers and details
- Mini-stories when possible

## FAQ

### Does it work with an existing AGENT.md?

Yes. The installer appends the social posts section to your existing file. Your original content is preserved.

### Where are draft files stored?

Session drafts go to `.social-draft-{username}.md` in your project root. These are automatically added to `.gitignore`.

### Can I use this on multiple projects?

Yes. Run the installer in each project. Your preferences are stored per-project in `.social-config.md`.

### What if I don't like the generated content?

Edit your `.social-config.md`:
- Adjust the tone or length settings
- Add Voice Notes with examples of how you write
- Claude will adapt to match your style

### Can I manually add to the draft file?

Absolutely. Open `.social-draft-{username}.md` and add notes anytime. Claude will include them in the next `/social` run.

## Files Created

| File | Purpose |
|------|---------|
| `.social-config.md` | Your preferences (platforms, tone, length) |
| `.social-draft-{name}.md` | Running notes during sessions (gitignored) |
| `socialmedia-{name}.md` | Generated content output |
| `AGENT.md` | Claude instructions (created or appended) |

## Contributing

Issues and PRs welcome. This project is intentionally simple.

## License

MIT
