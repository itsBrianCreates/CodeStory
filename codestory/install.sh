#!/bin/bash

# CodeStory installer
# Adds social media content generation to your Claude Code sessions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Version and repository
CODESTORY_VERSION="1.1.2"
CODESTORY_REPO="https://raw.githubusercontent.com/itsBrianCreates/CodeStory/main"

# ============================================================================
# Update Functions
# ============================================================================

# Compare two semver version strings
# Returns: 0 if v1 == v2, 1 if v1 > v2, 2 if v1 < v2
version_compare() {
    local v1="$1"
    local v2="$2"

    if [ "$v1" = "$v2" ]; then
        return 0
    fi

    local IFS='.'
    local i v1_parts=($v1) v2_parts=($v2)

    # Fill empty positions with zeros
    for ((i=${#v1_parts[@]}; i<${#v2_parts[@]}; i++)); do
        v1_parts[i]=0
    done
    for ((i=${#v2_parts[@]}; i<${#v1_parts[@]}; i++)); do
        v2_parts[i]=0
    done

    for ((i=0; i<${#v1_parts[@]}; i++)); do
        if ((10#${v1_parts[i]} > 10#${v2_parts[i]})); then
            return 1
        fi
        if ((10#${v1_parts[i]} < 10#${v2_parts[i]})); then
            return 2
        fi
    done

    return 0
}

# Check for available updates
# Returns: 0 if update available, 1 if up to date, 2 if fresh install needed, 3 if offline
check_for_updates() {
    # Check if .codestory-version exists (indicates existing installation)
    if [ ! -f ".codestory-version" ]; then
        return 2  # Fresh install
    fi

    # Read local version (handles both "1.0.0" and "version=1.0.0" formats)
    local local_version
    local_version=$(head -n 1 .codestory-version 2>/dev/null | sed 's/^version=//' | tr -d '[:space:]')

    if [ -z "$local_version" ]; then
        return 2  # Fresh install (corrupted version file)
    fi

    # Fetch remote version with timeout
    local remote_version
    remote_version=$(curl -fsSL --connect-timeout 5 --max-time 10 \
        "${CODESTORY_REPO}/codestory/VERSION" 2>/dev/null | tr -d '[:space:]')

    if [ -z "$remote_version" ]; then
        return 3  # Offline or fetch failed
    fi

    # Compare versions (capture return code without triggering set -e)
    local result
    version_compare "$local_version" "$remote_version" && result=0 || result=$?

    if [ $result -eq 2 ]; then
        # Local is older than remote
        REMOTE_VERSION="$remote_version"
        LOCAL_VERSION="$local_version"
        return 0  # Update available
    fi

    LOCAL_VERSION="$local_version"
    return 1  # Up to date (or local is newer)
}

# Create backup of current files
create_backup() {
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_dir=".codestory-backup-${timestamp}"

    mkdir -p "$backup_dir"

    # Backup files if they exist
    [ -f ".social-config.md" ] && cp ".social-config.md" "$backup_dir/"
    [ -f "CLAUDE.md" ] && cp "CLAUDE.md" "$backup_dir/"
    [ -f ".gitignore" ] && cp ".gitignore" "$backup_dir/"
    [ -f ".codestory-version" ] && cp ".codestory-version" "$backup_dir/"
    [ -d ".claude/skills/CodeStory" ] && cp -r ".claude/skills/CodeStory" "$backup_dir/"

    echo "$backup_dir"
}

# Update the CodeStory section in CLAUDE.md (between markers)
update_claude_section() {
    local username="$1"
    local claude_content="$2"

    if [ ! -f "CLAUDE.md" ]; then
        echo "$claude_content" > CLAUDE.md
        return 0
    fi

    # Check if markers exist
    if grep -q "CODESTORY-START" CLAUDE.md && grep -q "CODESTORY-END" CLAUDE.md; then
        # Create temp file with updated content
        local temp_file
        temp_file=$(mktemp)

        # Use awk to replace content between markers
        awk -v new_content="$claude_content" '
            /<!-- CODESTORY-START -->/ {
                printing = 0
                print new_content
                next
            }
            /<!-- CODESTORY-END -->/ {
                printing = 1
                next
            }
            printing != 0 { print }
            BEGIN { printing = 1 }
        ' CLAUDE.md > "$temp_file"

        mv "$temp_file" CLAUDE.md
        return 0
    else
        # No markers found, append the content
        echo "" >> CLAUDE.md
        echo "$claude_content" >> CLAUDE.md
        return 0
    fi
}

# Update the SKILL.md file
update_skill_file() {
    local skill_content="$1"

    mkdir -p .claude/skills/CodeStory
    echo "$skill_content" > .claude/skills/CodeStory/SKILL.md
}

# Update .gitignore with new patterns
update_gitignore_section() {
    local patterns=("$@")

    if [ ! -f ".gitignore" ]; then
        echo "# Social media drafts (CodeStory)" > .gitignore
        for pattern in "${patterns[@]}"; do
            echo "$pattern" >> .gitignore
        done
        return 0
    fi

    # Add patterns that don't already exist
    for pattern in "${patterns[@]}"; do
        if ! grep -qF "$pattern" .gitignore; then
            echo "$pattern" >> .gitignore
        fi
    done
}

# Write version file with metadata
write_version_file() {
    local version="$1"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    cat > .codestory-version << EOF
$version
installed: $timestamp
repo: $CODESTORY_REPO
EOF
}

# Perform the smart update
perform_update() {
    local username="$1"

    echo -e "${BLUE}Creating backup...${NC}"
    local backup_dir
    backup_dir=$(create_backup)
    echo -e "  ${GREEN}✓${NC} Backup created at $backup_dir"

    echo ""
    echo -e "${BLUE}Updating CodeStory...${NC}"

    # Fetch and update SKILL.md
    local remote_skill
    remote_skill=$(curl -fsSL --connect-timeout 5 --max-time 10 \
        "${CODESTORY_REPO}/codestory/.claude/skills/CodeStory/SKILL.md" 2>/dev/null)

    if [ -n "$remote_skill" ]; then
        update_skill_file "$remote_skill"
        echo -e "  ${GREEN}✓${NC} Updated .claude/skills/CodeStory/SKILL.md"
    else
        echo -e "  ${YELLOW}!${NC} Could not fetch SKILL.md (using local version)"
    fi

    # Update CLAUDE.md section
    # Generate the CLAUDE.md content with username
    local claude_content
    claude_content='<!-- CODESTORY-START -->
## CodeStory: Auto-Tracking & Trigger

### Live Session Tracking

While working on this project, automatically log notable moments to `.social-draft-'"$username"'.md`:

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

### Trigger Word

When the user says "CodeStory" in conversation (e.g., "run CodeStory", "let'"'"'s do CodeStory", "time for CodeStory"), run the `/CodeStory` skill to generate social media content.
<!-- CODESTORY-END -->'

    update_claude_section "$username" "$claude_content"
    echo -e "  ${GREEN}✓${NC} Updated CodeStory section in CLAUDE.md"

    # Update .gitignore with new patterns
    update_gitignore_section ".social-draft-*.md" ".codestory-backup-*/" ".codestory-version"
    echo -e "  ${GREEN}✓${NC} Updated .gitignore patterns"

    # Write new version file
    write_version_file "$CODESTORY_VERSION"
    echo -e "  ${GREEN}✓${NC} Updated version to $CODESTORY_VERSION"

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         Update complete!               ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "Updated from ${YELLOW}$LOCAL_VERSION${NC} to ${GREEN}$CODESTORY_VERSION${NC}"
    echo ""
    echo -e "Your ${BLUE}.social-config.md${NC} has been preserved."
    echo -e "Backup saved to: ${BLUE}$backup_dir${NC}"
    echo ""
}

# ============================================================================
# Main Flow
# ============================================================================

echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         CodeStory installer            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository.${NC}"
    echo "Please run this from the root of your git project."
    exit 1
fi

# Check for updates
check_for_updates
update_status=$?

case $update_status in
    0)
        # Update available
        echo -e "${YELLOW}Update available!${NC} ($LOCAL_VERSION → $REMOTE_VERSION)"
        echo ""
        echo "What would you like to do?"
        echo ""
        echo "  1) Update (recommended) - Updates tool files, keeps your config"
        echo "  2) Skip - Continue with current version"
        echo "  3) Fresh install - Reconfigure everything from scratch"
        echo ""
        read -p "Your choice [1]: " UPDATE_CHOICE

        case $UPDATE_CHOICE in
            2)
                echo ""
                echo -e "${BLUE}Skipping update. Current version: $LOCAL_VERSION${NC}"
                echo ""
                exit 0
                ;;
            3)
                echo ""
                echo -e "${BLUE}Proceeding with fresh install...${NC}"
                echo ""
                # Fall through to fresh install
                ;;
            *)
                # Get git username for update
                GIT_USERNAME=$(git config user.name 2>/dev/null || echo "")
                if [ -z "$GIT_USERNAME" ]; then
                    read -p "Enter your name: " GIT_USERNAME
                fi
                perform_update "$GIT_USERNAME"
                exit 0
                ;;
        esac
        ;;
    1)
        # Already up to date
        echo -e "${GREEN}CodeStory is already up to date!${NC} (v$LOCAL_VERSION)"
        echo ""
        echo "What would you like to do?"
        echo ""
        echo "  1) Exit"
        echo "  2) Fresh install - Reconfigure everything from scratch"
        echo ""
        read -p "Your choice [1]: " UPTODATE_CHOICE

        case $UPTODATE_CHOICE in
            2)
                echo ""
                echo -e "${BLUE}Proceeding with fresh install...${NC}"
                echo ""
                # Fall through to fresh install
                ;;
            *)
                exit 0
                ;;
        esac
        ;;
    3)
        # Offline - graceful fallback
        echo -e "${YELLOW}Could not check for updates (offline or timeout).${NC}"
        echo "Proceeding with installation..."
        echo ""
        # Fall through to fresh install
        ;;
    *)
        # Fresh install (status 2 or unknown)
        # Fall through to fresh install
        ;;
esac

# ============================================================================
# Fresh Install Flow
# ============================================================================

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

# Create .claude/skills/CodeStory directory
mkdir -p .claude/skills/CodeStory

# Create SKILL.md
cat > .claude/skills/CodeStory/SKILL.md << 'EOF'
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

Create or update `socialmedia-{username}.md` with this structure:

```markdown
## Raw Notes

**What happened this session:**
- [Bullet points summarizing the work]
- [Key moments worth sharing]
- [Interesting technical details]

**Potential angles:**
- Hook 1: [angle that might resonate]
- Hook 2: [different perspective]
- Hook 3: [the human story]

## Drafts

### LinkedIn
[Full draft matching configured tone and length]

---
Co-created with CodeStory
https://github.com/itsBrianCreates/CodeStory

### X/Twitter
[Full draft respecting 280 character limit]

---
Co-created with CodeStory
https://github.com/itsBrianCreates/CodeStory

### Threads
[Full draft, conversational tone]

---
Co-created with CodeStory
https://github.com/itsBrianCreates/CodeStory

### Bluesky
[Full draft respecting 300 character limit]

---
Co-created with CodeStory
https://github.com/itsBrianCreates/CodeStory
```

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
EOF

echo -e "  ${GREEN}✓${NC} Created .claude/skills/CodeStory/SKILL.md"

# CLAUDE.md content for auto-tracking and trigger word
CLAUDE_CONTENT='<!-- CODESTORY-START -->
## CodeStory: Auto-Tracking & Trigger

### Live Session Tracking

While working on this project, automatically log notable moments to `.social-draft-'"$GIT_USERNAME"'.md`:

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

### Trigger Word

When the user says "CodeStory" in conversation (e.g., "run CodeStory", "let'"'"'s do CodeStory", "time for CodeStory"), run the `/CodeStory` skill to generate social media content.
<!-- CODESTORY-END -->'

# Handle CLAUDE.md
if [ -f "CLAUDE.md" ]; then
    # Check if CodeStory section already exists
    if grep -q "CODESTORY-START" CLAUDE.md; then
        echo -e "  ${YELLOW}!${NC} CLAUDE.md already has CodeStory section (skipped)"
    else
        # Append to existing CLAUDE.md
        echo "" >> CLAUDE.md
        echo "$CLAUDE_CONTENT" >> CLAUDE.md
        echo -e "  ${GREEN}✓${NC} Appended CodeStory section to CLAUDE.md"
    fi
else
    # Create new CLAUDE.md
    echo "$CLAUDE_CONTENT" > CLAUDE.md
    echo -e "  ${GREEN}✓${NC} Created CLAUDE.md with CodeStory section"
fi

# Update .gitignore with all patterns
GITIGNORE_PATTERNS=(".social-draft-*.md" ".codestory-backup-*/" ".codestory-version")

if [ -f ".gitignore" ]; then
    ADDED_PATTERNS=0
    for pattern in "${GITIGNORE_PATTERNS[@]}"; do
        if ! grep -qF "$pattern" .gitignore; then
            if [ $ADDED_PATTERNS -eq 0 ]; then
                echo "" >> .gitignore
                echo "# CodeStory" >> .gitignore
            fi
            echo "$pattern" >> .gitignore
            ADDED_PATTERNS=$((ADDED_PATTERNS + 1))
        fi
    done
    if [ $ADDED_PATTERNS -gt 0 ]; then
        echo -e "  ${GREEN}✓${NC} Added $ADDED_PATTERNS pattern(s) to .gitignore"
    else
        echo -e "  ${YELLOW}!${NC} .gitignore already has all patterns (skipped)"
    fi
else
    echo "# CodeStory" > .gitignore
    for pattern in "${GITIGNORE_PATTERNS[@]}"; do
        echo "$pattern" >> .gitignore
    done
    echo -e "  ${GREEN}✓${NC} Created .gitignore with CodeStory patterns"
fi

# Write version file
write_version_file "$CODESTORY_VERSION"
echo -e "  ${GREEN}✓${NC} Created .codestory-version (v$CODESTORY_VERSION)"

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
echo "  2. When you're ready to post, use either:"
echo -e "     ${GREEN}/CodeStory${NC}  or  say ${GREEN}\"CodeStory\"${NC} in chat"
echo ""
echo "  3. Claude will generate polished drafts in:"
echo "     socialmedia-$GIT_USERNAME.md"
echo ""
echo -e "${BLUE}Customize your style:${NC}"
echo "  Edit .social-config.md to adjust platforms, tone, and length"
echo "  Add Voice Notes to help Claude match your personal style"
echo ""
echo -e "${YELLOW}Tip:${NC} Start a Claude Code session and make some changes."
echo "     Then run /CodeStory to see the magic happen!"
echo ""
