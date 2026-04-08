---
name: shape-up-shape
description: Shape Up shaping phase — transform a raw idea into a ready-to-pitch project. Use when defining appetite, narrowing problems, sketching elements, de-risking, and writing pitches.
origin: ECC
---

# Shape Up — Shaping

Transform a raw idea into a shaped project that's ready to pitch and bet on. Shaping happens on a **separate track** from building, by senior people (product, design, or technical leads). It's a **closed-door, creative process**.

**Who shapes**: Generalists combining interface design thinking, technical literacy, and strategic sense. Solo or with 1-2 trusted collaborators.

---

## Step 1: Raw Idea -> Appetite

Every project starts with a raw idea. Before diving into solutions, decide how much time it's worth.

**Set the appetite** — a time budget, NOT an estimate:
- **Small Batch**: 1-2 weeks (1 designer + 1-2 programmers). Several batched per cycle.
- **Big Batch**: Full 6 weeks (1 designer + 1-2 programmers). One per team per cycle.

Estimates start with a design and end with a number. **Appetites start with a number and end with a design.** The appetite is a creative constraint.

**Fixed time, variable scope**: Time is locked. Scope adjusts to fit. This is the fundamental principle — never extend time, cut scope instead.

**"Good" is relative**: There's no absolute best solution. A full database model might be right for a 6-week appetite; a flat textarea is right for a 2-week one. We can only judge "good" in context of how much time we want to spend.

**Default response to raw ideas**: "Interesting. Maybe some day." — a soft "no" that keeps options open. Don't say "yes" or "no" on first contact. Don't put it in a backlog.

---

## Step 2: Narrow the Problem — Set Boundaries

Don't accept requests at face value. Dig deeper.

**Flip the question**: From "What could we build?" to **"What's really going wrong?"**

- Ask *when* the problem occurs, not *what* solution they want
- Look for the specific moment where the workflow breaks down
- Find the specific pain point that drives the request

**Beware grab-bags**: "Redesign the Files section" or "Files 2.0" — these have no boundaries. No clear start or end. They're not projects, they're wishes.

Reframe them: "We need to rethink the Files section because **sharing multiple files takes too many steps**." Now you have a specific pain point to shape around.

**If you can't narrow it down**: Your appetite tells you how much research is worthwhile. If you can't get your hands around the problem, walk away. Maybe a future request will give you better insight.

**Boundaries in place when you have**: a raw idea + an appetite + a narrow problem definition.

---

## Step 3: Find the Elements

Now sketch out a solution at the right level of abstraction. Not a spec — **boundaries and rules of a game** that could go in countless ways when it's time to play.

**Move fast.** Work with a trusted partner or alone. Avoid the wrong level of detail.

### Breadboarding (for interaction flows)

Words only, no pictures. Three things to draw:
- **Places**: Screens, dialogs, menus (underlined names)
- **Affordances**: Buttons, fields, copy (listed below the place)
- **Connection lines**: Navigation between places

Focus on topology — what's connected to what. Writing out flows confronts you with questions you didn't think of.

### Fat Marker Sketches (for visual concepts)

When the 2D arrangement IS the problem (layout, spatial relationships):
- Use broad strokes that **prevent adding detail**
- Just enough to work out main elements
- Label clearly for others to understand

### Output

A list of concrete elements — specific enough to act on, abstract enough to leave room:
- "A new 'use this to Autopay?' checkbox on the existing Pay screen"
- "A 'disable Autopay' option on the invoicer's side"
- "A 2-up monthly grid with dots for events, no spanned pills"

**Room for designers**: Working at this level of abstraction leaves creative room. Specific mockups bias people — breadboards and fat markers avoid this.

**No conveyor belt**: You can still walk away. No commitment has been made. You've made the idea more actionable, but you're not obligated to bet on it.

---

## Step 4: Address Risks — Remove Unknowns & Tricky Issues

All it takes is **one hole** in the concept to derail the project. A 2-week unknown burns a third of the budget.

### Go deeper

Slow down. Walk through use cases **in slow motion**. Ask yourself:

- **Did we miss anything?** Are there gaps in the flow?
- **Any unfair technical assumptions?** Things we're assuming are easy that aren't?
- **Does this require new technical work we've never done before?**
- **Are we making assumptions about how the parts fit together?**
- **Are we assuming a design solution exists that we couldn't come up with ourselves?**
- **Is there a hard decision we should settle in advance so it doesn't trip up the team?**

### Patch the holes

When you find a risk, make a **specific design decision** to eliminate it. Trade-offs are easier to make now than under cycle pressure. Example: "We'll leave completed items exactly as they work today and just append the group name" — not perfect, but it removes a week of risk.

**Goal**: Thin-tailed risk profile. Independent, well-understood parts that assemble in known ways.

---

## Step 5: Declare Out of Bounds

Explicitly **call out cases you're NOT supporting**. Everyone on the team will naturally want to cover all use cases — listing no-gos prevents scope explosion.

Example: "Group notifications only apply to message posting. We are NOT supporting groups for to-do assignments or chat mentions in this project."

---

## Step 6: Discuss with Technical Experts

Before writing up the pitch, grab technical experts for a **whiteboard session**.

**Set the tone**: "Here's something I'm thinking about... but I'm not ready to show anybody yet... what do you think?"

Communicate this is an idea you're shaping, NOT something coming down the pipe.

**Key questions**:
- **"Is X possible in 6 weeks?"** — not "Is X possible?" (everything is possible in software, nothing is free)
- Walk through the constraints so they're partners in keeping scope within appetite
- Hunt for **time bombs** that could blow up the project
- **"Can we drastically simplify or approach this differently?"**

**Keep the clay wet**: Redraw elements on the whiteboard from the beginning. Don't present a finished document. Build up the concept step by step, then open it for revisions.

Depending on the conversation: either you've **validated your approach** or discovered problems that need another round of shaping.

---

## Step 7: Write the Pitch

Package shaped work into a formal document with **5 ingredients**:

### 1. Problem

A **single specific story** that shows why the status quo doesn't work. This is your baseline.

- What are customers doing today without this feature?
- At what specific moment does the workflow break down?
- Why is the current situation worse than what we're proposing?

The problem establishes a **test of fitness** — people can weigh the solution (or alternatives) against this specific story and judge if the outcome is better.

Without a problem, there's no basis for discussing whether the solution is good or bad.

### 2. Appetite

What the solution looks like **based on the time we're going to spend**. Not just "6 weeks" — state it as a constraint that shaped the solution.

"We want to solve this in 2 weeks, not 6. Here's what that means for the solution..."

Stating the appetite prevents unproductive conversations. Anybody can suggest expensive solutions. It takes work to find a simple idea that fits a small time box.

### 3. Solution

The core elements, presented so people can immediately **see it**.

- Use **embedded sketches** (fat marker, redrawn on iPad) where the concept needs to be visual
- Use **annotated fat marker sketches** with labels and call-outs for complicated parts
- Stay abstract enough to leave room for design, concrete enough to "get" the idea
- Only go into visual detail for "linchpin" parts that everyone needs to see concretely

### 4. Rabbit Holes

A few lines calling out specific decisions that **patch known risks**:
- "URLs will never live on custom domains for v1"
- "Completed items stay exactly as they work today — just append the group name"
- Technical choices that prevent the team from going down dead ends

### 5. No-Gos

Things we are **intentionally NOT building**:
- "No WYSIWYG editing — users customize via a separate settings page"
- "Group notifications only for messages, not to-dos or chat"

---

## Post & Review

**Post the pitch asynchronously** where stakeholders can read it on their own time. People comment to **poke holes or contribute missing information** — not to say yes or no (that happens at the betting table).

The pitch is now ready for the betting table.

---

## Shaping Checklist

Use this to verify a pitch is ready:

- [ ] **Appetite defined** — Small Batch or Big Batch?
- [ ] **Problem narrowed** — Specific pain point, not a grab-bag?
- [ ] **Elements sketched** — Breadboard or fat marker? Concrete enough to build, abstract enough for creativity?
- [ ] **Risks addressed** — Walked through use cases in slow motion? No technical unknowns?
- [ ] **Out of bounds declared** — What are we NOT doing?
- [ ] **Technical validation** — Discussed with experts? Possible in the appetite?
- [ ] **Pitch written** — All 5 ingredients present?
- [ ] **Posted for review** — Stakeholders can read and comment?

---

## Instructions for the AI

When this skill is invoked, you are a **shaping partner**. Your job is to help the user go from a raw idea to a ready pitch — but you MUST NOT fill in the blanks yourself. **Ask questions to surface what's missing.**

### How to behave

1. **Determine where the user is in the shaping process.** Ask: "Where en es-tu ? Tu as une idee brute, un probleme deja cadre, des elements de solution, ou un pitch a revoir ?"

2. **Never skip steps.** Walk through the steps in order. If the user jumps to writing a pitch but hasn't defined the appetite, stop and ask.

3. **Ask, don't assume.** When information is missing, ask for it directly. Don't invent problems, appetites, or solutions.

### Questions to ask at each step

**Step 1 — Appetite**: If not stated:
- "Combien de temps tu veux investir la-dessus ? Small Batch (1-2 semaines) ou Big Batch (6 semaines) ?"
- "C'est un truc qui vaut un quick fix ou un cycle entier ?"

**Step 2 — Problem/Boundaries**: If vague or grab-bag:
- "C'est quoi le probleme concret ? A quel moment precis le workflow casse ?"
- "Tu peux me raconter une situation specifique ou quelqu'un a eu ce probleme ?"
- "Ca ressemble a un grab-bag — est-ce qu'on peut resserrer autour d'un use case precis ?"
- "Qu'est-ce que les gens font aujourd'hui comme workaround ?"

**Step 3 — Elements**: If no solution sketched:
- "Quels sont les elements cles de la solution ? Ou ca se place dans le produit actuel ?"
- "Comment l'utilisateur arrive sur cette fonctionnalite ? Qu'est-ce qu'il voit ? Ou ca le mene ?"
- "On peut faire un breadboard ? Quels sont les ecrans, les actions, les liens entre eux ?"

**Step 4 — Risks**: Always challenge:
- "Si on deroule le use case au ralenti, est-ce qu'on a rate un truc ?"
- "Est-ce que ca demande du travail technique qu'on n'a jamais fait ?"
- "Qu'est-ce qui pourrait prendre 10x plus longtemps que prevu ?"
- "Y a-t-il une decision design qu'on devrait trancher maintenant pour eviter que l'equipe tourne en rond ?"

**Step 5 — Out of bounds**: If not declared:
- "Qu'est-ce qu'on ne fait PAS ? Quels use cases on exclut explicitement ?"
- "Si l'equipe te demandait 'et si on ajoutait aussi X ?', qu'est-ce que tu repondrais non ?"

**Step 6 — Technical validation**: If not done:
- "Est-ce que tu as valide avec un dev que c'est faisable dans l'appetite ?"
- "Y a-t-il un point technique ou tu n'es pas sur ?"

**Step 7 — Pitch review**: When reviewing a pitch, check each ingredient:
- "Je ne vois pas de probleme concret — tu peux ajouter une story specifique ?"
- "L'appetite n'est pas explicite — Small Batch ou Big Batch ?"
- "Quels sont les rabbit holes identifies ? Qu'est-ce qui pourrait deraper ?"
- "Il manque les no-gos — qu'est-ce qu'on exclut ?"

### Output format

When the user has fourni assez d'info pour un pitch, propose un draft structure avec les 5 ingredients. Marque clairement les trous restants avec **[A COMPLETER]** pour que l'utilisateur voie ce qui manque.
