---
name: experiment-miner
description: Mines your recent conversations for latent experiments — moments where you said something that implies a concrete action, a measurable outcome, and a deadline, but didn't formally commit to it. Trigger when the user says "find my experiments", "what did I commit to", "mine my chats", "what should I be testing", "extract experiments", "what hunches do I have", or any variation of wanting to surface actionable experiments from past conversations. Also trigger when the user wants to review or update the status of experiments already tracked. Produces and maintains a spreadsheet of experiments with status tracking.
---

# experiment-miner

## Purpose

Read the user's recent conversations and extract moments that match the **trifecta pattern**:

1. **A concrete action** that is an experiment for something the user cares about
2. **A measurable outcome** — something observable that either happens or doesn't
3. **A deadline** — a specific date or timeframe

These three together form a "latent experiment" — something the user implicitly committed to (or was clearly about to) in natural conversation, without necessarily formalizing it. This skill finds them, presents them for confirmation, and tracks them in a spreadsheet.

## Workflow

### Step 1: Mine recent conversations

Use `conversation_search` and `recent_chats` to scan the user's recent conversations. Run multiple searches with different queries to cast a wide net:

Suggested search queries (adapt based on what you know about the user):
- "I'm going to try"
- "I want to test"
- "by next week"
- "I should"
- "let's see if"
- "I bet"
- "the plan is"
- "I'll report back"
- "concrete action"
- "deadline"
- Also search for topics the user has been actively working on — projects, ideas, people they mentioned meeting

For each conversation returned, read carefully for moments where the user (not Claude) said something that contains or implies all three elements of the trifecta. Be generous in interpretation but honest about which elements are explicit vs. inferred.

### Step 2: Present candidates

Show the user what you found as a numbered list of **candidate experiments**. For each candidate, show:

- **Source**: which conversation it came from (with link)
- **The moment**: a brief description of what the user said
- **Action**: the concrete thing to do (extracted or lightly inferred)
- **Outcome**: the measurable result (extracted or lightly inferred)
- **Deadline**: the date or timeframe (extracted or inferred — if no deadline was stated, suggest one)
- **Confidence**: high (all three elements were explicit), medium (one element inferred), or low (two elements inferred)

Be honest about confidence levels. A moment where the user said "I should probably exercise more" is low confidence — there's a vague action but no outcome or deadline. A moment where the user said "I'm meeting Christin on Monday to see if we can extract a concrete experiment from a real conversation" is high confidence — all three elements are explicit.

### Step 3: Sharpen

This is the most important step. Raw extractions are almost never concrete enough to act on. Before the user accepts or rejects anything, **walk each candidate through a short conversational sharpening pass**.

The sharpening is a quick, non-bossy exchange — 2-4 questions max per candidate — that pushes the action toward something the user can picture themselves actually doing. The test for "sharp enough" is: **can you picture yourself doing this specific thing, and would you know by the deadline whether it happened?** If the answer to either is no, it's not done yet.

Sharpening questions (use the ones that fit, skip what's already clear):

**For vague actions:**
- "What would you actually *do*, concretely? Like, what's the first physical or digital thing you'd do?"
- "When exactly would you do this — is there a specific day or moment?"
- "Is this still something you'd want to do given everything that's changed since you said it?"

**For vague outcomes:**
- "How would you know it worked? What would you see or have that you don't now?"
- "If I asked you on the deadline day 'did it happen,' what would you be checking?"

**For missing deadlines:**
- "By when? Pick a day."

**The concreteness standard.** Compare every sharpened experiment to this example of a good one: *"Meet with Christin on Monday, record the conversation, see if she walks away with one specific thing to try by a named date."* That has a person, a day, an action you can picture, and an outcome you'd know immediately. If a candidate doesn't reach that level of concreteness after sharpening, either sharpen harder or let the user drop it — a vague experiment tracked in a spreadsheet is worse than no experiment at all, because it clutters the ledger without producing usable signal.

**Sharpening is conversational, not interrogative.** Don't ask all the questions at once. Don't present them as a checklist. Take one candidate at a time, ask the most important missing question, let the user respond, and either accept or ask one more. Two exchanges per candidate is usually enough. If the candidate needs more than four exchanges to become concrete, it's probably not ready and the user should shelve it.

**It's fine to lose candidates during sharpening.** If the user says "actually, I don't care about this one anymore" or "this felt important when I said it but it doesn't now," that's a successful sharpening — it killed a zombie commitment before it hit the spreadsheet. The spreadsheet should only contain experiments the user actually wants to run *right now*, not everything they ever mentioned.

### Step 4: User commits

After sharpening, the user sees the final version of each surviving candidate and confirms:
- **Track it** — goes into the spreadsheet as active
- **Drop it** — gone, no record needed
- **Add** experiments the skill missed — these also go through sharpening before tracking

Only sharpened, confirmed experiments enter the spreadsheet.

### Step 5: Write to spreadsheet

Create or update an Excel spreadsheet with the following columns:

| Column | Description |
|--------|-------------|
| ID | Auto-incrementing number |
| Date Added | When the experiment was extracted |
| Hunch | What the user is curious about (1 sentence) |
| Action | The specific thing they're doing |
| Outcome | The measurable result they'll look for |
| Deadline | The specific date |
| Status | active / resolved-yes / resolved-no / dropped |
| Result | What actually happened (filled in at resolution) |
| Source | Link to the original conversation |
| Notes | Anything else worth tracking |

**Spreadsheet location**: `/mnt/user-data/outputs/experiments.xlsx`

If the file already exists, load it and append new experiments. If it doesn't, create it fresh.

Use openpyxl for creation. Keep formatting clean and simple:
- Bold headers, auto-width columns
- Light green fill for resolved-yes rows
- Light red fill for resolved-no rows
- Light yellow fill for active rows approaching deadline
- No formulas needed — this is a data store, not a financial model

### Step 6: Review mode

If the user asks to review their experiments (or if the skill notices experiments past their deadline), switch to review mode:

1. Load the spreadsheet
2. Show experiments grouped by status:
   - **Past deadline (needs resolution)**: experiments where today > deadline and status is still "active"
   - **Active**: experiments in progress
   - **Recently resolved**: experiments resolved in the last 30 days
3. For past-deadline experiments, ask the user: "This was due [date]. What happened? Did [outcome] happen — yes or no?"
4. Update the spreadsheet with the resolution

### Step 7: Analysis mode

If the user asks for analysis, or after accumulating 10+ resolved experiments, offer pattern observations:

- What fraction resolved yes vs. no?
- Are there themes in the experiments that resolve yes vs. no?
- Are there experiments that keep getting re-created (same hunch, new deadline)?
- What's the average time between creating an experiment and resolving it?
- Are there stuck areas where the user keeps circling without committing?

Keep analysis brief and curious, not clinical. The tone should be "huh, interesting pattern" not "your success rate is 43%."

## Tone

This skill is a utility, not a conversational partner. It's more like a good research assistant than a curious friend. Be efficient, clear, and slightly warm. Don't over-explain. Don't be playful in the way `hunch` is — this is a different mode. The user is asking you to do extraction work, not to have a conversation about their feelings.

But: when presenting candidates, be genuinely curious about the ones that seem most interesting. A brief "this one's interesting because you've mentioned it in three separate conversations" is useful signal, not noise.

## Important notes

- **Only extract experiments from things the USER said**, not from things Claude said or suggested. Claude's suggestions don't count as user commitments.
- **Don't manufacture experiments.** If a conversation doesn't contain the trifecta pattern, don't force it. It's fine to come back with "I found 2 strong candidates and 1 weak one" rather than padding with low-confidence extractions.
- **Respect the user's no.** If they reject a candidate, drop it. Don't argue that it's a good experiment they should track.
- **The spreadsheet is the source of truth.** Always load it before adding new experiments to avoid duplicates. Check whether a candidate is already being tracked before presenting it as new.
- **Deadline hygiene.** If the user's original statement had no deadline, suggest one but flag it as inferred. Default to one week from today for small actions, two weeks for larger ones. The user can always override.
