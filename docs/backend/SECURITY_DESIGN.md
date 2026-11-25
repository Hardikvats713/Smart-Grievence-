# Security, Authorization & Audit Design
## Smart Grievance Management Information System — Arunachal Pradesh

### 1. Defense-in-Depth Security Model
The system enforces security at four distinct layers:

```
[Client (Flutter App)]
       │  TLS 1.3 Strict Transport Security
       ▼
[Express API Gateway] ── Rate Limiter & Helmet & CORS Origin Validation
       │
[Auth & RBAC Middleware] ── JWT Verification & User Identity Extraction
       │  Enforces Role-Based Access Control (4 Roles)
       ▼
[Jurisdiction Guard] ── Spatial & Departmental Boundary Enforcement
       │  Prevents cross-jurisdiction access (IDOR protection)
       ▼
[Database / Storage Layer] ── Parameterized Queries + PostGIS + Private Buckets
```

---

### 2. Authentication Tokens & Session Management

- **Access Token:**
  - Standard JSON Web Token (JWT) signed with HMAC-SHA256 (`HS256`).
  - Short lifetime: **15 minutes**.
  - Payload claims:
    ```json
    {
      "sub": "b2c140cb-46b5-4ff1-88f6-a94788c0353c",
      "phone": "+919876543210",
      "roles": ["DEPARTMENT_OFFICER", "CITIZEN"],
      "activeRole": "DEPARTMENT_OFFICER",
      "departmentId": "4a713916-724d-4dfb-93ff-1836545166f2",
      "jurisdictionId": "1ef9a528-98e3-4f99-a3b4-e40263f4581c",
      "iat": 1732525200,
      "exp": 1732526100
    }
    ```
- **Refresh Token:**
  - Cryptographically secure 64-character random string (`crypto.randomBytes(32).toString('hex')`).
  - Stored in `user_sessions` table as a SHA-256 hash.
  - Expiration: **30 days**.
  - Can be revoked at any time by user logout or administrator action.

---

### 3. Server-Side Authorization Enforcement
Under no circumstance does the backend trust client-supplied user IDs, roles, or department IDs:
1. `req.user` is constructed strictly from the validated JWT claims and fresh database verification.
2. If accessing citizen resources (`/api/v1/grievances/my`), the SQL query binds `WHERE citizen_id = req.user.id`.
3. If an officer performs an action on a grievance (`/api/v1/officer/grievances/:id/status`), the controller checks:
   - Does `req.user.activeRole` equal `DEPARTMENT_OFFICER` or `SENIOR_OFFICER`?
   - Does `grievance.department_id` match `req.user.departmentId`?
   - Does `grievance.location_point` fall within `req.user.jurisdictionId`?
   - If any check fails $\rightarrow$ HTTP 403 Forbidden with security audit log entry.

---

### 4. Immutable Audit Trail
Every sensitive operation writes an entry into `audit_logs`:
- State transitions
- Evidence uploads and deletions
- Role assignments and revocations
- Failed authorization attempts (suspicious IDOR attempts)
