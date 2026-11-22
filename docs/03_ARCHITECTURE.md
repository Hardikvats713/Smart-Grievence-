# 03 — Technical architecture

## Logical architecture

Flutter mobile app
    |
    | HTTPS / JSON REST API
    v
NestJS backend
    |-- Authentication and authorization
    |-- Citizen/profile service
    |-- Grievance service
    |-- Assignment and workflow service
    |-- Notification orchestration
    |-- Audit service
    |-- GIS query service
    |
    +--> PostgreSQL (PostGIS when spatial features are enabled)
    +--> Private object storage (evidence)
    +--> Push notification provider (FCM)
    +--> Optional Python AI service (classification suggestions)

## Responsibilities

### Flutter
- Presentation and navigation.
- Client-side form validation for usability.
- Secure token handling using platform-secure storage.
- Camera, media and location permission handling.
- API communication and user feedback.
- No authoritative workflow or authorization decisions.

### NestJS
- Authoritative business rules.
- Authentication and role-based authorization.
- Validation and persistence.
- Workflow transitions.
- Reference number generation.
- Audit events.
- Signed/private file access.
- Notification event creation.

### PostgreSQL
Proposed core entities:
- users
- roles
- user_roles
- departments
- grievance_categories
- grievances
- grievance_attachments
- grievance_assignments
- grievance_status_events
- grievance_comments
- grievance_feedback
- notifications
- escalation_rules
- audit_logs

Use migrations. Do not rely on manual production schema edits.

### AI service (optional)
- Receives minimum necessary grievance text.
- Returns category/department suggestions with confidence and explanation.
- Must not autonomously reject, close or make a final assignment without an approved human-controlled policy.
- Handle unavailable service gracefully.
- Do not send personal identifiers unless strictly required and approved.

## Trust boundaries
- Treat the mobile client as untrusted.
- Enforce access on every backend endpoint.
- Citizens may access only their own records unless an explicitly approved public view exists.
- Officers may access only records allowed by their role, department and assignment.
- Internal notes and private attachments must not be exposed to citizens.
- Validate file type, size and content; store files privately.

## Environments
- Local development
- Test/staging
- Production

Use separate databases, storage buckets, credentials and notification projects per environment.
