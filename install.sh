#!/bin/bash

# claude-social-posts installer
# Adds social media content generation to your Claude Code sessions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     claude-social-posts installer      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository.${NC}"
    echo "Please run this from the root of your git project."
    exit 1
fi

# Get git username
GIT_USERNAME=$(git config user.name 2>/dev/null || echo "")
if [ -z "$GIT_USERNAME" ]; then
    echo -e "${YELLOW}Could not detect git username.${NC}"
    read -p "Enter your name: " GIT_USERNAME
fi

echo -e "Hello, ${GREEN}$GIT_USERNAME${NC}!"
echo ""

# Platform selection
echo -e "${BLUE}Which platforms do you post to?${NC}"
echo "(Enter numbers separated by spaces, e.g., '1 2' for LinkedIn and X/Twitter)"
echo ""
echo "  1) LinkedIn"
echo "  2) X/Twitter"
echo "  3) Threads"
echo "  4) Bluesky"
echo ""
read -p "Your choices: " PLATFORM_CHOICES

LINKEDIN="[ ]"
TWITTER="[ ]"
THREADS="[ ]"
BLUESKY="[ ]"

for choice in $PLATFORM_CHOICES; do
    case $choice in
        1) LINKEDIN="[x]" ;;
        2) TWITTER="[x]" ;;
        3) THREADS="[x]" ;;
        4) BLUESKY="[x]" ;;
    esac
done

echo ""

# Tone selection
echo -e "${BLUE}What tone fits your style?${NC}"
echo ""
echo "  1) casual      - like texting a friend about your work"
echo "  2) professional - polished but still personable"
echo "  3) educational  - teaching focused, explaining the why"
echo ""
read -p "Your choice [1]: " TONE_CHOICE

case $TONE_CHOICE in
    2) TONE="professional" ;;
    3) TONE="educational" ;;
    *) TONE="casual" ;;
esac

echo ""

# Length selection
echo -e "${BLUE}How long are your typical posts?${NC}"
echo ""
echo "  1) short  - 1-2 sentences, punchy"
echo "  2) medium - a small paragraph, tells a mini story"
echo "  3) long   - multiple paragraphs, detailed narrative"
echo ""
read -p "Your choice [2]: " LENGTH_CHOICE

case $LENGTH_CHOICE in
    1) LENGTH="short" ;;
    3) LENGTH="long" ;;
    *) LENGTH="medium" ;;
esac

echo ""
echo -e "${BLUE}Setting up your project...${NC}"
echo ""

# Create .social-config.md
cat > .social-config.md << EOF
# Social Media Config

## Platforms
- $LINKEDIN LinkedIn
- $TWITTER X/Twitter
- $THREADS Threads
- $BLUESKY Bluesky

## Tone
$TONE
<!-- Options: casual, professional, educational -->
<!-- casual = like texting a friend about your work -->
<!-- professional = polished but still personable -->
<!-- educational = teaching focused, explaining the why -->

## Length
$LENGTH
<!-- Options: short, medium, long -->
<!-- short = 1-2 sentences, punchy -->
<!-- medium = a small paragraph, tells a mini story -->
<!-- long = multiple paragraphs, detailed narrative -->

## Author
$GIT_USERNAME

## Voice Notes
<!-- Add examples of how you write, phrases you use, your vibe -->
<!-- Claude will try to match your personal style -->
EOF

echo -e "  ${GREEN}✓${NC} Created .social-config.md"

# AGENT-social.md content
AGENT_CONTENT='<!-- SOCIAL-POSTS-START -->
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
- Write like you are telling a friend about your day
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
- Never start with "I am excited to announce" or similar corporate openers
- Never use phrases like "game-changer", "leveraging", "synergy", or "at the end of the day"
- Never sound like a press release

**Always do these:**
- Write conversationally, like texting a friend about your work
- Use short sentences. They hit harder.
- Tell a micro-story when possible (problem, struggle, solution)
- Be specific with numbers and details (not "improved performance" but "cut load time from 3s to 400ms")
- Match the user configured tone (casual/professional/educational)
- Match the user configured length (short/medium/long)
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
- First line is crucial (it is the hook before "see more")

**Threads:**
- Similar to Twitter but can go longer
- Conversational tone
- Good for storytelling

**Bluesky:**
- 300 character limit
- Similar vibe to early Twitter
- Tech audience appreciates specifics

### Configuration File

The user preferences are stored in `.social-config.md` in the project root. Always read this file before generating content to respect their platform choices, tone, and length preferences.
<!-- SOCIAL-POSTS-END -->'

# Handle AGENT.md
if [ -f "AGENT.md" ]; then
    # Check if social posts section already exists
    if grep -q "SOCIAL-POSTS-START" AGENT.md; then
        echo -e "  ${YELLOW}!${NC} AGENT.md already has social posts section (skipped)"
    else
        # Append to existing AGENT.md
        echo "" >> AGENT.md
        echo "$AGENT_CONTENT" >> AGENT.md
        echo -e "  ${GREEN}✓${NC} Appended social posts section to AGENT.md"
    fi
else
    # Create new AGENT.md
    echo "$AGENT_CONTENT" > AGENT.md
    echo -e "  ${GREEN}✓${NC} Created AGENT.md with social posts section"
fi

# Update .gitignore
if [ -f ".gitignore" ]; then
    if grep -q "\.social-draft-" .gitignore; then
        echo -e "  ${YELLOW}!${NC} .gitignore already has draft pattern (skipped)"
    else
        echo "" >> .gitignore
        echo "# Social media drafts (claude-social-posts)" >> .gitignore
        echo ".social-draft-*.md" >> .gitignore
        echo -e "  ${GREEN}✓${NC} Added draft pattern to .gitignore"
    fi
else
    echo "# Social media drafts (claude-social-posts)" > .gitignore
    echo ".social-draft-*.md" >> .gitignore
    echo -e "  ${GREEN}✓${NC} Created .gitignore with draft pattern"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           Setup complete!              ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}How it works:${NC}"
echo ""
echo "  1. Claude will track notable moments as you code"
echo "     (saved to .social-draft-$GIT_USERNAME.md)"
echo ""
echo "  2. When you're ready to post, just type:"
echo -e "     ${GREEN}/social${NC}"
echo ""
echo "  3. Claude will generate polished drafts in:"
echo "     socialmedia-$GIT_USERNAME.md"
echo ""
echo -e "${BLUE}Customize your style:${NC}"
echo "  Edit .social-config.md to adjust platforms, tone, and length"
echo "  Add Voice Notes to help Claude match your personal style"
echo ""
echo -e "${YELLOW}Tip:${NC} Start a Claude Code session and make some changes."
echo "     Then run /social to see the magic happen!"
echo ""
