# Testing Strategy & Quality Assurance Plan
## Smart Grievance Management Information System — Arunachal Pradesh

### 1. Multi-Tier Testing Pyramid
```
          / \
         / E2E \        (Flutter Driver / Playwright / Manual APK)
        /-------\
       /  Integ  \      (Supertest API + PostGIS Spatial Query Testing)
      /-----------\
     /    Unit     \    (Business Rules, SLA Calculators, RBAC Guards)
    /---------------\
```

---

### 2. Backend Automated Test Matrix (`backend/test/`)

#### Suite 1: Authentication & Session Verification
- `test_auth_otp_flow`: Request OTP for valid mobile $\rightarrow$ receive simulated/delivered OTP $\rightarrow$ verify $\rightarrow$ receive JWT with correct role.
- `test_auth_refresh_token`: Exchange valid refresh token for fresh access token; verify old expired token is rejected.
- `test_role_switching`: User with multiple roles (`CITIZEN` + `DEPARTMENT_OFFICER`) can switch active role; verify token payload updates.

#### Suite 2: Role-Based Access Control (RBAC) & Authorization
- `test_citizen_cannot_access_officer_routes`: Ensure Citizen JWT receives HTTP 403 when calling `/api/v1/officer/grievances`.
- `test_officer_cannot_edit_other_department`: Officer for Water Supply attempting to update an Electricity grievance receives HTTP 403.
- `test_jurisdiction_boundary_violation`: Officer assigned to Ward 1 attempting to update a grievance located in Ward 12 receives HTTP 403.

#### Suite 3: Grievance Lifecycle State Machine
- `test_valid_transition_pipeline`: `SUBMITTED` $\rightarrow$ `ASSIGNED` $\rightarrow$ `IN_PROGRESS` $\rightarrow$ `RESOLUTION_PROPOSED` $\rightarrow$ `RESOLVED` $\rightarrow$ `CLOSED`.
- `test_illegal_transition_rejection`: Direct jump from `SUBMITTED` to `RESOLVED` without assigned officer is rejected with HTTP 422 Unprocessable Entity.
- `test_resolution_requires_proof`: Transition to `RESOLUTION_PROPOSED` without resolution attachment proof is rejected.

#### Suite 4: Spatial PostGIS Queries
- `test_point_containment`: Create point within Itanagar coordinates; verify `ST_DWithin` accurately lists grievance in jurisdiction query.

---

### 3. Flutter Client Verification
- Run `flutter analyze`: Must produce **0 issues**.
- Run `flutter test`: Must pass **138/138 tests** across all 25 screens, state management providers, and mock services.
