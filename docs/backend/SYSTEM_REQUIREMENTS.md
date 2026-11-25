# System Requirements Specification (SRS)
## Smart Grievance Management Information System — Arunachal Pradesh

### 1. Document Control
- **Project:** Smart Grievance (Arunachal Pradesh Civic Services)
- **Version:** 1.0.0-PROD
- **Classification:** Public Sector Digital Governance Infrastructure
- **Target Audience:** System Architects, Backend Engineers, DevOps, Administrative Officers, Academic Evaluators

---

### 2. Functional Requirements (FR)

#### FR-1: Citizen Management & Self-Service
- **FR-1.1:** Citizen authentication via Mobile Number and Time-Based One-Time Password (OTP) with rate limiting (max 3 attempts per 5 minutes per IP/phone).
- **FR-1.2:** Profile creation & editing with Full Name, Phone Number, Email (optional), District, Ward/Locality, and Profile Picture.
- **FR-1.3:** Address Book allowing citizens to persist up to 5 frequently used incident addresses with custom labels (Home, Work, Relative).
- **FR-1.4:** Grievance Submission containing Department Category, Subcategory, Incident Title, Detailed Description, Geospatial Location (Latitude, Longitude, Reverse Geocoded Address), and up to 5 media evidence attachments (Photos/Videos).
- **FR-1.5:** Generation of human-readable, cryptographically non-guessable Grievance Reference Numbers format `GRV-{YYYY}-{DISTRICT_CODE}-{SEQ_NO}`.
- **FR-1.6:** Real-time Grievance Tracking displaying the append-only lifecycle milestone timeline, assigned officer designations, and estimated SLA resolution time.
- **FR-1.7:** Citizen Post-Resolution Feedback: Citizen must be prompted to rate resolution quality (1 to 5 stars) and provide satisfaction comments within 7 days of resolution.
- **FR-1.8:** Grievance Reopening Request: If dissatisfied, citizen may submit a reopening request within 72 hours of closure, mandating justification remarks and new photo proof.

#### FR-2: Department Management & Category Routing
- **FR-2.1:** Master data maintenance for 7 core departments: Water Supply (`WATER_SUPPLY`), Electricity (`ELECTRICITY`), Roads (`ROADS`), Sanitation (`SANITATION`), Education (`EDUCATION`), Healthcare (`HEALTHCARE`), and Other Services (`OTHER_SERVICES`).
- **FR-2.2:** Dynamic database-driven mapping between Grievance Categories, Subcategories, and responsible Government Departments.
- **FR-2.3:** Configurable department contact points, nodal officer assignments, and escalation hierarchy per administrative division.

#### FR-3: Geographical Hierarchy & Jurisdiction Boundary Access
- **FR-3.1:** 4-tier spatial hierarchy: State (`AR`) $\rightarrow$ District (e.g., Papum Pare) $\rightarrow$ Administrative Subdivision (e.g., Itanagar Capital Complex) $\rightarrow$ Ward/Gram Panchayat.
- **FR-3.2:** PostGIS-backed coordinates (`geography(Point, 4326)`) and polygonal boundary representation (`geography(Polygon, 4326)`).
- **FR-3.3:** Automatic spatial containment calculation: Submitting a coordinate automatically determines the enclosing District, Subdivision, and Ward.
- **FR-3.4:** Jurisdiction Access Control: Department Officers and Field Inspectors can query and modify *only* grievances whose coordinates fall inside their assigned geographical jurisdictions.

#### FR-4: Officer Workflow & Investigation Management
- **FR-4.1:** Multi-role dashboard filtering by assigned jurisdiction, department queue, SLA status (Normal, Nearing Breach, Breached), and Priority.
- **FR-4.2:** Internal Investigation Log: Department officers can add timestamped internal remarks and field inspection notes visible only to authorized department and supervisory personnel.
- **FR-4.3:** Field Inspection Logging: Capture field visit date, inspection team lead, site observations, and field verification photographs.
- **FR-4.4:** Resolution Submission: Mandate closure remarks, resolution action summary, cost of repair (optional), and mandatory before/after visual proof.
- **FR-4.5:** Senior Officer Supervisory Oversight: Review proposed resolutions, approve closure, or reject resolution back to `IN_PROGRESS` with specific rework directives.

#### FR-5: Service Level Agreements (SLA) & Automated Escalation
- **FR-5.1:** Dynamic SLA policies defined per Department, Category, and Severity Priority (LOW: 120 hrs, MEDIUM: 72 hrs, HIGH: 48 hrs, CRITICAL: 24 hrs).
- **FR-5.2:** Automated background evaluator monitoring grievance age against target resolution deadlines.
- **FR-5.3:** 3-tier Escalation Hierarchy:
  - **Level 1 (Warning):** When 75% of SLA has elapsed, notify Department Officer and Section In-Charge.
  - **Level 2 (Breach - Senior Officer):** At 100% of SLA elapsed without resolution, escalate to District Senior Officer.
  - **Level 3 (Severe Breach - District Magistrate / Admin):** At 150% elapsed, escalate to District Magistrate / System Administrator.

#### FR-6: Audit Trails & Governance Compliance
- **FR-6.1:** Immutable audit log table recording every state transition, assignment change, internal remark, media upload, and authorization violation attempt.
- **FR-6.2:** Capture Actor User ID, Actor Role, Client IP Address, User Agent, Action Verb, Old State, and New State in JSONB format.

---

### 3. Non-Functional Requirements (NFR)

#### NFR-1: Performance & Scalability
- **NFR-1.1 Response Latency:** 95th percentile (P95) API response time < 250ms for read queries and < 500ms for multipart uploads and spatial joins.
- **NFR-1.2 Throughput:** Support 1,000 concurrent active users and up to 50 grievance submissions per minute under peak monsoon flood/landslide conditions.
- **NFR-1.3 Database Indexing:** Spatial indexing (`GIST` index) on PostGIS location columns; B-tree indexes on foreign keys, composite status filters `(department_id, status)`, and user phones.

#### NFR-2: Security & Privacy
- **NFR-2.1 Transport Layer:** All client-server communication strictly over TLS 1.3 with HSTS enabled.
- **NFR-2.2 Authentication Tokens:** Short-lived JWT Access Tokens (15-minute expiry) and cryptographically random, revocable Refresh Tokens (30-day expiry stored hashed in DB).
- **NFR-2.3 Authorization Enforcement:** Server-side verification of Role, Department, and Jurisdiction on every single request. Never trust client claims.
- **NFR-2.4 Media Isolation:** Media stored in private Supabase Storage buckets. Access strictly mediated via time-limited signed URLs (valid 15 minutes).
- **NFR-2.5 PII Protection:** Citizen phone numbers and emails masked in public and officer-facing timeline views unless explicit citizen contact authorization is granted.

#### NFR-3: Reliability & Availability
- **NFR-3.1 High Availability:** 99.9% uptime target with automated failover provided by cloud managed PostgreSQL.
- **NFR-3.2 Disaster Recovery:** Automated daily full database backups with 7-day point-in-time recovery (PITR).
- **NFR-3.3 Graceful Degradation:** Local offline caching in the Flutter client using SQLite/SharedPreferences for offline drafts and incident tracking.

#### NFR-4: Interoperability
- **NFR-4.1 API Standards:** RESTful API complying with OpenAPI 3.0 specification, standard JSON envelopes `{ success, message, data, meta }`, and semantic HTTP status codes (200, 201, 400, 401, 403, 404, 409, 422, 500).
- **NFR-4.2 Notification Integration:** Multi-channel alerting via Firebase Cloud Messaging (FCM) push notifications and SMS gateway webhooks.
