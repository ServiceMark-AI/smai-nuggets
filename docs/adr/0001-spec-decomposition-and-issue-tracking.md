# ADR 0001: Decompose PRDs into feature-scoped GitHub issues; separate "what" from "how"

- **Status:** Accepted
- **Date:** 2026-05-02
- **Deciders:** Mike (engineering)
- **Applies to:** Everything under `docs/prd/`

## Context

The product requirement documents in `docs/prd/PRD-*.md` are dense. Each one runs 500–1100 lines, mixing operator-facing behavior, UI mockups, edge cases, design rationale, revision history, and implementation slices. When work begins, that density becomes friction:

- Engineers can't tell at a glance what's a hard contract versus a design suggestion. PRDs frequently include Lovable mockups, breakpoint hints, button copy, and color guidance — useful inspiration, but not *gates*.
- Tracking progress against a multi-thousand-word document is hard. There's no natural unit of work to assign, review, or close.
- The relationship between a feature and the PRD section it was born from rots over time. Without explicit links, the PRD drifts from the codebase and reviewers lose the trail.
- PRDs themselves are revised on a fast cadence (most carry multiple `**Patch note**` blocks already). Tying issue tracking to a frozen artifact would defeat the point.

We need a lightweight, repeatable pattern that translates a PRD into actionable, reviewable units without burying the underlying PRD or the engineer's judgment.

## Decision

For every approved PRD under `docs/prd/`, do the following:

### 1. Decompose the PRD into **feature-scoped GitHub issues**

- Use the PRD's existing **Implementation Slices** (or, where slices don't fit cleanly, the smallest reviewable feature) as the unit of decomposition. One issue per slice / feature.
- Apply a single shared `prd` label to every issue created from a PRD, and reference the PRD number in the issue title (e.g., `PRD-01 Slice A: Core job record and contact schema`). One label is enough — the PRD number lives in the title and body. Avoid per-PRD labels; they create proliferation without payoff.

### 2. In each issue, separate **the "what"** from **the "how"**

The issue body has a fixed structure:

```
## What this implements
[1–2 sentence description, plain language]

## Acceptance criteria (the "what")
- [ ] testable assertion 1
- [ ] testable assertion 2
…

## Design suggestions from the PRD (the "how" — guidance, not gates)
- design hint
- design hint

## First-pass codebase review
[unchecked observations of current state — no boxes ticked]

## PRD reference
docs/prd/PRD-XX-…md §N
```

The **acceptance criteria checklist is the only place checkboxes appear**, and every box is a behavior claim that can be verified at code-review time. Things like "place the dropdown between Search and Status," "use the existing teal palette," "44px minimum tap target" go under **Design suggestions**, not under acceptance criteria. PRDs frequently spend pages describing design; treating those pages as a pass/fail grid produces issues that fail review for the wrong reasons.

The author of the issue *does not* tick any boxes. The first-pass codebase review surfaces what already exists in the repo as context — but marking work complete is the reviewer's call, not the issue author's.

### 3. **Link issues back into the PRD, in two places**

- Add a `Tracking issues` row to the PRD's Document Meta table, listing every issue with its number, slice/feature label, and URL.
- Append `([#NN](url))` to the heading of the matching Implementation Slice (or feature subheading) in the PRD.

This means a reader of the PRD can navigate to the live tracking surface, and a reader of an issue can navigate back to the source PRD section.

### 4. The PRD stays the single source of truth for **behavior**; the issue is the single source of truth for **work status**

When an issue and the PRD disagree, the PRD wins. When the PRD is revised, existing issues either (a) absorb the change in their checklists if the change is in scope, or (b) are closed and replaced with new issues if the scope shifted. This avoids the trap of trying to keep frozen issue copies of a living PRD — they will diverge.

## Consequences

**Positive:**

- Engineers can pick up a PRD they've never read, scan the Document Meta tracking row, and see the work cleanly partitioned. They can pick up an issue without having to re-derive its scope.
- Reviewers verify a fixed checklist of behavior contracts, not a wall of design prose. Disagreements about styling don't block merge.
- The relationship between a piece of code, the issue it implements, and the PRD section it traces back to is visible at every layer.
- A single shared `prd` label plus the PRD number in the title means it is cheap to filter to PRD-derived work without an explosion of per-PRD labels.

**Negative:**

- Two places to update when a PRD is revised: the PRD itself and the issue checklists. We tolerate this because issue churn is cheaper than alternatives (e.g. tools that auto-sync from PRD).
- Issue authors must make a judgment call about what counts as a contract vs. a design suggestion. The PRD usually makes this distinction explicit (Slice headings, "Rules and Non-Negotiables" tables, "What Builders Must Not Misunderstand" sections), but borderline cases will exist.
- The "first-pass codebase review" goes stale. We accept this — it is a snapshot for the issue author's onboarding, not a contract.

**Neutral:**

- This pattern can co-exist with a future scheduled sweep that re-checks each issue against current `HEAD` and posts updated codebase observations. Not built; flagged as a possible follow-up.

## Worked example: PRD-01 v1.4.1 (Job Record)

PRD-01 defines five implementation slices (A–E). Each becomes one issue:

- *Slice A: Core job record and contact schema*
- *Slice B: Status transition engine*
- *Slice C: CTA engine (shared utility)*
- *Slice D: Field editability enforcement*
- *Slice E: Audit trail validation*

The Document Meta in PRD-01 carries a `Tracking issues` row listing all five with their issue numbers and links. Each Slice subheading in the PRD's `## 14. Implementation Slices` carries the matching issue link inline. Each issue body contains the fixed five-section structure above; the checklist focuses on behavior claims (e.g., "edits to locked fields are rejected server-side with a typed error"), and design hints from the PRD (e.g., "store CTA at query time, not as a column") sit under Design suggestions where they don't gate review.

## Alternatives considered

1. **One mega-issue per PRD.** Rejected: too large to assign, no natural unit of partial completion, can't be parallelised across engineers.
2. **One issue per acceptance-criterion bullet.** Rejected: criterion granularity is too small to be a unit of work; hundreds of issues; loses PRD-level coherence.
3. **One label per PRD (`prd:PRD-XX`).** Considered and tried initially; rejected after one round. With ~10 PRDs the labels are visual noise; the PRD number in the title is sufficient, and one shared `prd` label gives the same filterability without proliferation.
4. **GitHub Projects or Linear, with no markdown-level cross-link.** Rejected: tools change; the PRD markdown is the durable artifact and must point at the work itself.
5. **Auto-generate issues from PRD front-matter via CI.** Considered. Worth revisiting when there are 4+ PRDs reaching this stage in a single quarter; not worth the tooling investment for a one-off pass.
