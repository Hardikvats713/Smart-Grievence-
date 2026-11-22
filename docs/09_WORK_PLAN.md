# 09 — Work plan and delivery gates

## Recommended sequence

### Phase A — Repository and design foundation
Deliverables:
- Flutter app scaffold.
- Theme tokens and typography.
- Shared components.
- Component showcase.
- Approved logo and asset integration.

Gate A: Product owner approves component showcase.

### Phase B — Citizen experience
Deliverables:
- Onboarding and authentication UI.
- Home.
- Grievance submission.
- Tracking and detail.
- Map.
- Notifications.
- Profile.

Gate B: Citizen journey can be demonstrated end-to-end with clearly labelled mock data.

### Phase C — Backend foundation
Deliverables:
- NestJS structure.
- PostgreSQL schema and migrations.
- Authentication.
- User and category APIs.
- Grievance creation and tracking.
- File upload security.
- Audit events.

Gate C: API tests and authorization tests pass.

### Phase D — Officer workflow
Deliverables:
- Officer role access.
- Review and assignment.
- Investigation updates.
- Resolution.
- Feedback/reopening.
- Escalation configuration.

Gate D: Role-based workflow passes integration tests.

### Phase E — Intelligence and GIS
Deliverables:
- GIS queries and map filters.
- Optional AI classification suggestion.
- Duplicate-similarity suggestions.
- Human review and fallback behavior.

Gate E: AI/GIS behavior is evaluated, explainable and does not make unauthorized final decisions.

### Phase F — Hardening and release
Deliverables:
- Security review.
- Accessibility review.
- Performance testing.
- Backup/restore test.
- Production configuration.
- Signed Android/iOS builds.

Gate F: Explicit release approval.

## Work item format
Every task should state:
- Objective.
- Scope.
- Dependencies.
- Acceptance criteria.
- Files/modules expected to change.
- Tests required.
- Out-of-scope items.

Do not start a dependent task until its prerequisite gate is approved.
