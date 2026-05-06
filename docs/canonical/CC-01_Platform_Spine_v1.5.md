# ServiceMark AI Platform Spine

**Version:** v1.5
**Status:** Canonical
**Supersedes:** v1.4 (2026-03-16)
**Last updated:** 2026-04-29

---

## Table of Contents

0. ServiceMark AI: The Central Thesis
1. What ServiceMark AI Is, and Why It Exists
2. The SMAI Thesis: Managed SaaS Over DIY Automation
3. What We Refuse to Be
4. The Separation That Makes SMAI Work: Intelligence With Accountability, Then Execution
5. Job Submission and Plan Resolution: The Moment SMAI Earns Trust
6. Plan Safety and Fallback: Guardrails That Prevent Debate and Risk
7. Job as the Unit of Truth, The Event Record Behind It
8. States, Overlays, Needs Attention, and the CTA Discipline
9. Campaign Execution: Deterministic Follow-Through Once the Playbook Is Approved
10. Reply Handling: Stop Immediately, Route Clearly, Return Control to Humans
11. Delivery Failure: First-Class, Recoverable, Auditable
12. Notifications: Escalation Without Noise
13. Analytics as Proof Layer and Compounding Loop: The Substrate for Bounded Learning
14. KPI Attribution: Credible, Defensible, and Non-Political
15. Near-Term Unlocks the Architecture Already Supports
16. The Shape of the Platform: Restoration First, Multi-Vertical Long Arc
17. The Trust Contract: What "Done Right" Looks Like for SMAI

Appendix: Doctrine Atom List (Internal)

---

## 0. ServiceMark AI: The Central Thesis

Most proposal-driven businesses do not lose work because they cannot do the work. They lose work because the moment after the proposal is sent is where discipline collapses. The proposal goes out, and the job enters a fog. Someone thinks they followed up. Someone else assumes they did. The customer is busy, distracted, or uncertain. The estimator moves on to the next bid because there are always more bids. A manager asks a simple question — "where are we on this one" — and the answer is a mix of guesses and partial signals across tools that were never designed to tell the truth about revenue motion.

This is not a sales problem in the traditional sense. It is an operating problem. It is a systems problem. It is the predictable outcome of three realities that exist in almost every service business: proposals are produced quickly, the workday is fragmented, and follow-through is handled in the margins of the day by people who already have too much to do. In some workflows, the same breakdown starts even earlier, when inbound work is fragmented across calls, forms, inboxes, and legacy systems that do not produce one clean, standardized job record at the beginning of the process. SMAI starts where the operating pain is most acute and most provable today, but the deeper problem is broader than post-proposal follow-through alone.

The evidence is not abstract. You see it in every shared inbox. You see it in the way important jobs become email threads with no owner. You see it when someone says "I never saw it," and they mean it. You see it when a customer replies and the reply sits for four hours because it did not reach the right person. You see it when an email bounces and no one notices until days later. You see it when the team wins the job but cannot explain why, which means they cannot repeat it on purpose. And you see it most clearly in the jobs that go cold without a clean reason, the ones that were not truly lost, just neglected.

ServiceMark AI exists to end that fog. SMAI builds and leases AI agents to field service operators, organized into teams that own specific phases of the operator's revenue and back-office workflow. The first agent in market — the Conversion Coordinator (working title) — handles governed proposal follow-through. Additional agents extend the same job-centered, approval-first, event-driven discipline into adjacent moments. The agents do the work; the platform owns correctness, supportability, and the trust contract that keeps the work legible. Customers do not configure follow-up campaigns or maintain templates. SMAI authors the playbooks each agent runs; the operator approves them; deterministic services execute them.

This is a different promise from the dashboard, the CRM integration, or the maintained-template library. Those tools can help, but they miss the underlying failure mode. The failure mode is that follow-through is treated as a human memory task supported by brittle automation. The automation is brittle because it is generic. The memory task is fragile because it depends on the best operator in the building. The system works right up until it does not, and when it breaks, there is no record of what broke, only blame and repair.

SMAI makes a different promise: if a proposal exists, follow-through becomes a managed, auditable, disciplined system. That is the current wedge, and it is intentionally narrow because it is the fastest way to prove trust, correctness, and operational value without asking the customer to adopt a new operating universe. But the underlying problem is broader than post-proposal follow-through alone. The longer arc for SMAI is to apply the same job-centered discipline to the chaos that starts earlier and to the workflow that follows, so the system can govern intake, orchestration, interrupts, follow-through, and later job progression without abandoning the same trust boundaries that make the wedge usable in the first place.

The mistake most products make is trying to do both at the same time in the same layer. They either lean fully into automation, which creates unpredictability and distrust, or they lean fully into templates, which creates rigidity and irrelevance. SMAI is built around a more exacting separation.

In MVP and early v1, the agent's playbook is authored offline by SMAI as a versioned campaign template. The operator approves the playbook for each (job type, scenario) pair the first time that pair is used. After that, jobs of the same pair execute the approved playbook automatically — the deterministic execution layer substitutes job-specific data into operator-approved content. The boundary between intelligence and execution moves from "AI runs once at job submission" to "AI runs offline during template authoring," but the boundary itself is preserved. Intelligence creates a plan you can inspect; deterministic services run that plan without freelancing.

For Buc-ee's MVP specifically, the per-campaign approval gate ships intact — the operator still approves the campaign on each job before launch. The first-time-per-pair approval shape is an Early v2 milestone, not a Buc-ee's deliverable. CC-06 governs current Buc-ee's scope and remains unchanged on this point.

This is the central design conviction: AI is used to author better playbooks offline, not to create a less accountable system at runtime. Smart authoring, controlled execution, and defensible truth — that combination is the SMAI thesis. Not "AI for AI's sake." Not "automation everywhere."

Once execution begins, SMAI behaves like a disciplined operations engine. Emails go out when the playbook says they go out. If a customer replies, SMAI stops immediately. There is no ambiguity about whether it should send the next step. The reply is a real-world interruption, and the system treats it as decisive. The job moves into Customer Waiting, and the system surfaces it for human handling. SMAI does not pretend it can close the sale, interpret intent, or negotiate terms inside an email thread. In MVP, it does not need to. It needs to do the one thing humans routinely fail to do under load: follow through consistently until reality intervenes.

Delivery failures are handled with the same seriousness. If an email bounces, SMAI does not keep going as if nothing happened. It stops, surfaces the issue, and makes the recovery path obvious. That recovery is not buried in logs. It is not a hidden admin panel. It is a job state with a primary next action: correct the contact issue and resume. This is what separates a revenue operating system from a marketing tool. Marketing tools assume the channel works. Revenue systems assume the channel will fail sometimes, and they build recovery into the contract.

Pauses are handled similarly. If an operator pauses a job, the campaign stops and the job becomes ineligible for follow-through until the pause is lifted. SMAI does not treat pause as a soft preference. It treats pause as an explicit state, because execution discipline depends on explicit constraints. If a system is willing to "kinda keep going," it becomes untrustworthy. When revenue is on the line, ambiguity is the enemy.

All of this is powered by one more principle that is easy to say and hard to implement: system truth.

Every meaningful step in SMAI produces an event. Not for analytics theater, but because without an event record, you do not have truth. You have anecdotes. You have arguments about what happened. You have managers reconstructing timelines. You have operators defending themselves with screenshots. You have no stable input for improvement.

With an event fabric, the business can finally answer questions that matter. Did the proposal go out when we think it did. Did the customer receive it. Did the follow-through happen on time. Did we stop because the customer replied or because the system failed. Did the operator pause it. How long did it sit in Customer Waiting. How often do delivery issues occur, and where. Which playbooks outperform others for jobs of similar size and type. Those are not abstract questions. They are the difference between guessing and managing.

This is also where the platform becomes inevitable without resorting to hype. Once you have jobs, playbooks, deterministic execution, explicit interruptions, and an event record, you have a compounding loop that does not require fantasy. You can improve playbook authoring because you can measure what happened against what was approved. You can improve validation because you can see where playbooks fail and where operators consistently override. You can produce analytics that owners believe because they are grounded in a record of events, not in self-reported outcomes. And once that same spine can establish the beginning of the job with the same clarity it now brings to post-proposal follow-through, it earns the right to standardize intake, create structured job records earlier, orchestrate into systems of record, and govern adjacent workflow steps with the same auditability and operational restraint.

That compounding effect is also why SMAI can expand far beyond restoration without changing its identity. Proposal-driven work exists everywhere. Home services, commercial services, managed services, construction subs, pool installers, remodelers, specialty trades, even professional services that operate with bids and scopes. The surface details differ, but the operating shape repeats: work comes in through messy channels, a job has to become legible, a decision window opens, follow-through happens in a messy reality, and the outcome is often more random than it should be.

A system that can author job-specific follow-through playbooks against the realities of a proposal-driven business, and then execute them deterministically while capturing truth, is not a niche feature. It is a reusable operating capability. A system that can extend that same discipline to the beginning of the job and the workflow that follows, without breaking trust, is more than a follow-up feature. It is the foundation of a job-centric operating layer. That is the difference between "we have campaigns" and "we have an engine." Campaigns are assets. An engine is a discipline.

This is also why SMAI's managed posture matters. The market is full of tools that say, "you can configure it." The reality is that most businesses do not want to configure revenue-critical automation. They want it to work, stay correct, and improve over time without becoming another system they are responsible for maintaining. Managed does not mean heavy services. It means accountability. It means the platform owns the standards, the validations, the operational guardrails, and the evolution of the intelligence layer, while the customer uses a simple surface that respects their time and their workflow.

The MVP is intentionally narrow because trust is earned, not claimed. SMAI does not try to solve intake, voice, multi-channel orchestration, or autonomous negotiation in v1. It proves the core loop. Proposal in. Playbook resolved. Operator confirms. Deterministic follow-through. Explicit stop conditions. Clear CTAs. Truth captured. Performance visible. The broader platform destination matters, but it is destination logic, not permission to loosen the current wedge or overclaim present-tense scope.

If we get that right, the product becomes very hard to replace. Not because it is complicated, but because it becomes the thing that made follow-through reliable. It becomes the system that ended the fog. When a business starts trusting that proposals do not get forgotten and that the system will tell the truth about what happened, that trust becomes operational habit. Habit becomes retention. Retention becomes leverage.

The time is right for this approach for one simple reason: AI can finally make planning specific without making execution unpredictable. For the last decade, teams had to choose between generic templates or complicated automation. Generic templates did not fit the job. Complicated automation broke under real-world variance. Now we can use AI where it is strong — authoring inspectable playbooks against the messy reality of proposal-driven work — and we can keep determinism where it is essential, executing revenue motion with discipline.

What follows is the spine behind that thesis. It is written as a set of operational contracts, not as a second argument. If you want to know what SMAI does under pressure, where it draws hard boundaries, and how it stays trustworthy as volume and complexity rise, this document is the answer.

---

## 1. What ServiceMark AI Is, and Why It Exists

ServiceMark AI builds and leases AI agents to field service operators, starting with restoration. Today, the first agent in market — the Conversion Coordinator — runs proposal-to-response follow-through against operator-approved campaign templates. SMAI's contract is simple and strict: when a proposal becomes a job and the playbook is approved, follow-through becomes an operational obligation that runs the same way under pressure.

The company exists for one practical reason: once a proposal is sent, most businesses cannot reliably protect the decision window that follows, because that window is managed through memory, not through a system. The result is not dramatic failure, it is quiet leakage: follow-through becomes inconsistent, ownership becomes unclear, and the business cannot later explain what happened with confidence.

That is the wedge, and it remains intentionally narrow. But the architecture beneath it is broader than the wedge: a job-centered, approval-first, event-driven system that can later make the beginning of the job and adjacent orchestration moments as legible and governable as post-proposal follow-through, without abandoning the same trust contract. SMAI is built to separate intelligence from execution so authoring can be smart and execution can be predictable. The rest of this spine defines the boundaries that make that separation trustworthy, and the primitives that let it scale without turning into another system that depends on heroics.

---

## 2. The SMAI Thesis: Managed SaaS Over DIY Automation

A common mistake in this category is assuming that "more control" is the same thing as "more outcomes." Many tools sell automation but deliver a configuration surface, and then they silently judge the customer's competence when results are flat. That is not a moral failure on the customer's part, it is a category mismatch: most service operators are not campaign operators, and they should not have to become one to protect revenue they already earned the right to win.

In operator reality, the cost of DIY automation shows up in the seams, not in the demo. One location uses one template, another location tweaks it, a new manager arrives and changes timing, and suddenly the business cannot tell whether outcomes are driven by the work or by the tool. Under load, that "flexibility" becomes drift: the follow-up system starts behaving differently across people and locations, and the owner has no single truth to trust.

SMAI's posture is managed SaaS as strategy, not packaging. The system owns correctness, supportability, and the guardrails that keep revenue-critical behavior legible across an account and its locations. In MVP, SMAI enforces a fixed, non-configurable role model across each account and its locations: Admin has workspace-wide visibility and control, Manager operates across assigned locations and teams, and Operator can act only on the jobs they own. That managed posture also means tenancy and access are not left to customer-side configuration: the system enforces a simple organization and location hierarchy with deterministic permissions so the right people can act quickly without ever wondering whether they are seeing too much or too little. When the category is crowded with knobs, the differentiator becomes whether the product reduces operational load while staying accountable for results.

The commercial expression of this managed posture is that SMAI leases agents to operators, organized into three teams that map to the operator's revenue and back-office workflow: Sales & Revenue Recovery, Intake & Customer Communication, and Operations & Back Office Functions. Pricing is anchored to the cost savings the agent team delivers versus the human roles it replaces, not to seat counts or message volumes. The teams are the smallest commercial unit a customer can buy at that level, with the Conversion Coordinator offered as a standalone bridge agent during Sales & Revenue Recovery Team build-out. CC-04 Pricing & Packaging governs the full pricing card.

---

## 3. What We Refuse to Be

We refuse to be a general campaign tool, because general tools inevitably become debates disguised as features. The more a system invites customization, the more it invites inconsistency, and inconsistency is where trust erodes in revenue-critical flows. A business does not need another dashboard that can do anything; it needs one loop it can rely on when the week is at its worst.

In operator reality, category confusion is not academic, it is wasted time and broken expectations. If the product looks like a CRM replacement, customers ask for pipeline features and blame you for gaps that were never your job. If the product looks like a marketing system, they evaluate it with marketing standards and try to retrofit it into a service workflow. SMAI stays narrow on purpose: proposal-to-response follow-through, with disciplined execution and explicit interrupts, anchored to jobs rather than campaigns.

We also refuse to be a system that authors customer-facing content at runtime. Campaign content is templated and pre-approved offline. Runtime substitutes job-specific data into operator-approved content; it does not generate content from scratch. This is what makes the trust contract legible: the operator can read the playbook before approving it, and the playbook is exactly what the agent will run.

We refuse to expose a conversational chat interface to agents. Operator interactions with agents are structured (approve, pause, override, review). Conversational surfaces invite freelancing — both by the operator and by the agent — and freelancing is what the trust contract exists to prevent.

---

## 4. The Separation That Makes SMAI Work: Intelligence With Accountability, Then Execution

Here is the contract that makes SMAI worth trusting: intelligence produces a real artifact you can inspect, and deterministic services execute that artifact without freelancing. AI is used where it is strong, turning messy inputs into a coherent playbook and clear writing, and it is kept out of the places where unpredictability destroys confidence. If you cannot explain what the system did and why, you are not automating anything. You are just moving the confusion from people into software.

In MVP and early v1, SMAI communicates with customers through email only, so every outbound touch is deliverable, auditable, and governed by a single channel contract. The intelligence layer authors campaign templates offline, organized by job type and scenario. Each template is a versioned, inspectable playbook that defines the cadence, content, merge-field schema, and stop conditions for that (job type, scenario) pair. Templates are authored by SMAI, governed by SPEC-11 (template architecture) and SPEC-12 (authoring methodology), and activated per tenant in the SMAI admin portal.

The operator approves the playbook before any agent runs against it. In Buc-ee's MVP, approval happens per campaign on each job. In Early v2, approval happens per (job type, scenario) pair the first time that pair is used; subsequent jobs of the same pair execute the approved playbook automatically. The unit of approval changes; the principle does not. Re-approval is required when SMAI ships an updated template, when the merge-field schema changes materially, or on the operator's explicit request.

At runtime, deterministic services resolve the active template for the job's (job type, scenario) pair, substitute job-specific data into the operator-approved content, and execute. There is no AI rewriting at runtime. There are no cadence changes mid-campaign. The plan a customer receives is exactly the plan the operator approved.

Those are not convenience choices. They are the line that keeps the system understandable when the office is buried.

That separation exists because real weeks are ugly in ways no demo will ever show. Proposals are inconsistent, sometimes beautifully structured and sometimes a rushed PDF with half the detail missing. Customer situations swing from urgent to delicate, and a one-size-fits-all sequence breaks often enough that operators stop trusting it. At the same time, a system that "adapts" mid-flight creates a different fear: that it will send something the business did not intend, and that the owner will only find out after the customer reacts.

The Intelligence Layer earns the right to author a playbook by being constrained, not by being clever. That is why context packs sit inside the doctrine, not as optional enrichment, but as the governed inputs SMAI uses when authoring templates offline and when resolving job-specific data into approved content at runtime. A context pack is a published, versioned set of guidance or facts with a clear scope — proposal signals, brand voice, industry norms, deliverability rules, scenario taxonomy, sub-type briefs.

Every template must carry its receipts. When SMAI authors a template, it records which context packs were used and which versions they were, so the business can answer, later, why a cadence profile or tone choice was made. That is what turns the playbook into something you can defend, instead of something you are told to trust. If a pack is missing, stale, or low confidence, the system falls back to a safe default template instead of pretending it knows.

After playbook approval, SMAI performs no adaptive AI rewriting or cadence changes during campaign execution in MVP and early v1. SMAI halts immediately on any stop condition: a customer reply, an email bounce or delivery issue, or an operator-initiated pause. Context packs shape the playbook authored offline and the merge-field substitutions resolved at runtime, but they do not rewrite the execution contract, set outcomes, or mutate the job record after the fact. Operator transparency into running campaigns is preserved through visibility surfaces (active jobs, what each agent is doing right now, full audit trail), not through per-job approval clicks beyond the first time a (job type, scenario) pair is used.

This is also where MCP belongs in the doctrine, not as an abstract framework, but as the accountability language that keeps the system coherent as it grows. MCP is the organizing abstraction that represents jobs, messages, users, agents, events, templates, and tenant-scoped packs as contexts in one system language so you can trace what happened across authoring, approval, execution, and interrupts without stitching together folklore. When you later compound learning, the only acceptable kind is bounded recursion: improving authoring quality and validation strictness based on outcomes, not letting an agent take over revenue-critical behavior. The separation is what keeps recursion safe, because the only thing that gets smarter is the playbook, and the thing that runs stays stable.

---

## 5. Job Submission and Plan Resolution: The Moment SMAI Earns Trust

Picture the end of a long day when the office is trying to clear the last few proposals before people leave. An estimator uploads a proposal at 4:47 p.m., the admin is answering phones, and the owner is already thinking about tomorrow's crew issues. That is the moment follow-up usually becomes a mental note, and mental notes are where deals go to die quietly.

SMAI starts at job submission because that is the one moment you still have a shot at discipline before the day pulls you back into chaos. Submission begins with an uploaded proposal (or, later, with a structured intake produced by the Intake Coordinator agent). The proposal is the primary context, and the job carries the minimum fields needed for correctness and routing. SMAI first parses the proposal into a draft job shell, then the originator reviews the job shell, confirms the (job type, scenario) classification, provides any missing required information, and submits the job. The runtime resolves the active template for that (job type, scenario) pair from the operator's approved playbook library, substitutes job-specific data into the operator-approved content, and presents the resolved plan for review. The plan reflects the job the business is actually bidding because the template was authored against that scenario and the merge-field substitution makes the output specific.

The contract is that the operator always sees the plan before the system acts. The preview is not a place to tinker in MVP. It is the moment the system shows its work, so approval is a real decision, not a checkbox. Over time, this becomes the trust hinge in a world where customers have become less tolerant of generic follow-ups and operators have become less capable of writing bespoke sequences at scale, not because they care less, but because the work environment punishes attention.

---

## 6. Plan Safety and Fallback: Guardrails That Prevent Debate and Risk

One of the fastest ways to lose an owner is to send a message that invents terms, implies certainty you do not have, or applies pressure in a way that feels wrong for the situation. It only takes one bad email to turn "interesting" into "never again," because the owner is not buying novelty, they are buying protection of their reputation. When people say they fear AI, they usually mean they fear being surprised by their own system.

SMAI draws a bright line here: the intelligence layer can summarize what is in the proposal and draft clear language during template authoring, but it cannot invent discounts, timelines, availability, or outcomes it cannot guarantee. It cannot imply surveillance, and it cannot drag a customer into manipulative urgency framing that will backfire on a stressed homeowner. The validator enforces bounded schedules, including the eight-week maximum campaign length in MVP, and it rejects anything that would turn follow-through into harassment or brand risk instead of trying to "be clever" under uncertainty. If the right context pack is missing, stale, or out of scope, the system is not allowed to "wing it" to sound helpful.

Fallback is not a degraded experience, it is the safety net that keeps the product deployable when inputs are messy. If extraction confidence is low, if required fields cannot be verified, or if no template variant exists for the resolved (job type, scenario) pair, SMAI either routes the job to Needs Attention for operator handling or falls back to a safe default template variant with conservative copy that still sounds professional. The fallback rules are themselves part of the operator-approved playbook, not runtime improvisation. Operator reality is scanned PDFs, typos, missing fields, and rushed uploads. A system that cannot degrade gracefully becomes a liability the first week it is live.

---

## 7. Job as the Unit of Truth, The Event Record Behind It

The job is not a row in a database, it is the container for time and accountability. It is the customer, the scope, the proposal artifact, the playbook, the execution timeline, the interrupts, and the final outcome, all in one place so the business can answer "what happened" without guessing. When teams are lean and handoffs happen, any other unit of truth becomes a debate.

In operator reality, truth fragments immediately. The proposal lives in email, a note lives in someone's head, a reply lands in a shared inbox, and the owner assumes someone else saw it. When the business loses a deal, the postmortem is usually vague because the evidence is scattered. The job-centered model is how SMAI prevents that drift, because every state transition and every meaningful action is interpreted through the job lens.

That only works at scale if "who can see what" is as explicit as "what happened." In a multi-location org, a shared services admin needs broad visibility, a manager needs oversight across their locations, and an operator needs a clean, personal working set they can own without noise or leakage. SMAI is designed so every job and every event is scoped deliberately by account and location, with a fixed MVP role model and row-level enforcement at the data layer, not best-effort front-end filtering. The point is not security theater, it is operational clarity: the business can move fast without creating accidental cross-location exposure or brittle permission schemes that break under staff turnover.

This is where the event fabric becomes non-negotiable. Every meaningful action emits an append-only event so timelines, audits, and analytics do not depend on reconstructing intent after the fact. The event record is memory, but more importantly it is proof: who approved what playbook, what was sent, when it was delivered, when a reply arrived, and what the system did next. MCP fits here as well, because it gives you a unified way to represent the job context and its event stream so later features do not splinter into incompatible languages.

The why-now implication is not a trend, it is a staffing and attention reality. Service businesses run with less slack, and fewer people carry more responsibility across more jobs. A job that can be audited, handed off, and defended without meetings becomes a competitive advantage in itself, because it compresses operational ambiguity into an explicit record.

---

## 8. States, Overlays, Needs Attention, and the CTA Discipline

If you want a system to feel like relief, it cannot ask users to interpret it. It has to tell the truth about what is happening and what to do next, especially when the job breaks the neat story the playbook assumed. Most operational failures in follow-up are not dramatic; they are silent, and silence is what Needs Attention is designed to prevent.

In operator reality, the highest-cost mistakes look like absence. A customer replies and nobody sees it, or an email bounces and the team assumes disinterest, or the customer calls and asks for a pause and the system keeps nudging. Those are not corner cases, they are the predictable ways revenue leaks when workflows depend on human vigilance. States and overlays are how SMAI makes those conditions explicit without pretending the job advanced normally.

The operator product exposes three operational surfaces, Jobs, Needs Attention, and Analytics, and intentionally includes no Campaigns configuration UI. The Jobs surface is the system's working list and detail view for every submitted job, while Needs Attention is the interrupt-driven control tower that routes the next required human action. Needs Attention is the control tower driven by states and overlays, and the CTA discipline turns ambiguity into one next action rather than a list of possibilities. That discipline matters more as inbox chaos increases and response-time economics become harsher, because operators do not have spare cycles to diagnose why a job went quiet.

Template authoring, tenant configuration, agent activation, and OBO operations live in the SMAI admin portal — a separate surface that operators do not see. The admin portal is for SMAI internal use and tenant-administrator support flows.

---

## 9. Campaign Execution: Deterministic Follow-Through Once the Playbook Is Approved

There is the flashy kind of automation that "adapts," and there is the kind that an owner will actually trust when the office is slammed. SMAI chooses the second one, because a system that improvises midstream is indistinguishable from a system that cannot be trusted. The outcome SMAI sells is not "more touches," it is consistent follow-through that holds its shape when people cannot.

In operator reality, teams do not forget to follow up because they are indifferent. They forget because the day is a pinball machine, and follow-up only becomes "urgent" after the decision window has already cooled. Once the playbook is approved, deterministic execution removes that dependence on memory by sending what was authorized on the timeline that was authorized, while stopping immediately when real-world interrupts occur. Execution that behaves the same way given the same inputs is not an engineering preference; it is what allows an operator to let go without fear. That is the whole point of deterministic execution: it keeps its promise even when the humans cannot.

Under the templated architecture, deterministic execution means: the runtime resolves the active template version for the job's (job type, scenario) pair, substitutes job-specific merge-field data into operator-approved content, and sends. No content is authored at send time. No cadence is recomputed. The template version is locked when the playbook was approved; the job version is locked when the job was submitted; and the campaign runs against both.

---

## 10. Reply Handling: Stop Immediately, Route Clearly, Return Control to Humans

A reply is the moment the system has done its job. If the product continues sending after a customer engages, it becomes socially incompetent, and the owner will shut it off. The purpose of follow-through is to surface human moments sooner, not to replace humans in those moments.

In operator reality, reply routing is where teams stumble even when they have good intentions. Replies land in shared inboxes, the person who created the job is not always the person who owns the relationship, and managers need visibility without being forced into every thread. SMAI treats reply as an interrupt that halts execution and creates a clear next action, not as a signal to "keep going."

The rule is simple: classification routes and suggests; humans decide outcomes (Won/Lost) in MVP. Classification can recommend "ready to proceed," "pause," "question," or "wrong person," but it does not finish the story, and it does not auto-close revenue outcomes. That boundary becomes more important as AI becomes more capable, because capability without restraint invites systems to overstep, and overstepping is what turns helpful into risky.

---

## 11. Delivery Failure: First-Class, Recoverable, Auditable

If you cannot tell the difference between disinterest and non-delivery, you do not have a follow-up system, you have a false narrative generator. Delivery failure is one of the most common reasons a deal goes cold without anyone understanding why. Treating it as an edge case is how products quietly fail in production.

In operator reality, email addresses are mistyped, domains reject messages, and providers enforce deliverability constraints that operators do not think about until they get burned. When an email bounces, the business often interprets silence as rejection and changes behavior accordingly, which is the wrong lesson. SMAI makes delivery failure first-class by halting execution, surfacing the issue, and requiring an explicit fix before resuming.

This is also where event fabric earns its keep. Delivery events, bounce classifications, fixes, and resumes must be recorded as append-only truth so analytics and attribution are defensible later. Recoverable does not mean invisible; recoverable means the system tells the truth early enough for a human to salvage the decision window.

---

## 12. Notifications: Escalation Without Noise

Most products treat notifications as a feature. SMAI treats notifications as an operational cost, because every unnecessary ping teaches the user to ignore the product. A system that protects revenue cannot afford to train users into dismissal.

Operator reality is nonstop interruptions: calls, texts, adjusters, techs, vendors, and customers. If SMAI adds narration, it becomes noise, and the one alert that matters gets lost. That is why notifications are escalation without noise, and SMS is opt-in.

SMS notifications are opt-in and reserved for critical interrupts, specifically customer replies and delivery issues opened in MVP. Everything else stays in-product in Jobs and Needs Attention, because that is where context exists and where action is safest. This posture matters because attention has become the scarce resource in service operations, and systems that respect attention get adopted while systems that demand attention get disabled.

---

## 13. Analytics as Proof Layer and Compounding Loop: The Substrate for Bounded Learning

Nobody renews you because you sounded smart in month one. They renew because the product shows proof that it changed behavior and protected revenue without introducing new operational risk. Analytics is the proof layer that makes SMAI real, and it is also the substrate that allows bounded learning to compound over time without touching deterministic execution. In MVP, Analytics is a first-class surface where Admins can see system performance and failure modes directly from the job and event record, without needing an external BI tool to understand what is happening.

In operator reality, owners want to know whether follow-up discipline improved or whether they just "feel better" because they bought software. Originators want to know what to respond to and what is stuck. Managers want to see where response times lag and where delivery failures cluster, not to blame people, but to stop leakage from repeating. Without a proof layer, follow-through becomes a faith-based story that collapses under the first difficult month.

SMAI's contract is that analytics ties back to authorized playbooks and append-only events, not to fuzzy heuristics. It can answer what was approved, what was sent, what was delivered, what triggered a stop, what the next required action was, and when a human took it. That traceability is what makes attribution credible later and what prevents internal politics from rewriting reality. When playbook provenance includes the context pack versions and template version that shaped the playbook, you can improve authoring without gaslighting the operator about why the system behaved the way it did.

This is also where MCP and bounded recursion become practical rather than theoretical. MCP gives you a coherent system language for contexts and events, so analytics and later learning are grounded in the same objects the product runs on. Recursive AI, in SMAI's doctrine, is compounding understanding, not autonomous action: the system learns which playbook designs and validations correlate with faster replies and healthier outcomes, and it uses that to improve template authoring and tighten validators, not to improvise mid-campaign. When improvement is constrained to authoring and validation, you get compounding value without breaking trust.

Analytics earns its place because the decision window is getting shorter and the margin for slop is basically gone. Customers decide faster, attention is thinner, and a business that cannot see where the decision window is being lost cannot fix it. Proof turns "we think it helped" into operational truth a team can act on.

---

## 14. KPI Attribution: Credible, Defensible, and Non-Political

Attribution is where many systems lose credibility, because they claim too much or because they cannot explain their claim. If SMAI is going to be part of revenue operations, it must be able to show its work without asking for belief. Attribution has to be boring in the best way: simple, consistent, grounded, and impossible to argue with in a Monday morning meeting.

In operator reality, teams will argue about credit the second you give them an opening, especially when the month was hard and the numbers matter. The owner does not want a philosophical debate about causality; they want to know whether the product protected the follow-up window and whether it did so reliably. When attribution is vague, it becomes political, and political metrics do not survive.

SMAI's contract is that attribution is grounded in playbook provenance and telemetry. If the playbook source and authoring conditions are not met, SMAI does not claim credit, and it does not try to narrate its way into value. That credibility matters because owners are done tolerating systems that claim value but cannot show their work. If you overclaim once, they stop believing you everywhere.

---

## 15. Near-Term Unlocks the Architecture Already Supports

The MVP is intentionally narrow, but the architecture is not fragile. In the real world, the moment a team trusts follow-through, they immediately start asking for the same thing in adjacent moments: fewer handoffs, fewer "did anyone see that," fewer places where the job can drift into ambiguity. That pressure is not feature-hunger, it is operational gravity, and it is exactly why SMAI is built on stable primitives rather than a pile of one-off workflows. The near-term unlocks are credible because they extend what already exists: job as the unit of truth, a playbook as a versioned approved artifact, deterministic execution, explicit interrupts, and an append-only event record that can be audited later.

The SMAI admin portal is the most direct extension of the managed SaaS model, and it is how the platform stays reliable as usage grows. Templates, prompts, brand voice assets, deliverability rules, compliance constraints, and pack versions are controlled assets in this system, and the admin portal makes that control explicit without pushing complexity onto operators. This is also where event-level tracing becomes practical at scale: when something goes wrong, the goal is not to "debug the AI," it is to answer, quickly and confidently, what was approved, what was sent, what was delivered, and what the system did next. The posture stays the same: customers get Jobs, Needs Attention, and Analytics, while SMAI runs the operational machinery behind the scenes so outcomes stay consistent.

Scheduling via email links and proposal-building are natural next moves precisely because they can be implemented as deterministic actions that emit events, not as a new adaptive layer that changes behavior midstream. A scheduling link does not need to redefine your job statuses or violate your human authority boundary; it can create a clear, auditable signal that routes and suggests, while humans still decide outcomes in MVP terms and in early v1+. Similarly, proposal-building should be framed as a controlled transformation from structured inputs to structured outputs, with auditability and replay, so the playbook authoring layer becomes stronger because the proposal itself becomes more consistent and legible. MCP and bounded recursion matter here, but only in the way that preserves trust: MCP keeps contexts coherent across jobs, playbooks, and events, and bounded learning compounds the quality of authoring, validation, and recommended next actions without turning execution into improvisation.

The same logic also defines the next layer of credible extension. Once the system can create the job, resolve the playbook, handle interrupts, and preserve proof on one spine, adjacent workflow steps become governable in the same way. Intake standardization, structured FNOL or job creation, orchestration into systems of record, dispatch routing, customer updates, collections, PM notification, and insurance workflow coordination only belong here to the extent they remain consequences of the same architecture, not exceptions to it. They are not present-tense MVP claims. They are the next set of responsibilities the platform may earn — and the next set of agents the platform may field — only by preserving the same job-centered record, operator authority, deterministic contracts where required, and append-only proof that make the wedge trustworthy now.

---

## 16. The Shape of the Platform: Restoration First, Multi-Vertical Long Arc

A restoration operator, a pool installer, and a remodeler live in different surface realities, but the loop underneath is the same. Work comes in through messy channels, a job has to become legible, the customer decides, and the business either protects that workflow with discipline or it does not. The common thread is not email. It is the operational truth that fragmented intake, inconsistent job starts, weak orchestration, and unreliable follow-through all collapse under load unless a system holds the line.

In operator reality, the leak looks identical even when the work is not. Intake is fragmented, duplicate entry appears, handoffs are inconsistent, follow-up is missed, replies are lost, delivery fails silently, and the business blames lead quality because that is easier than admitting the system depended on memory. The teams that win are not the ones with the most complicated tooling, they are the ones that can show up consistently with professional follow-through, fast response handling, and cleaner job orchestration even when the week is chaos.

SMAI scales because the primitives do not change: the job remains the anchor, the playbook remains the operator-approved artifact, execution remains deterministic, interrupts remain explicit, and the event record remains proof. What changes across verticals is managed context, scenario taxonomy, and tone, not the workflow spine, and that is how the system avoids turning into a generic builder nobody trusts. The same rule applies to lifecycle expansion inside a vertical. Earlier and later job-stage responsibilities can be added only if they preserve the same legibility, authority boundaries, and truth layer that make the wedge trustworthy in the first place. Scale that preserves trust is slower at first and stronger later, because it does not require relearning how the product behaves every time you add an industry or a new job-stage responsibility.

For the next 6 to 12 months, restoration is the proving ground. The platform's broader vertical reach (Roofing, HVAC, Plumbing, Electrical, and adjacent proposal-driven work) remains the long arc, but it is earned by proof in restoration first, not by parallel expansion. The Servpro franchise channel, served through the RestorAI subsidiary motion, is the primary near-term go-to-market vehicle (governed by CC-07 RestorAI Brief). Direct non-Servpro restoration operators are a parallel motion on the same product. Channel and vertical expansion beyond restoration is post-Gate C and explicitly deferred, not abandoned.

The platform extension model is also clearer under the agent frame. Each new agent is a phase-owning unit that extends the spine without violating it: it consumes context packs, runs against operator-approved playbooks, executes deterministically, emits append-only events, surfaces interrupts to Needs Attention, and respects operator authority. Adding an agent is the same shape every time: define its phase, author its playbooks, integrate its surfaces, validate the trust contract, ship. The agent platform architecture document (forthcoming) governs how agents share state, surfaces, and governance without producing a Frankenstein product.

---

## 17. The Trust Contract: What "Done Right" Looks Like for SMAI

A spine document is only worth keeping if it can predict behavior under pressure. The easiest way to look smart is to describe capabilities; the harder and more valuable thing is to describe boundaries that will still hold when the product is deployed into messy reality. SMAI's trust contract is that it will do less than some tools claim, and it will do it with a level of accountability most tools avoid.

In operator reality, "done right" looks like a Tuesday when the office is slammed, proposals are flying out, and nobody has time for heroics. The product catches the moments humans miss: it resolves the operator-approved playbook for the job, demands explicit approval (per campaign in Buc-ee's MVP, per (job type, scenario) pair in Early v2), executes without drift, stops immediately when reality changes, and surfaces the next human action without interpretation. Nobody needs to remember what to do next, because the system refuses to let the most important revenue moments become invisible.

The non-negotiables are not slogans, they are the operational boundaries that keep SMAI reliable.

In MVP and early v1, SMAI communicates with customers through email only, so every outbound touch is deliverable, auditable, and governed by a single channel contract.

Campaign content is templated and operator-approved. Templates are authored offline by SMAI, organized by (job type, scenario) pair, versioned, and activated per tenant. The operator approves the template before any agent runs against it. In Buc-ee's MVP, approval happens per campaign on each job. In Early v2, approval happens per (job type, scenario) pair the first time that pair is used; subsequent jobs of the same pair execute the approved playbook automatically. Re-approval is required when SMAI ships an updated template, when the merge-field schema changes materially, or on the operator's explicit request. **The unit of approval changes between Buc-ee's and Early v2; the principle does not. Operator authority over what gets sent to their customer remains absolute.**

At runtime, deterministic services resolve the active template, substitute job-specific data into operator-approved content, and execute. SMAI performs no AI rewriting or cadence changes after the playbook is approved. SMAI halts immediately on any stop condition: a customer reply, an email bounce or delivery issue, or an operator-initiated pause. The operator can pause a single job, a scenario, or an entire agent at any time with one click.

The operator product exposes three operational surfaces: Jobs, Needs Attention, and Analytics. It includes no Campaigns configuration UI. Template authoring, tenant configuration, and OBO operations live in the SMAI admin portal, which is a separate surface that operators do not see.

Underneath those boundaries also sits the agent-as-staff frame. SMAI's agents are not autonomous; they are leased units of work that follow operator-approved playbooks the way a well-trained employee follows a documented standard operating procedure. The operator hires the agent (subscribes to the team), trains it (approves the playbook), watches it work (Jobs, Needs Attention, Analytics), and can pause it at any time. Agent identity in the operator UI (named agents, attribution on Jobs and Needs Attention) is post-Buc-ee's and is governed by the agent platform architecture document. There is no conversational chat interface to agents in the product. Operator interactions with agents are structured.

Underneath those boundaries sits the technical doctrine that keeps scale from turning into chaos. Multi-tenancy is not a bolt-on or an enterprise checkbox, it is the thing that lets a franchise group, a multi-state operator, or a shared-services model run at speed without crossing wires, because access is enforced deterministically at the job and event layer. MCP is how the system stays coherent as contexts multiply, and the event fabric is how it stays honest as volume grows, because nothing important happens without an append-only record. Recursive AI is welcomed only in its bounded form: compounding understanding that improves authoring and validation based on outcomes, without taking control of revenue-critical decisions or improvising mid-flight. If SMAI keeps that contract, "smart" becomes a multiplier rather than a risk, and the product earns the right to expand without losing the thing customers actually buy: trust under load.

---

## Appendix: Doctrine Atom List (Internal)

This Appendix is the internal-only doctrine that governs the spine. It is the invariant set of system truths, boundaries, and architectural promises that the narrative above is built on and must remain faithful to as the product evolves. If a future edit makes the prose sound better but violates any atom below, the prose is wrong.

### Core identity and posture

**DA-01.** SMAI exists to close the proposed-not-booked leak with operational reliability, not clever messaging.
*Boundaries:* SMAI is not a general campaign tool and does not lead with customization. It treats follow-through as an operational obligation that must run the same way every time under pressure. The current wedge remains narrow on purpose, while the broader platform arc is earned only by extending the same discipline into adjacent lifecycle moments and additional agents rather than by loosening the contract.

**DA-02.** Managed SaaS is the strategy, not packaging.
*Boundaries:* SMAI is simple on the surface by design and avoids pushing configuration burden onto operators. The operating model assumes SMAI owns correctness, supportability, and guardrails.

**DA-03.** Correctness first beats flexibility first in revenue-critical flows.
*Boundaries:* SMAI does not accept "power-user configurability" that creates silent failures, partial setups, or inconsistent behavior across accounts. Determinism is a trust requirement, not an engineering preference.

**DA-04.** SMAI separates intelligence from execution to stay legible and auditable.
*Boundaries:* Intelligence produces inspectable artifacts (campaign templates, scenario taxonomies, sub-type playbooks) authored offline; execution runs those artifacts without improvisation, substituting job-specific data into operator-approved content at runtime. This is a category trust constraint, not a feature choice.

### Three-layer system posture (the "how")

**DA-05.** Layer 1: deterministic services own all revenue-critical behavior.
*Boundaries:* state transitions, stop conditions, delivery failure handling, and the "next action" discipline never depend on probabilistic decisions. Given the same inputs, the system behaves the same way.

**DA-06.** Layer 2: the intelligence layer authors campaign templates and playbooks offline; runtime template resolution and merge-field substitution are deterministic.
*Boundaries:* the intelligence layer does not run mid-campaign and does not run at job submission to author content from scratch. Templates are authored, versioned, and activated offline. At job submission, deterministic services resolve the active template for the job's (job type, scenario) pair and substitute job-specific data into operator-approved content. Its output is a structured, inspectable playbook reviewed by the operator before activation.

**DA-07.** Layer 3: deterministic execution runs only after human authorization and follows the playbook exactly.
*Boundaries:* no unapproved sending, no "helpful" midstream adjustments, and no silent deviations. Execution halts on real-world interrupts.

### Job, plan, and lifecycle primitives

**DA-08.** The job is the unit of truth and the container for time.
*Boundaries:* messages, replies, overlays, and outcomes are interpreted through a job lens. Earlier and later lifecycle actions may only be added if they attach to the same job truth rather than creating parallel records. This prevents operational ambiguity when workloads spike and handoffs happen.

**DA-09.** The job-specific plan is the resolved template + job-specific merge-field data, locked at submission and attached to the job as a durable artifact.
*Boundaries:* plans are derived from the operator-approved template (versioned, activated per tenant per (job type, scenario) pair) plus the proposal and job context (resolved into merge-field substitutions). The resolved plan becomes the durable artifact attached to the job. This is what makes attribution and audit possible.

**DA-10.** Plan resolution happens once at job submission; templates are authored offline and approved before activation.
*Boundaries:* the system resolves the active template at submission time, substitutes job-specific data, and locks the resolved plan to the job. It does not re-resolve or re-author mid-flight. Template authoring is an offline activity governed by SPEC-11 and SPEC-12; template activation per tenant is governed by PRD-10 (admin portal). This preserves causality and prevents the "moving target" effect in support and analytics.

**DA-11.** Maximum campaign length is capped and enforced (8 weeks in MVP).
*Boundaries:* the playbook validator rejects schedules that violate the cap. This constrains risk, keeps follow-through culturally acceptable, and prevents "automation that never ends."

### Operator control and outcome authority

**DA-12.** No customer-facing message is sent without operator-approved content.
*Boundaries:* every outbound message resolves to operator-approved template content. The operator approves the playbook before any agent runs against it. In Buc-ee's MVP, approval happens per campaign on each job. In Early v2 and beyond, approval happens per (job type, scenario) pair the first time that pair is used; subsequent jobs of the same pair execute the approved playbook automatically. Re-approval is required when SMAI ships an updated template, when the merge-field schema changes materially, or on the operator's explicit request. The unit of approval evolves; operator authority over what gets sent to their customer does not. The system must be able to answer, via the event record, what content was approved by whom and when, and which approved template version any sent message was resolved from.

**DA-13.** Classification routes and suggests; humans decide outcomes (Won/Lost) in MVP.
*Boundaries:* reply classification may recommend an outcome but cannot auto-close the job as Won or Lost. Outcome changes remain an operator act, recorded as such.

**DA-14.** The system is allowed to halt; it is not allowed to "finish the story."
*Boundaries:* SMAI stops on interrupts and makes them explicit. It does not silently infer closure or push a job into a terminal state without a human action.

### Stop conditions, delivery, and interrupts

**DA-15.** Stop conditions are first-class and immediate: reply, bounce/delivery issue, pause.
*Boundaries:* the system must halt execution and surface the interruption with a clear next action. No further touches occur while an interrupt is active.

**DA-16.** Delivery failure is recoverable, auditable, and treated as operational truth, not an edge case.
*Boundaries:* delivery failure is not a "log line"; it is a surfaced condition that pauses execution and requires explicit handling. The event fabric is the proof of what happened.

### Surfaces and UX boundaries

**DA-17.** The operator product exposes three operational surfaces: Jobs, Needs Attention, Analytics. The SMAI admin portal is a separate surface that operators do not see.
*Boundaries:* the operator product exposes no Campaigns configuration UI. Template authoring, tenant configuration, agent activation, and OBO operations live in the SMAI admin portal (governed by PRD-10). The admin portal is for SMAI internal use and tenant-administrator support flows. Operators interact only with Jobs, Needs Attention, and Analytics.

**DA-18.** Needs Attention is the operational control tower, driven by states and overlays.
*Boundaries:* the system expresses "what is true" and "what needs action" without creating parallel workflows. Overlays clarify interrupts without rewriting the underlying lifecycle.

### Context packs and bounded intelligence

**DA-19.** Context packs are managed assets with schemas, provenance, TTL, and influence boundaries.
*Boundaries:* packs are not free-form prompt stuffing; they are controlled inputs with explicit lifetimes and documented effects on template authoring and validation.

**DA-20.** Packs may shape selection and framing; packs do not get to invent promises or set specific dates.
*Boundaries:* packs influence cadence profile choice and tone but cannot directly generate commitments. This is how "smarter" does not become "riskier."

**DA-21.** Public-only external data posture in v1.
*Boundaries:* any enrichment is constrained to public sources and handled through the same managed-asset discipline, with clear provenance.

### Event fabric, auditability, and proof

**DA-22.** Every meaningful action emits an append-only event (event fabric).
*Boundaries:* the event record is not optional and not reconstructive. It powers timelines, audits, downstream automation, and later learning. Nothing important happens silently.

**DA-23.** The event fabric is memory, but more importantly, it is proof.
*Boundaries:* the platform must answer operational questions precisely (authorization, send time, delivery, reply, next system action) without guesswork. This is essential for trust and renewals.

**DA-24.** The event taxonomy defines payload minimums and state-machine mapping.
*Boundaries:* events are not "whatever engineering logs"; they are contractual records with known fields that enable analytics and defensible attribution.

### MCP and recursive AI (bounded learning)

**DA-25.** MCP is the organizing abstraction: contexts, events, agents, templates, playbooks.
*Boundaries:* jobs, contacts, campaigns, messages, users, agents, and operator-approved playbooks are represented as contexts in a unified system language. Agents are first-class entities; templates are versioned context; playbooks are the operator-approved bound between an agent and the templates it runs. This is the coherence mechanism across features, verticals, and the agent fleet.

**DA-26.** Recursive AI is compounding understanding, not autonomous action.
*Boundaries:* recursion means observing outcomes via structured immutable context and improving recommendations, validation, and authoring quality without taking control of revenue-critical decisions.

**DA-27.** Improvement occurs through better template authoring and stricter validation, not in-flight improvisation.
*Boundaries:* the system compounds value by learning which playbook designs work, while execution remains deterministic and stable.

### Notifications posture

**DA-28.** Notifications are escalation without noise, and SMS is opt-in.
*Boundaries:* SMS is reserved for critical interrupts only, specifically customer reply and delivery issue opened in MVP. Everything else stays in-product.

### Analytics and attribution doctrine

**DA-29.** Analytics is the proof layer that converts behavior into defensible truth.
*Boundaries:* analytics must tie back to authorized playbooks and events, not to fuzzy heuristics. It is what allows internal accountability and external credibility.

**DA-30.** Attribution must be credible and non-political because it is grounded in playbook provenance and telemetry.
*Boundaries:* attribution never depends on narrative negotiation. If the playbook source and authoring conditions aren't met, SMAI does not claim credit. This stays simple and defensible.

### Platform scaling boundaries

**DA-31.** Vertical scale comes from stable primitives + managed context + operator-approved playbooks per (job type, scenario) pair, not from a new workflow per industry.
*Boundaries:* differences across industries are handled as context, tone, urgency, scenario taxonomy, and buying behavior, while the job/plan/execution spine remains unchanged. The same principle governs lifecycle expansion inside a vertical and agent-fleet expansion within an operator: earlier and later moments may be added (and additional agents may be leased) only if they preserve the same spine.

**DA-32.** Near-term unlocks must be consequences of the architecture, not speculative feature lists.
*Boundaries:* extensions like scheduling links, structured job creation, or adjacent orchestration steps are acceptable only if they update job state, emit events, and preserve the deterministic execution engine and trust boundary where those are required.

### Agent platform doctrine (new in v1.5)

**DA-33.** SMAI builds and leases AI agents organized into teams; each agent owns a phase, runs against operator-approved playbooks, and respects the trust contract.
*Boundaries:* agents are not autonomous. They run authored playbooks, executed deterministically, with operator authority preserved at every layer. The current agent fleet is restricted to the Conversion Coordinator (live), with additional agents earned by repeatability and the agent platform architecture (forthcoming). Multi-agent team views and agent identity in the operator UI are post-Buc-ee's. There is no conversational chat interface to agents in the product.

### Templated content architecture (new in v1.5)

**DA-34.** Campaign content is templated and operator-approved; runtime is deterministic.
*Boundaries:* SMAI authors templates offline (SPEC-11, SPEC-12), organized by (job type, scenario) pair, versioned, and activated per tenant in the admin portal (PRD-10). Operators approve playbooks before agents run against them. Runtime resolves the active template version for the job's pair and substitutes job-specific merge-field data into operator-approved content. There is no AI content generation at runtime. There is no AI rewriting after approval. The fallback path is itself part of the authored template set, not runtime improvisation.

### Restoration-first sequencing (new in v1.5)

**DA-35.** Restoration is the active GTM scope for the next 6 to 12 months; broader vertical reach is the long arc.
*Boundaries:* active GTM and product investment is restoration-first. The Servpro franchise channel, served through the RestorAI subsidiary motion (CC-07), is the primary near-term go-to-market vehicle. Direct non-Servpro restoration operators are a parallel motion on the same product. The four other spine verticals (Roofing, HVAC, Plumbing, Electrical) and channels beyond Servpro / direct-restoration are deferred to post-Gate C, not abandoned. Channel and vertical expansion is earned by proof in restoration.

---

**Change control:** Any update to these atoms requires an explicit version bump to this Appendix and a short written rationale for what changed and why. If the Appendix and the body ever conflict, the Appendix governs, and the body must be revised until it matches.

---

## Document Control

- **Document name:** ServiceMark AI Platform Spine
- **Document ID:** CC-01
- **Version:** v1.5
- **Status:** Canonical
- **Supersedes:** v1.4 (2026-03-16)
- **Owner:** ServiceMark AI leadership team (Kyle, Ethan, Mark)
- **Last updated:** 2026-04-29
- **Change summary:** Templates pivot, approval shape direction (with Buc-ee's per-campaign gate preserved through Early v2), agent-as-staff frame, restoration-first sequencing, RestorAI motion, team-based pricing posture, admin portal as separate surface
- **Atom changes:** DA-04, DA-06, DA-09, DA-10, DA-12, DA-17, DA-25, DA-31 amended. DA-33, DA-34, DA-35 added. No atoms deleted.
- **Triggers:** Per CP-02 §12, this CC-01 update triggers review of CC-02, CC-03, CC-04, CC-05, CC-06 (no change expected), and the Canonical Index. CC-07 RestorAI Brief is a new canonical document authored alongside this update.
- **Source:** Edit register (CC-01 v1.5 Surgical Edit Register, 2026-04-29) approved by Kyle.
