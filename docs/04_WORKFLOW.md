# 04 — Workflows and state model

## Citizen submission
1. Citizen authenticates.
2. Selects category/subcategory.
3. Enters title and description.
4. Adds optional/required evidence according to approved policy.
5. Captures or selects location.
6. Reviews the information.
7. Submits.
8. Backend validates and persists the grievance.
9. Backend returns a unique reference number.
10. Citizen sees confirmation and can open the grievance detail screen.

If submission fails, preserve the user's draft where safe and explain how to retry. Prevent duplicate submissions using an idempotency key.

## Officer processing
1. New grievance enters the review queue.
2. Authorized officer checks completeness and relevance.
3. Officer confirms or corrects category.
4. Officer assigns department/responsible officer.
5. Investigation begins.
6. Officer records progress and evidence.
7. Officer submits a proposed resolution.
8. Citizen is notified.
9. Citizen feedback or reopening follows approved policy.
10. Closure is recorded with a complete audit history.

## Proposed state model
- SUBMITTED
- UNDER_REVIEW
- ASSIGNED
- IN_PROGRESS
- RESOLUTION_PROPOSED
- RESOLVED
- REOPENED
- REJECTED
- CLOSED

The product owner must approve the final state names and permitted transitions. Do not let clients change states directly.

## Escalation
The source concept includes Level 1 at 7 days, Level 2 at 15 days and Level 3 at 30 days. Treat these as unapproved proposed values until the authority confirms:
- Which clock starts the timer.
- Calendar days or working days.
- Whether waiting for citizen information pauses the clock.
- Which statuses pause or stop the clock.
- Which officer/authority receives each escalation.
- What happens after escalation.
- Whether each category has a different SLA.

Store rules as configuration, not hardcoded UI logic.

## Workflow invariants
- Every state transition records actor, timestamp, previous state, new state and reason.
- A grievance cannot be silently deleted to hide its history.
- A resolution must include the required outcome details and evidence according to policy.
- Reopening must preserve prior history.
- Duplicate detection may flag possible duplicates; it must not silently merge or discard complaints.
