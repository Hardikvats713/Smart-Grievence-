# Grievance Lifecycle & State Machine

```mermaid
stateDiagram-v2
    [*] --> SUBMITTED: Citizen submits
    SUBMITTED --> UNDER_REVIEW: Officer reviews
    SUBMITTED --> REJECTED: Invalid/Duplicate (Officer)
    UNDER_REVIEW --> ASSIGNED: Assigned to Officer
    ASSIGNED --> IN_PROGRESS: Investigation started
    IN_PROGRESS --> RESOLUTION_PROPOSED: Officer uploads proof
    RESOLUTION_PROPOSED --> RESOLVED: Senior Officer / Policy approves
    RESOLUTION_PROPOSED --> IN_PROGRESS: Returned by Senior Officer
    RESOLVED --> CLOSED: Citizen confirms or SLA auto-close
    RESOLVED --> REOPENED: Citizen requests reopen (within policy)
    REOPENED --> IN_PROGRESS: Re-assigned for action
    CLOSED --> [*]
    REJECTED --> [*]
```

## Permitted Transitions
- **Backend-Enforced:** Arbitrary status updates from the Flutter client are rejected with `400 Bad Request` or `403 Forbidden`.
- **Append-Only History:** Every transition inserts a row into `grievance_status_history` with `previous_status`, `new_status`, `changed_by`, `action_type`, and `comment`.
