# Department Workflow & Investigation Lifecycle Specification
## Smart Grievance Management Information System — Arunachal Pradesh

### 1. Department Operational Flow
Each civic grievance submitted by a citizen follows an operational path managed through role-based access in the Flutter app and enforced server-side.

```mermaid
flowchart TD
    SUBMITTED(["1. SUBMITTED (Citizen)"]) --> ROUTE{"System Auto-Route"}
    ROUTE -->|Dept & Jurisdiction Matched| ASSIGNED["2. ASSIGNED (Dept Field Officer)"]
    ROUTE -->|Boundary Ambiguous| UNDER_REVIEW["2b. UNDER REVIEW (Nodal Desk)"]
    UNDER_REVIEW -->|Classified| ASSIGNED
    
    ASSIGNED --> ACK["Officer Acknowledges & Reviews Evidence"]
    ACK --> IN_PROGRESS["3. IN PROGRESS"]
    
    IN_PROGRESS --> INSPECT{"Field Inspection Needed?"}
    INSPECT -->|Yes| FIELD_INSPECTION["4. FIELD INSPECTION (Site Survey)"]
    INSPECT -->|No| REPAIR["Work Execution / Repair"]
    
    FIELD_INSPECTION -->|Evidence Logged| REPAIR
    REPAIR --> PROPOSED["5. RESOLUTION PROPOSED (Proof Uploaded)"]
    
    PROPOSED --> SUPERVISE{"Senior Officer / Supervisor Review"}
    SUPERVISE -->|Approved| RESOLVED["6. RESOLVED"]
    SUPERVISE -->|Incomplete/Rejected| IN_PROGRESS
    
    RESOLVED --> CITIZEN_ACTION{"Citizen Verification (72 hrs)"}
    CITIZEN_ACTION -->|Satisfied / Timeout| CLOSED(["7. CLOSED"])
    CITIZEN_ACTION -->|Dissatisfied + Proof| REOPEN_REQ["Reopening Request"]
    REOPEN_REQ -->|Approved by Senior Officer| REOPENED["REOPENED"]
    REOPENED --> ASSIGNED
```

---

### 2. Officer Responsibilities & Capabilities

#### Level 1: Field Officer (`DEPARTMENT_OFFICER`)
- **Queue Triage:** Receives push notifications of new complaints routed to their department and assigned ward/locality.
- **Site Inspection:** Uses the mobile app on-site to record GPS-verified inspection notes and upload survey photos.
- **Investigation Remarks:** Adds internal notes for team members regarding repair estimates, required materials, or contractor coordination.
- **Resolution Proof:** Uploads mandatory photographic evidence of completed repair/work before requesting resolution.
- **Status Advancement:** Permitted transitions: `ASSIGNED` $\rightarrow$ `IN_PROGRESS` $\rightarrow$ `FIELD_INSPECTION` $\rightarrow$ `RESOLUTION_PROPOSED`.

#### Level 2: Sub-Divisional Officer / Senior Officer (`SENIOR_OFFICER`)
- **Supervisory Review:** Reviews all `RESOLUTION_PROPOSED` grievances across their sub-division or district.
- **Resolution Approval:** Approves resolution transitioning status to `RESOLVED`, or returns complaint to `IN_PROGRESS` with written rejection remarks if work is substandard.
- **Escalation Intervention:** Receives auto-escalations when field officers breach SLA warning thresholds (L1) or hard deadlines (L2).
- **Reopening Adjudication:** Reviews citizen reopening claims. If genuine, approves reopening and reassigns with priority.

#### Level 3: Department Administrator / District Magistrate (`ADMINISTRATOR`)
- **Capacity Management:** Rebalances officer workload across municipal wards.
- **Policy Tuning:** Modifies SLA hours, priority weights, and escalation warning periods.
- **System-Wide Analytics:** Audits cross-department resolution performance, recurring hotspot areas, and citizen satisfaction ratings.
