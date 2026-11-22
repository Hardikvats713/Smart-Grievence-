# 10 — Test strategy

## Flutter
- Unit tests for validators, formatters and state logic.
- Widget tests for shared components and screen states.
- Navigation tests.
- Form validation tests.
- Accessibility and layout checks.
- Integration tests for critical citizen journey.

## Backend
- Unit tests for business rules.
- Integration tests for repositories and database transactions.
- API tests for authentication and authorization.
- Workflow transition tests.
- Upload validation tests.
- Idempotency and duplicate submission tests.
- Audit event tests.

## Critical scenarios
1. Citizen submits a valid grievance.
2. Invalid grievance is rejected with field-level guidance.
3. Network failure does not falsely show success.
4. Retry does not create duplicate grievances.
5. Citizen cannot access another citizen's grievance.
6. Officer cannot access an unauthorized department's grievance.
7. Citizen cannot call officer-only endpoints.
8. Internal notes are not returned to citizen endpoints.
9. Resolution and reopening preserve history.
10. Escalation follows approved configuration.
11. Private attachments cannot be accessed without authorization.
12. Map output follows location privacy rules.

## Release rule
No critical or high-severity unresolved security issue may be accepted without documented risk approval.
