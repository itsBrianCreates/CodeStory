---
name: CodeStory
description: Generate social media content from your coding session
---

# CodeStory: Social Media Content Generator

Generate polished social media drafts from your coding session. Perfect for "build in public" developers.

## When This Skill Runs

This skill is triggered when:
- User types `/CodeStory`
- User says "CodeStory" in conversation (e.g., "run CodeStory", "let's do CodeStory")

## Step 1: Gather Context

Read these files and run these commands to understand what happened:

**Session Notes:**
- Read `.social-draft-{username}.md` for manual notes captured during the session
- If the file doesn't exist or is empty, that's fine - rely on git history instead

**Git Activity:**
```bash
git log --oneline -10
git diff --stat HEAD~5
```

**User Preferences:**
- Read `.social-config.md` for platform choices, tone, and length settings
- If no config exists, assume: all platforms, casual tone, medium length

## Step 2: Generate Output

Create or update `socialmedia-{username}.md`. **New sessions are prepended to the top** so the most recent content appears first. All session history is preserved.

### File Header

If the file is new or empty, start with:

```markdown
# Social Media Content
```

### Session Block Structure

Each session gets a block with this structure (prepended to the top, after the main header):

```markdown
---

## Session: {DATE} at {TIME}

Generated: {DATE} at {TIME in 12-hour format, e.g., "3:45 PM"}

### Raw Notes

**What happened this session:**
- [Bullet points summarizing the work]
- [Key moments worth sharing]
- [Interesting technical details]

**Potential angles:**
- Hook 1: [angle that might resonate]
- Hook 2: [different perspective]
- Hook 3: [the human story]

### Drafts

#### LinkedIn
[Full draft matching configured tone and length]

---
Co-created with CodeStory
https://github.com/itsBrianCreates/CodeStory

#### X/Twitter
[Full draft respecting 280 character limit]

---
Co-created with CodeStory
https://github.com/itsBrianCreates/CodeStory

#### Threads
[Full draft, conversational tone]

---
Co-created with CodeStory
https://github.com/itsBrianCreates/CodeStory

#### Bluesky
[Full draft respecting 300 character limit]

---
Co-created with CodeStory
https://github.com/itsBrianCreates/CodeStory

---

*Copy these drafts and paste directly to your platforms.*
```

### Important: Prepend New Sessions

When running CodeStory on an existing file:
1. Read the existing file content
2. Insert the new session block immediately after the `# Social Media Content` header
3. Keep all previous session blocks below (history is preserved indefinitely)

Only generate drafts for platforms enabled in `.social-config.md`.

## Step 3: Clean Up

After generating content:
- Clear the contents of `.social-draft-{username}.md` (keep the file, empty the content)
- The draft file is now ready for the next session

## Writing Style Rules

**NEVER do these:**
- Never use hashtags (not even one)
- Never use dashes or em-dashes in post text
- Never use bullet points or lists in the final post
- Never start with "I'm excited to announce" or similar corporate openers
- Never use phrases like "game-changer", "leveraging", "synergy", or "at the end of the day"
- Never sound like a press release

**ALWAYS do these:**
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

## Platform-Specific Notes

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

## Attribution

Every draft MUST end with this footer:

```
---
Co-created with CodeStory
https://github.com/itsBrianCreates/CodeStory
```

This attribution helps spread the word about CodeStory while giving credit to the tool.
