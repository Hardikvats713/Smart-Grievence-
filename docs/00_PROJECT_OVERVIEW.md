# 00 — Project overview

## Product
Smart Grievance is a mobile application through which citizens can submit civic grievances, attach evidence, provide a location, follow progress and give feedback. Authorized officers can review, assign, investigate and record resolution.

## Phase boundary
### Included
- Citizen onboarding and authentication.
- Citizen profile.
- Grievance submission with category, description, evidence and location.
- Submission acknowledgement and reference number.
- Grievance list, detail and status timeline.
- Notifications.
- Officer review, assignment, investigation and resolution workflow.
- Configurable escalation framework.
- Basic map-based grievance visualization.
- Role-based access and audit trail.

### Excluded from this phase
- Disaster Management / SOS / rescue coordination.
- Rural Development / project and budget monitoring.
- Unapproved public dashboards or unrelated modules.

## User roles
- Citizen: submit and follow own grievances; provide feedback; request reopening where policy permits.
- Department Officer: access assigned grievances; investigate; add remarks and evidence; propose resolution.
- Senior Officer: supervise permitted queues and escalations.
- Administrator: manage approved reference data, roles, departments and configuration.

Final role permissions must be approved and enforced by the backend.

## Product success criteria
- A citizen can submit a valid grievance with a clear confirmation.
- A citizen can find the current status and history of their grievance.
- An authorized officer can process only grievances within their permissions.
- Every material status/assignment action is timestamped and attributable.
- Failures are explained clearly and do not silently lose user input.
