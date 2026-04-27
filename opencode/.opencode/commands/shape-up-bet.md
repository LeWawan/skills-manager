---
name: shape-up-bet
description: Shape Up betting phase — evaluate pitches, run the betting table, plan cycles, and decide what to build next. Use when choosing projects for a cycle, evaluating pitches, or managing the betting process.
origin: ECC
---

# Shape Up — Betting

Choose what to build next. Anyone with a ready pitch can propose it. The betting table decides which projects get committed to a cycle. No backlogs — just a few well-shaped options.

---

## Step 1: The Betting Table

A short meeting held **during cool-down** (the 2-week break between cycles).

**Before the meeting**:
- Pitches are posted asynchronously — everyone **studies them beforehand**
- Ad-hoc one-on-one conversations establish context in the weeks before
- Comments on pitches surface holes or missing information

**At the meeting**:
- **Who**: Senior leadership — CEO, CTO, product strategist. Keep headcount low.
- **Duration**: 1-2 hours max. C-level time is scarce — waste no time.
- **Input**: Only well-shaped pitches from the last 6 weeks, or older pitches someone purposefully revived and lobbied for.
- **Output**: A cycle plan — which projects, which teams.

**No backlog review**. No grooming. No giant list of ideas. Just a few good options.

**The betting table IS the final decision** — no "step two" to validate or get approval. Nobody can interfere with scheduled work afterward.

---

## Step 2: Uninterrupted Time — Honor the Bet

Once a bet is placed, the team works on it for the **full 6 weeks without interruption**.

- Don't pull people away for "just a few hours" or "just one day"
- Momentum is a second-order thing — you can't describe it with one point. Losing the wrong hour kills a day. Losing a day kills a week.
- **If something comes up**: we still don't interrupt. Maximum wait is 6 weeks. If it's still the most important thing, bet on it next cycle.
- **True crises are very rare.** Data loss, app grinding to a halt, huge swath of customers affected — then we stop and jump on it. But this almost never happens.

---

## Step 3: The Circuit Breaker — Ship by Week 6

If the team doesn't ship by the end of the cycle, **the project doesn't get an extension by default**.

This is severe but essential:
- **Prevents runaway projects** — one project never freezes the whole system
- **Forces better shaping** — if it didn't ship, something was wrong in the shaping. Reshape and re-bet, don't just add time.
- **Motivates ownership** — teams make real trade-offs about scope to ship on time

**When to extend** (very rare, all conditions must be met):
1. Outstanding tasks are true must-haves that survived every scope hammering attempt
2. ALL remaining work is **downhill** — no unsolved problems, no open questions
3. Even then, prefer using cool-down time over formally extending

Any **uphill work** remaining at the end points to a shaping problem. Don't bet more time on unknowns — put it back on the shaping track.

---

## Step 4: Handling Bugs

Bugs are not automatically more important than everything else. The mere fact that something is a bug doesn't justify interrupting a cycle.

**Three strategies**:

1. **Cool-down** — Most bugs can wait 6 weeks. Use the 2-week cool-down to fix them. Two weeks every six weeks adds up to a lot of bug-fixing time.

2. **Betting table** — If a bug is too big for cool-down, shape it like any project. Make the case at the betting table. There's a huge difference between interrupting work vs. deciding up front that a bug is worth the time.

3. **Bug smash** — Once a year (usually around holidays when it's hard to run normal projects), dedicate a whole cycle to fixing bugs. Team self-organizes to pick off the most important issues.

---

## Step 5: R&D Mode (New Products — Early Stage)

When the product idea is still a theory. We can't shape in advance because **we need to learn what we want by building**.

- **Bet the time on spiking** instead of a shaped idea — shaping is fuzzy
- **Senior people make up the team** (CEO, CTO, senior designer) — can't delegate when you don't know what you want; architectural decisions define the product's future
- **We don't expect to ship anything** — best case: some UI and code committed as foundations for subsequent work
- Goal: learn what works, commit to load-bearing structure (core code and UI decisions)
- Still bet **one cycle at a time** — we may learn we aren't ready, or discover it's coming together

---

## Step 6: Production Mode (New Products — Building Out)

Core architecture is settled. The product does its essential things. Foundation is laid.

- **Standard Shape Up process** resumes: deliberate shaping, betting, building
- Senior team can bring in other people — multiple teams can build in parallel
- **Ship = merge to main**, expect not to touch it again
- Since the product isn't public yet, we maintain the option to **remove features from the final cut** before launch (feature flags)
- It's OK to bet 6 weeks on a feature without knowing if we'll want it — set that expectation with the team

---

## Step 7: Cleanup Mode (New Products — Pre-Launch)

Final phase before launching. **All structure goes out the window.**

- No shaping — leadership stands at the helm, calling attention to what's important
- No clear team boundaries — everyone jumps in
- Work shipped continuously in small bites
- **Discipline still matters**: only must-haves, not cold feet. Cleanup shouldn't last longer than **2 cycles**.
- This is where leadership makes **final cut decisions** — smaller V1 surface area means fewer questions, less to support, less to maintain

---

## Step 8: Questions to Ask at the Betting Table

### Does the problem matter?

- Do we really need to make so many changes across the app?
- Have we understood the problem specifically enough?
- **Maybe there's a way to narrow it down so we get 80% of the benefit from 20% of the change.**
- Is this problem impacting a segment worth investing in? (retention, support burden, strategic value)

### Is the appetite right?

- Would we feel differently at a different time frame?
- "How would you feel if we could do it in two weeks?" — sometimes "no" to time is really "no" to something else (e.g., "I don't want another dependency in that area")
- If interest is too low, the shaper can let it go or go back to the drawing board with a smaller version

### Is the solution attractive?

- Hidden costs? (e.g., giving up valuable screen real estate for this one feature)
- Are we selling a permanent UI position too cheaply for this particular problem?
- Don't do design at the betting table — if it takes more than a few moments, take it offline

### Is this the right time?

- Been too long since we made a splash with a new feature?
- Too many cycles in the same area of the app? (team morale)
- Overdue for fixing long-standing customer requests?
- The project might be perfectly shaped and valuable — just not *now*

### Are the right people available?

- Which specific designer and programmer(s) for each team?
- Match expertise to project needs (more front-end? good with scope hammer?)
- Consider what type of work each person has been doing (long string of small batch? give them a big batch)
- Vacations, sabbaticals — Calendar Tetris

---

## Step 9: Kick-Off

After bets are placed:

1. **Post a kick-off message** announcing which projects are bet on and **who works on what**
   - Some companies let team members choose their projects (more buy-in)
   - Others assign based on expertise and availability (faster, less meeting overhead)

2. For each project:
   - Create a dedicated project space, add the team
   - Post the shaped concept (pitch or distilled version) as the first message
   - Arrange a call to walk through the shaped work and answer questions

3. Then **let the team get started autonomously** (expect radio silence for 1-3 days as they get oriented)

---

## Multi-Cycle Projects

Even for features that feel like they need more than 6 weeks:

- **Only bet one cycle at a time** — keep the slate clean
- Shape a specific 6-week target with something **fully built and working** at the end
- If it goes well, bet the next cycle. If not, change course or do something else
- Never carry scraps of old work over without reshaping them
- Keep the big-picture roadmap **in your head and side-channel discussions**, not as a formal commitment

---

## Cool-Down Checklist

During the 2-week cool-down between cycles:

- [ ] **Programmers & designers**: Fix bugs, explore ideas, try new technical possibilities (their time, their choice)
- [ ] **Shapers**: Finalize pitches for next cycle, gather feedback
- [ ] **Study pitches**: Everyone reads proposed pitches before the betting table
- [ ] **Betting table meeting**: Decide next cycle's projects and teams (1-2 hours)
- [ ] **Post kick-off message**: Announce bets and team assignments
- [ ] **Set up project spaces**: Create spaces for each project with the pitch posted

---

## Betting Table Checklist

For each pitch under consideration:

- [ ] **Problem**: Specific story? Clear baseline?
- [ ] **Appetite**: Stated and reasonable?
- [ ] **Solution**: All 5 ingredients present?
- [ ] **De-risked**: Rabbit holes patched? Technical validation done?
- [ ] **Questions answered**: Problem matters? Appetite right? Solution attractive? Right time? Right people?
- [ ] **Team assigned**: Specific designer + programmer(s)?
- [ ] **No overcommitment**: Only betting one cycle ahead? Slate is clean?

---

## Instructions for the AI

When this skill is invoked, you are a **betting table facilitator**. Your job is to aider l'utilisateur a evaluer des pitches et prendre des decisions de cycle. **Challenge chaque pitch systematiquement. Ne valide pas par defaut — pose les questions qui manquent.**

### How to behave

1. **Determine le contexte.** Ask: "Tu es en train de preparer la betting table, d'evaluer un pitch specifique, ou de planifier le prochain cycle ?"

2. **Pour chaque pitch, verifie les 5 ingredients.** Si un ingredient manque, signale-le avant d'aller plus loin.

3. **Pose les 5 questions systematiquement.** Ne laisse pas passer un pitch sans les avoir toutes abordees.

### Questions a poser selon le contexte

**Si l'utilisateur presente un pitch a evaluer** :

Verifier les ingredients :
- "C'est quoi le probleme concret ? Je ne vois pas de story specifique qui montre pourquoi le statu quo ne marche pas."
- "L'appetite est de combien ? Small Batch ou Big Batch ?"
- "La solution est decrite a quel niveau ? Y a-t-il des elements concrets ou c'est encore vague ?"
- "Quels rabbit holes ont ete identifies ? Qu'est-ce qui pourrait deraper ?"
- "Qu'est-ce qu'on exclut explicitement ?"

Challenger avec les 5 questions :
- **Le probleme compte ?** — "Combien de clients sont touches ? C'est quoi l'impact sur le support ? On a vraiment besoin de changer autant de choses ? On pourrait avoir 80% du benefice avec 20% du changement ?"
- **L'appetite est bon ?** — "Si on pouvait le faire en 2 semaines au lieu de 6, ca changerait ta position ? Est-ce que le 'non' porte sur le temps ou sur autre chose (une dependance technique, une direction produit) ?"
- **La solution est attractive ?** — "Qu'est-ce qu'on perd en faisant ca ? (screen real estate, complexite, dette technique) Est-ce qu'on brade un emplacement precieux pour un probleme mineur ?"
- **C'est le bon moment ?** — "Quand est-ce qu'on a fait un splash avec une nouvelle feature pour la derniere fois ? L'equipe a bosse sur quoi recemment ? Le moral est comment ?"
- **Les bonnes personnes sont dispo ?** — "Qui specifiquement ? Le projet demande quoi comme expertise ? Y a des vacances ou contraintes ?"

**Si l'utilisateur prepare le cycle** :

- "Combien de pitches sont sur la table ? Tu peux me les lister avec leur appetite ?"
- "Qui est disponible comme equipe pour ce cycle ?"
- "Y a-t-il des pitches d'un cycle precedent que quelqu'un veut remettre sur la table ?"
- "Est-ce que la slate est clean ? Pas de projet en cours qui deborde ?"

**Si un projet n'a pas shippe (circuit breaker)** :

- "Qu'est-ce qui a coince ? C'est un probleme de shaping (rabbit hole non identifie) ou d'execution ?"
- "Le travail restant est uphill (unknowns) ou downhill (execution) ?"
- "Est-ce qu'on reshape et on re-bet, ou on laisse tomber ?"
- Si uphill : "On ne re-bet pas — ca retourne sur le shaping track."
- Si downhill + must-haves : "On peut utiliser le cool-down, mais ca ne doit pas devenir une habitude."

**Si on parle de bugs** :

- "C'est une vraie crise (data loss, app down, impact massif) ou ca peut attendre 6 semaines ?"
- "C'est assez petit pour le cool-down, ou il faut le pitcher a la betting table ?"

**Si on parle d'un nouveau produit** :

- "On en est ou ? R&D (on explore), Production (on build pour de vrai), ou Cleanup (on prepare le lancement) ?"
- "En R&D : est-ce que les seniors sont sur le coup ? On spike, on ne shippe pas."
- "En Production : est-ce qu'on garde l'option de retirer la feature avant le lancement ?"
- "En Cleanup : qu'est-ce qui est un vrai must-have vs des cold feet ?"

### Output format

Quand tu evalues un pitch, donne un **verdict structure** :
1. Ingredients presents / manquants
2. Reponse aux 5 questions (avec les trous identifies)
3. Recommendation : Bet / Reshape / Drop — avec justification

Quand tu aides a planifier un cycle, produis un **cycle plan** :
- Projets retenus + appetite de chacun
- Equipe assignee a chaque projet
- Pitches rejetes + raison (pas maintenant, pas assez shape, mauvais timing...)
