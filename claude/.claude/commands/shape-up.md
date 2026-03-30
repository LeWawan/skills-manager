---
name: shape-up
description: Shape Up product development methodology — shaping, betting, and building in six-week cycles. Use when planning features, writing pitches, running cycles, mapping scopes, or deciding when to ship.
origin: ECC
---

# Shape Up — Product Development Method

A complete methodology for shipping meaningful work in fixed time windows, based on Ryan Singer's Shape Up (Basecamp). The core loop: **Shape** the work, **Bet** on it, **Build** it in six weeks.

## Targeting Risk — The Unifying Principle

At every step, Shape Up targets one specific risk: **the risk of not shipping on time**. Risk is reduced at three levels:

1. **Shaping** reduces risk by solving open questions *before* committing the project. No rabbit holes or tangled interdependencies are handed to the team.
2. **Betting** reduces risk by capping bets at six weeks (the circuit breaker). If it runs over, it doesn't get an extension — preventing runaway projects.
3. **Building** reduces risk by integrating design and programming early. Instead of building disconnected parts and hoping they fit at the 11th hour, the team builds one meaningful piece end-to-end first, sequences from most unknown to least, and learns by integrating as soon as possible.

## When to Activate

- Planning a new feature or project
- Writing or reviewing a pitch
- Starting a new six-week cycle
- Breaking down a project into scopes
- Deciding what to cut or keep before shipping
- Evaluating whether a project is ready to bet on
- Assessing progress mid-cycle (hill chart)
- Responding to raw feature requests or bug reports

---

## Part 1: Shaping

Shaping is the pre-work done before committing a project to a team. It happens on a **separate track** from building, usually by senior people (product, design, or technical leads).

### Who Shapes

Shaping requires a **generalist** profile combining three skills:
- **Interface design** thinking (from the user's perspective)
- **Technical literacy** (judge what's possible, easy, or hard — even without writing code)
- **Strategic thinking** (appetite setting, business priorities, opportunity cost)

You either embody this as one person or collaborate with 1-2 others. Shaping is a **closed-door, creative process** — rough sketches on paper or whiteboard with a trusted collaborator.

### Two Tracks

Shaping and building run in **parallel**:
- During any cycle, teams **build** previously shaped work
- Shapers work on what teams **might build** in a future cycle
- Shaping work is kept **private** until the betting table — shapers can shelf or drop work that isn't coming together

### Properties of Well-Shaped Work

1. **Rough** — Unfinished enough to leave room for the team's creativity. No wireframes, no pixel-perfect mocks.
2. **Solved** — The main elements of the solution are defined and connected at the macro level. Not specified down to tasks, but the direction is clear.
3. **Bounded** — Indicates what NOT to do. Has a clear appetite (time budget) and explicit scope limits.

### Step 1: Set Boundaries

Before solving anything, establish constraints:

**Set the Appetite**
- **Small Batch**: 1-2 weeks (1 designer + 1-2 programmers). Several batched per cycle.
- **Big Batch**: Full 6 weeks (1 designer + 1-2 programmers). One per team per cycle.
- The appetite is NOT an estimate. Estimates start with a design and end with a number. Appetites start with a number and end with a design.

**Fixed Time, Variable Scope**
- Time is fixed. Scope is adjusted to fit.
- This is the fundamental principle. Never extend time — cut scope instead.

**"Good" is Relative**
- There's no absolute "best" solution. The best is relative to your constraints.
- The appetite leads to different solutions: a full database model for the fancy version, or just a flat textarea for the simple version.
- We can only judge "good" in the context of how much time we want to spend and how important it is.

**Narrow the Problem**
- Don't accept requests at face value. Dig into *when* and *why* the problem occurs.
- Flip from "What could we build?" to "What's really going wrong?"
- Beware **grab-bags** ("Redesign the Files section", "Files 2.0") — they have no clear boundaries. Reframe them around a specific pain point.

**Default response to raw ideas**: "Interesting. Maybe some day." — a soft "no" that keeps options open.

### Step 2: Find the Elements

Sketch out the solution at the right level of abstraction — concrete enough to act on, abstract enough to leave room for creativity.

**Breadboarding** (for interaction flows):
- **Places**: Screens, dialogs, menus (drawn as underlined names)
- **Affordances**: Buttons, fields, copy (listed below the place)
- **Connection lines**: Show navigation between places
- Words only, no pictures. Focus on topology and flow.

**Fat Marker Sketches** (for visual concepts):
- Use broad strokes that prevent adding detail
- Good for 2D layout problems where arrangement matters
- Label clearly for others to understand

**Room for designers**: Working at the right level of abstraction leaves creative room. Specific mockups bias people — even unintentionally. Breadboards and fat markers avoid this.

**No conveyor belt**: At this stage, you can still walk away from the project. No commitment has been made. You've added value to a raw idea by making it more actionable, but you aren't obligated to bet on it.

**Output**: A list of concrete elements, not a spec. Example:
- "A new 'use this to Autopay?' checkbox on the existing Pay screen"
- "A 'disable Autopay' option on the invoicer's side"

### Step 3: Address Risks and Rabbit Holes

Stress-test the concept before betting on it:

- Walk through use cases in slow motion — look for gaps
- Ask: Does this require new technical work we've never done? Are we assuming a design solution exists that we haven't validated?
- **Patch holes**: Make specific design decisions on tricky spots to prevent the team from getting stuck
- **Declare out of bounds**: Explicitly list what the project does NOT cover
- **Cut back**: Remove nice-to-haves that aren't essential to the core value
- **Present to technical experts**: Walk through the concept on a whiteboard. Ask "Is X possible in 6 weeks?" not "Is X possible?"

**Goal**: Thin-tailed risk profile — no unknowns that could blow up the timeline.

### Step 4: Write the Pitch

Package the shaped work into a formal document with **5 ingredients**:

```
## 1. Problem
A specific story showing why the status quo doesn't work.
The baseline users are dealing with today.

## 2. Appetite
How much time we want to spend (Small Batch: 1-2 weeks / Big Batch: 6 weeks).
This constrains the solution — stating it prevents unproductive debates.

## 3. Solution
Core elements described with embedded sketches or annotated fat marker drawings.
Concrete enough to "get" the idea, abstract enough to leave room for design.

## 4. Rabbit Holes
Specific technical or design decisions called out to prevent the team from getting stuck.
Patches for known risks.

## 5. No-Gos
Functionality or use cases explicitly excluded.
Things we are intentionally NOT building to fit the appetite.
```

Post the pitch asynchronously for stakeholders to read before the betting table.

---

## Part 2: Betting

### No Backlogs

- Backlogs are a weight that grows endlessly and wastes time on grooming.
- Instead: each person/department tracks their own ideas informally.
- **Important ideas come back**. If you hear about a problem once and never again, it probably wasn't critical.

### The Betting Table

A short meeting during cool-down where stakeholders decide what goes into the next cycle.

**Inputs**: Only well-shaped pitches from the last 6 weeks (or purposefully revived older pitches). No backlog review.

**Participants**: Senior leadership (CEO, CTO, product strategist). Keep it small.

**Output**: A cycle plan — which projects, which teams.

**Rules**:
- Only bet one cycle at a time (keep the slate clean)
- If a pitch doesn't get picked, it's let go — anyone can revive it later
- Everyone reads pitches in advance; meeting stays short (1-2 hours max)
- No "step two" approval needed — the betting table IS the final decision

### The Meaning of a Bet

1. **Payout**: Something meaningful ships at the end. Not incremental progress.
2. **Commitment**: The team gets the full 6 weeks uninterrupted. No pulling people away.
3. **Capped downside**: Maximum loss is 6 weeks (the circuit breaker).

### The Circuit Breaker

- If a project doesn't ship in 6 weeks, it does NOT get an extension by default.
- This prevents runaway projects and forces better shaping.
- If it didn't ship, something was wrong in the shaping — reshape and re-bet, don't just add time.
- Motivates teams to take ownership: they must make trade-offs about scope to ship on time.

### Multi-Cycle Projects

- Even for features that feel like they need more than 6 weeks, **only bet one cycle at a time**.
- Shape a specific 6-week target with something fully built and working at the end.
- If it goes well, bet the next cycle. If not, change course or do something else entirely.
- Keep the slate clean — never carry scraps of old work over without reshaping them.

### Cool-Down (2 weeks between cycles)

- No scheduled project work
- Team fixes bugs, explores ideas, addresses tech debt
- Betting table meets to plan the next cycle

### Handling Bugs

1. **Use cool-down** for most bugs (6 weeks is not long to wait)
2. **Bring to betting table** if too big for cool-down — shape it like any other pitch
3. **Annual bug smash** — dedicate one cycle per year to fixing accumulated bugs

### Questions at the Betting Table

- Does the problem matter? (weigh against other problems)
- Is the appetite right? (would we feel differently at a smaller appetite?)
- Is the solution attractive? (hidden costs like lost screen real estate?)
- Is this the right time? (team morale, recent project types, news splash?)
- Are the right people available? (expertise, preferences, vacations?)

### New Products — Three Phases

| Phase | Shaping | Team | Goal |
|-------|---------|------|------|
| **R&D Mode** | Fuzzy, exploratory | Senior people only | Spike, not ship. Find load-bearing architecture |
| **Production Mode** | Deliberate, standard Shape Up | Any team | Ship (merge to main, expect not to touch again) |
| **Cleanup Mode** | No shaping | Everyone, no boundaries | Fix everything needed before launch (max 2 cycles) |

---

## Part 3: Building

### Hand Over Responsibility

- **Assign projects, not tasks**. The team defines their own tasks and approach.
- **Done means deployed**. Testing and QA happen within the cycle.
- The pitch stays "whole" — don't shred it into disconnected tickets.

### Kick-Off

- Create a dedicated project space and add the team
- Post the shaped concept (pitch or distilled version) as the first message
- Arrange a call to walk through the shaped work and answer questions
- Then let the team get started autonomously

### Getting Oriented (Days 1-3)

- Expect radio silence. The team is reading code, understanding the system, finding a starting point.
- Don't ask for status in the first 3 days. If silence persists past day 3, check in.
- **Imagined tasks** (what you think needs doing) will be replaced by **discovered tasks** (what actually needs doing) as real work begins.

### Get One Piece Done

Build one **vertical slice** (front-end + back-end integrated) early in the first week:

- Pick something **core** (central to the concept), **small** (finishable in days), and **novel** (eliminates uncertainty)
- **Start in the middle** — skip login, setup screens, etc. Jump to the interesting problem.
- Designers: provide **affordances before pixel-perfect screens** — basic HTML with enough hierarchy to test the interaction
- Programmers: don't wait for design. Start on back-end problems informed by the pitch.
- **Program just enough for the next step** — strategic scaffolding, not full implementation

Motto: **First make it work, then make it beautiful.**

### Map the Scopes

Organize work by **structure of the project**, not by person or role.

**Scopes** = integrated slices that can be finished independently (few days each). They become the **language of the project**.

**How scopes emerge**:
1. Start with flat task lists as you discover work
2. After ~1 week, group tasks into scopes based on real interdependencies
3. Each scope becomes a to-do list; tasks live under their scope
4. Scopes get redrawn as the team learns more — this is normal

**Signs scopes are right**:
- You can see the whole project; nothing worrying is hidden in details
- Conversations flow naturally using scope names
- New tasks have an obvious home

**Signs scopes need redrawing**:
- Hard to say how "done" a scope is (tasks are unrelated)
- Name is generic ("front-end", "bugs") — these are grab bags
- Too big to finish soon

**Special patterns**:
- **Layer cakes**: Even front-end/back-end split — integrate in same scope
- **Icebergs**: Heavy back-end or front-end — factor out and separate
- **Chowder**: A catch-all for loose tasks (keep it under 3-5 items)
- Mark nice-to-haves with **~** prefix

### Show Progress — The Hill Chart

**Why not just count tasks?** To-do lists actually *grow* as the team makes progress — discovered tasks outnumber imagined tasks. At any point, you can't tell from the outside whether outstanding tasks will go up or down. And estimates are misleading: a "4-hour task" means something very different for familiar work vs. work with unknowns (could stretch to 3 days).

The hill chart replaces task-counting and estimates with a focus on **what's unknown vs. what's solved**.

Every piece of work has two phases:

```
        Uphill                    Downhill
   (figuring it out)            (execution)
        /          \
       /   unknowns  \         certainty,
      /   uncertainty  \       confidence,
     /   problem-solving\      knowing what to do
    /                    \
   /                      \
  /________________________\
```

- **Uphill**: "I'm still figuring out my approach" -> "I've validated it" -> "No more unknowns"
- **Downhill**: "I can see all remaining work" -> "Almost done" -> "Done"

**Plot each scope as a dot on the hill.** Move dots as work progresses.

**Key insights**:
- A dot that doesn't move = raised hand ("something might be wrong")
- Compare snapshots over time to see what's moving vs stuck
- If a scope is stuck, try breaking it into smaller scopes
- **Build your way uphill** — validate with real code, not just thinking
- First third uphill = "I've thought about this"; second third = "I've validated my approach"; final third = "No more unknowns"

**Sequence work using the hill**:
- Push the **scariest/most unknown** scopes uphill first
- Leave routine work for last
- Like the journalist's "inverted pyramid" — most essential info first

### Decide When to Stop

**Compare to baseline, not to the ideal.**
- Ask: "Is this better than what customers have now?" not "Is this perfect?"
- The question is not "Can we make it better?" (always yes) but "Is it good enough to ship?"

**Scope Grows Like Grass**
- Scope creep isn't the fault of bad people. Projects are opaque until you're in the work.
- Every project is full of scope we don't need. Not every part needs equal polish, speed, or prominence.
- Rather than trying to stop scope from growing, give teams tools and authority to constantly cut it down.

**Cutting Scope Isn't Lowering Quality**
- Making choices makes the product better *at some things instead of others*.
- Variable scope is about being picky about what actually matters and moves the needle.
- Differentiating core from peripheral is a competitive advantage.

**Scope Hammering** — forcefully question every addition:
- Is this a must-have for the new feature?
- Could we ship without this?
- What happens if we don't do it?
- Is this a new problem or pre-existing?
- How likely is this case? How many customers see it?
- Is it core or edge case?
- What's the actual impact if this condition occurs?
- How aligned is the use case with our intended audience?

**Must-haves** = tasks that define "done" for a scope.
**Nice-to-haves** = marked with **~**, cut if time runs out.

**QA**: Comes in toward end of cycle for edge cases only. Designers and programmers own basic quality. QA issues are nice-to-haves by default — team triages and elevates as needed. Collect QA issues on a separate to-do list; if a must-have, drag it to the relevant scope.

**Code Review**: Same philosophy as QA — a level-up, not a gate. The team can ship without waiting for code review. If there's time and it makes sense, someone senior looks at the code. It's a teaching opportunity, not a mandatory checkpoint.

**Extending a project** (very rare, only if):
1. Outstanding tasks are true must-haves that survived scope hammering
2. ALL remaining work is downhill (no unknowns)
3. Even then, prefer to use cool-down time rather than extending

### Move On

After shipping:
- **Let the storm pass** — don't react to immediate feedback knee-jerk style
- **Stay debt-free** — say a gentle "no" to follow-up requests. They need to be shaped like any other idea.
- **Feedback needs to be shaped** — raw requests go back to Step 1 (Set Boundaries). Shape them on the next shaping track, then bet at the next betting table.

---

## Adapting to Your Size

### Small Teams (2-3 people)

- Skip formal structure: no rigid 6-week cycles, no cool-down, no formal pitches or betting table
- Same people alternate between shaping and building
- Be deliberate about which hat you're wearing and what phase you're in
- Bets can be different sizes: 2 weeks here, 3 weeks there
- Still shape, bet, and build — just more fluidly

### Large Teams (specialized roles)

- Full structure: 6-week cycles, 2-week cool-downs, formal betting table
- Dedicated shapers work on an "out of cycle" track
- Multiple teams can build in parallel
- Dedicated SIP/Ops/Support teams handle interruptions so build teams stay focused
- Cool-down between cycles gives everyone room to fix bugs and breathe

### How to Begin

**Option A: One Six-Week Experiment**
1. Shape one significant project conservatively
2. Carve out 1 designer + 2 programmers for 6 uninterrupted weeks
3. Kick off with the pitch, let team discover their own tasks
4. Focus on Get One Piece Done — don't worry about scopes or hill charts yet
5. Use success to lobby for wider adoption

**Option B: Start with Shaping**
- If you can't control team allocation, just shape better projects
- Present well-shaped work through your existing scheduling process
- Better-shaped work naturally demonstrates the method's value

**Option C: Start with Cycles**
- Switch from 2-week sprints to 6-week cycles
- Removes constant planning overhead, gives teams momentum
- Once breathing room exists, start thinking about shaping

**Fix Shipping First**: Build your shipping muscles before worrying about discovery/research. If you can't ship, the best insights don't matter.

**Focus on the End Result**: Don't micromanage hours or days. Ask: "Will we feel good about what we shipped after six weeks?" The outcome matters, not the minute-by-minute process.

---

## Glossary Quick Reference

| Term | Definition |
|------|-----------|
| **Appetite** | Time budget for a project (not an estimate) |
| **Baseline** | Current reality for customers without the feature |
| **Bet** | Commitment of a team to a project for one cycle |
| **Betting table** | Meeting to decide next cycle's projects |
| **Big Batch** | One project, full 6-week cycle |
| **Small Batch** | Set of 1-2 week projects in one cycle |
| **Breadboard** | UI concept: affordances + connections, no visuals |
| **Circuit breaker** | Cancel projects that don't ship in one cycle |
| **Cool-down** | 2-week break between cycles |
| **Cycle** | 6-week uninterrupted work period |
| **Fat marker sketch** | Low-fidelity UI sketch with thick lines |
| **Hill chart** | Status diagram: unknown -> known -> done |
| **Iceberg** | Scope with disproportionate front/back-end work |
| **Layer cake** | Scope with even front/back-end distribution |
| **Pitch** | Document presenting a shaped project for betting |
| **Rabbit hole** | Unknown/complex part that could blow up timeline |
| **Scope** | Independent, integrated slice of a project |
| **Scope hammering** | Forcefully cutting scope to fit the time box |
| **Discovered tasks** | Tasks found by doing real work (vs imagined tasks) |
| **Imagined tasks** | Tasks assumed before doing the work |
| **Chowder** | Catch-all list for loose tasks that don't fit any scope |
| **De-risk** | Remove unknowns through shaping to improve odds of shipping |
| **Raw ideas** | Unshaped requests or feature ideas expressed in words |
| **Time horizon** | Longest period where the deadline pushes from the start (6 weeks) |
| **R&D mode** | Early new-product phase: senior team spikes core features |
| **Production mode** | New-product phase: standard Shape Up with delegated teams |
| **Cleanup mode** | Pre-launch phase: unstructured time to fix everything before shipping |
| **Uphill/Downhill** | Unknowns phase vs execution phase |

---

## How to Apply This Skill

When the user invokes this skill, help them with the relevant phase:

### If shaping a feature:
1. Help define the appetite (Small Batch or Big Batch?)
2. Narrow the problem — ask "What's really going wrong?" not "What should we build?"
3. Sketch elements using breadboard or fat marker notation
4. Identify rabbit holes and propose patches
5. Draft the pitch with all 5 ingredients

### If at the betting table:
1. Review pitches against the 5 questions (problem matters? appetite right? solution attractive? right time? right people?)
2. Ensure each pitch has all 5 ingredients
3. Help decide which pitches to bet on

### If building (mid-cycle):
1. Help map scopes from discovered tasks
2. Identify what to build first (core, small, novel)
3. Use hill chart thinking to sequence unknowns first
4. Scope hammer when time gets tight — separate must-haves from nice-to-haves

### If deciding to ship:
1. Compare to baseline, not ideal
2. Apply scope hammering questions
3. Verify remaining work is all downhill before considering any extension
