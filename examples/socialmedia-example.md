# Social Media Content

---

## Session: 2024-01-15 at 4:30 PM

Generated: 2024-01-15 at 4:30 PM

### Raw Notes

**What happened this session:**
- Fixed a nasty authentication bug (tokens were being URL-encoded twice)
- Refactored the validation layer from 400 lines down to 120
- Added rate limiting using a sliding window approach
- Wrote tests for the new rate limiter (all passing)

**Potential angles:**
- Hook 1: The debugging story (URL encoding bug hunt)
- Hook 2: The refactor win (400 lines to 120)
- Hook 3: Making technical decisions (why sliding window over fixed buckets)

### Drafts

#### LinkedIn

Spent my afternoon hunting a bug that turned out to be hilariously simple.

Users were randomly getting logged out. Checked the auth flow, the token storage, the session handling. Everything looked fine. Took me two hours to realize the token was being URL-encoded twice before hitting the API.

One line fix. Two hours of detective work.

While I was in there, I noticed our validation layer had gotten out of hand. 400 lines of spaghetti accumulated over months of "quick fixes." Took another hour to refactor it down to 120 lines.

Sometimes the best code you write is the code you delete.

---
Co-created with CodeStory
https://github.com/itsBrianCreates/CodeStory

#### X/Twitter

spent 2 hours debugging an auth issue

turns out the token was being URL encoded twice before hitting the API

one line fix

also refactored 400 lines of validation code down to 120 while I was in there. sometimes the best code you write is the code you delete

---
Co-created with CodeStory
https://github.com/itsBrianCreates/CodeStory

#### Threads

Two hour debugging session today. Users getting randomly logged out, no pattern, nothing in the logs that made sense.

Checked auth flow. Fine. Token storage. Fine. Session handling. Fine.

Finally found it: the auth token was being URL-encoded twice before hitting the API. One extra line of code from a "fix" three months ago.

One line to fix. Two hours to find.

Also refactored our validation layer while I was in there. 400 lines down to 120. Felt good to delete more code than I wrote today.

---
Co-created with CodeStory
https://github.com/itsBrianCreates/CodeStory

#### Bluesky

Today's debugging adventure: 2 hours to find a bug, 1 line to fix it.

Auth tokens were getting URL-encoded twice. Classic case of a "quick fix" from months ago causing mysterious logouts.

Also deleted 280 lines of validation code. Sometimes less really is more.

---
Co-created with CodeStory
https://github.com/itsBrianCreates/CodeStory

---

*Copy these drafts and paste directly to your platforms.*

---

## Session: 2024-01-14 at 10:15 AM

Generated: 2024-01-14 at 10:15 AM

### Raw Notes

**What happened this session:**
- Set up the project boilerplate with TypeScript
- Configured ESLint and Prettier
- Built the initial API structure

**Potential angles:**
- Hook 1: Starting a new project from scratch
- Hook 2: The tooling decisions that save future headaches

### Drafts

#### LinkedIn

Starting a new project is always a mix of excitement and decision fatigue. Today was all about laying the foundation right.

TypeScript for type safety. ESLint and Prettier working together so I never argue with myself about semicolons again. A clean API structure that will scale when we need it to.

None of this is glamorous work. But future me will thank present me when everything just works.

---
Co-created with CodeStory
https://github.com/itsBrianCreates/CodeStory

#### X/Twitter

Started a new project today. Spent the morning on boilerplate nobody will ever see.

TypeScript, ESLint, Prettier, folder structure. Boring but necessary.

Future me will thank present me.

---
Co-created with CodeStory
https://github.com/itsBrianCreates/CodeStory

---

*Copy these drafts and paste directly to your platforms.*
