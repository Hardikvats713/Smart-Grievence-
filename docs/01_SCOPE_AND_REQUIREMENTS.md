# 01 — Scope and requirements

## Functional requirements

### FR-01 Authentication
- Support the approved sign-in method (phone + OTP is the proposed default).
- OTP delivery and verification must use a real provider in production.
- Rate-limit OTP requests and verification attempts.
- Never store OTP values in plaintext or source control.

### FR-02 Citizen profile
- Store only necessary profile fields.
- Make optional fields clearly optional.
- Provide consent and privacy information before collecting sensitive permissions.

### FR-03 Grievance submission
Required workflow:
1. Select category and optional subcategory.
2. Enter concise title.
3. Enter issue description.
4. Attach permitted photo/video evidence.
5. Capture or select location.
6. Review all information.
7. Submit and receive a unique reference number.

The final required fields and attachment limits must be confirmed by the product owner.

### FR-04 Tracking
- List grievances belonging to the authenticated citizen.
- Show status, category, submission date and reference number.
- Detail screen shows event timeline, officer remarks visible to the citizen and permitted evidence.
- Do not expose internal-only notes.

### FR-05 Officer processing
- Review submitted grievance.
- Confirm or correct category where authorized.
- Assign department/officer.
- Record investigation updates.
- Attach progress/resolution evidence.
- Submit a resolution recommendation or outcome.

### FR-06 Citizen feedback
- Allow feedback after a grievance reaches an eligible status.
- Reopening must follow an approved policy and be recorded in the audit trail.

### FR-07 Notifications
- Notify users about relevant submission, assignment and status events.
- Push notification delivery is not the system of record; the in-app event history is.

### FR-08 Map
- Display grievances only when privacy and policy permit.
- Apply location precision controls; do not expose exact citizen addresses publicly by default.
- Support category/status filters when implemented.

### FR-09 Escalation
- Support configurable escalation thresholds and recipients.
- The source concept describes 7/15/30-day levels, but these are proposed defaults only.
- Do not activate these values until the responsible authority approves the policy, calendar rules, pause rules and recipient mapping.

## Non-functional requirements
- Secure transport (HTTPS/TLS).
- Server-side authorization for every protected operation.
- Secure private file storage.
- Audit logging for important workflow changes.
- Accessible text contrast and touch targets.
- Graceful offline/error behavior; offline submission is a later milestone unless explicitly approved.
- Pagination for lists.
- Input validation and upload validation.
- Backups, retention and deletion policies to be defined before production.
- Monitoring without logging secrets or unnecessary personal data.

## Acceptance criteria
A feature is complete only when:
- Its expected behavior is documented.
- UI loading, empty, error and success states exist.
- Server-side validation and authorization are implemented where relevant.
- Automated tests cover critical behavior.
- Manual mobile verification is recorded.
- No secrets or real personal data are committed.
