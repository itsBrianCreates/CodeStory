<!-- SOCIAL-POSTS-START -->
## Social Media Content Generation

This section enables automatic tracking and generation of social media content from your coding sessions. Perfect for "build in public" developers.

### Live Session Tracking

When working on this project, maintain a running log of notable moments in `.social-draft-{GIT_USERNAME}.md`:

**What to capture:**
- Technical wins (clever solutions, performance improvements, clean refactors)
- Progress milestones (features completed, bugs squashed, tests passing)
- Lessons learned (debugging adventures, "aha" moments, things that surprised you)
- Interesting decisions (architecture choices, tradeoffs you made, why you picked one approach over another)
- Frustrations turned victories (that bug that took forever, the docs that were wrong)

**Log format:**
```
## Session: {DATE}

{TIME} - Brief note about what just happened
- Include relevant code snippets or commands when they add context
- Keep it casual and authentic
- Write like you're telling a friend about your day
```

**Example entry:**
```
## Session: 2024-01-15

2:34 PM - Finally figured out why the auth was failing. Turns out the token was being URL-encoded twice. Classic.

3:15 PM - Refactored the entire validation layer. Went from 400 lines to 120. Sometimes less really is more.

4:02 PM - Added rate limiting. Used a sliding window approach instead of fixed buckets. Feels cleaner.
```

### The /social Command

When the user types `/social`, generate social media content by following these steps:

**Step 1: Gather Context**
- Read the session draft file (`.social-draft-{username}.md`)
- Review recent git activity:
  - `git log --oneline -10` for recent commits
  - `git diff --stat HEAD~5` for a sense of what changed
- Read `.social-config.md` for platform and style preferences

**Step 2: Generate Output**
Create or update `socialmedia-{username}.md` with two sections:

**Raw Notes Section:**
```markdown
## Raw Notes

**What happened this session:**
- Bullet points summarizing the work
- Key moments worth sharing
- Interesting technical details

**Potential angles:**
- Hook 1: [angle that might resonate]
- Hook 2: [different perspective]
- Hook 3: [the human story]
```

**Polished Drafts Section:**
For each platform enabled in `.social-config.md`, create a ready-to-post draft:

```markdown
## Drafts

### LinkedIn
[Full draft here, matching configured tone and length]

### X/Twitter
[Full draft here, respecting character limits]
```

**Step 3: Clean Up**
- Clear the session draft file contents (keep the file, empty the content)
- The draft file is now ready for the next session

### Writing Style Rules

These rules apply to ALL generated content. No exceptions.

**Never do these:**
- Never use hashtags (not even one)
- Never use dashes or em-dashes in post text
- Never use bullet points or lists in the final post
- Never start with "I'm excited to announce" or similar corporate openers
- Never use phrases like "game-changer", "leveraging", "synergy", or "at the end of the day"
- Never sound like a press release

**Always do these:**
- Write conversationally, like texting a friend about your work
- Use short sentences. They hit harder.
- Tell a micro-story when possible (problem, struggle, solution)
- Be specific with numbers and details (not "improved performance" but "cut load time from 3s to 400ms")
- Match the user's configured tone (casual/professional/educational)
- Match the user's configured length (short/medium/long)
- If Voice Notes exist in config, try to match that personal style

**Length guidelines:**
- **Short:** 1-2 sentences. Punchy. A single observation or win.
- **Medium:** A small paragraph. Tells a mini-story with a beginning and end.
- **Long:** Multiple paragraphs. Detailed narrative with context and learnings.

**Tone guidelines:**
- **Casual:** Like texting a friend. Informal, maybe a bit funny, very human.
- **Professional:** Polished but still personable. Good for LinkedIn. Not stiff.
- **Educational:** Teaching focused. Explains the why. Shares the lesson.

### Platform-Specific Notes

**X/Twitter:**
- Keep under 280 characters for single tweets
- Can suggest thread format for longer content
- Casual tone works best here

**LinkedIn:**
- Medium to long format performs well
- Can be more detailed and professional
- First line is crucial (it's the hook before "see more")

**Threads:**
- Similar to Twitter but can go longer
- Conversational tone
- Good for storytelling

**Bluesky:**
- 300 character limit
- Similar vibe to early Twitter
- Tech audience appreciates specifics

### Configuration File

The user's preferences are stored in `.social-config.md` in the project root. Always read this file before generating content to respect their platform choices, tone, and length preferences.
<!-- SOCIAL-POSTS-END -->
