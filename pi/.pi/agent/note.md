### What `/tree` actually is
`/tree` is **conversation-history navigation + branching**, not an undo stack.

Pi stores your session as a **tree of entries** (each message has an `id` and a `parentId`). There is a single pointer called the **leaf** = “where you currently are in history”. `/tree` lets you move that leaf to an earlier point and continue from there, creating a **new branch** on your next message.

So it *is* a way to navigate between user/assistant turns and “go back”, but it’s **non-destructive**: nothing is deleted.

---

## How to use `/tree` (practical workflow)

### 1) Open it
- Type: `/tree`
- Or press **Escape twice** (default `doubleEscapeAction` is `"tree"`)

### 2) Navigate
Key controls (most useful ones):
- **↑/↓**: move through entries
- **type to search**: jump by matching text
- **Ctrl+U**: toggle “user messages only” (good if you only care about prompts)
- **Ctrl+O**: cycle filters (show more stuff, including tool/custom/label entries)
- **Shift+L**: label/bookmark an entry (helps you find “good states” later)
- **Enter**: select
- **Esc**: cancel

### 3) Understand what selecting a node does (this is the key)
Pi treats **user messages** differently from **non-user messages**:

#### If you select a **user message**
Pi assumes: “you want to re-ask/rewrite that prompt.”
- It sets the leaf to the **parent** of that user message
- It puts that user message’s text into the **editor**, so you can edit it
- When you submit, you create a **new branch** (the old “bad prompt” branch still exists)

This is the cleanest way to fix “I sent the prompt too early / incomplete”.

#### If you select an **assistant message** (or compaction, etc.)
Pi assumes: “continue from here.”
- It sets the leaf to the **selected node**
- The editor stays empty
- Your next message continues from that point (creating a new branch from there)

This feels closest to “rollback”, but again: it’s a rollback of **conversation state**, not your filesystem.

---

# Why does `/tree` offer “summarize branch” and what happens if you do it?

When you navigate to a different branch, pi may ask:

1) **No summary**
2) **Summarize**
3) **Summarize with custom prompt**

### What “Summarize” does
It generates a **branch summary of the path you’re leaving** (from your old leaf back to the **common ancestor** with the branch you’re switching to), then saves that as a `branch_summary` entry in the session file.

Important details:
- **It does not delete anything.** Full history remains in the JSONL session file.
- The summary is there to **carry over useful context** into the branch you’re switching to *without replaying tons of old tokens*.
- It also tracks things like **read/modified files** cumulatively (so the model can keep awareness of what changed, even when old turns aren’t in the active context).

### When it helps
- You explored approach A for 30 turns, then decide to try approach B.
- Without a summary, the new branch might “forget” what you already learned/did.
- With a summary, you get a compact “here’s what we tried and what we learned” injected into the new branch’s context.

### When you should choose “No summary”
- If the branch you’re leaving is junk or irrelevant
- If you’re just doing quick navigation and don’t want extra tokens spent

Tip: if the prompt annoys you, set:
- `branchSummary.skipPrompt: true` (it will stop asking; default becomes “no summary”)

---

## “Can’t I fork a conversation from earlier than the tip?”
Yes—two related features:

### A) Branch *inside the same session file*: use `/tree`
That’s exactly what it’s for. Jump to any earlier entry, continue, and you’ve effectively forked *in place*.

### B) Create a *new session file*: use `/fork`
`/fork` extracts history up to a chosen point into a **new session file**, so experiments don’t share the same JSONL.

There’s also CLI for it:
- `pi --fork <path|id>`

Rule of thumb:
- `/tree` = branch within one session file
- `/fork` = new session file

---

## “If I fired off a message too soon… how do I remediate?”
Three good options, depending on what you want:

### Option 1 (cleanest): rewrite that prompt via `/tree`
1. `/tree`
2. Select the **incomplete user message**
3. Press **Enter**
4. Pi puts that message into the editor → **edit it to be complete**
5. Submit

You’ll get a new branch where the prompt is corrected, and the old mistaken branch remains for reference.

### Option 2: jump to just *before* the bad message and write a fresh one
1. `/tree`
2. Select the **assistant message right before** your incomplete user prompt
3. Enter
4. Write a brand-new correct prompt

### Option 3 (quick and fine): just send a follow-up correction
Works, but it “pollutes” the branch with a confusing partial prompt + correction sequence. The model usually copes, but `/tree` keeps things tidier.

---

## One last gotcha: `/tree` doesn’t revert files
`/tree` changes **conversation history position** only. If you want actual code rollback, use git (or a git-checkpointing extension/workflow).

If you tell me what you expected “rollback” to mean (conversation only vs. working tree too), I can recommend a concrete setup (plain git, or an extension-based checkpoint flow).
