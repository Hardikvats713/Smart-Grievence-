# Data Dictionary & Schema Specification
## Smart Grievance Management Information System — Arunachal Pradesh

This document provides the definitive data dictionary for all database tables, columns, constraints, foreign keys, and indexes in the Supabase PostgreSQL database.

---

### 1. Core Authentication & Identity Entities

#### Table: `roles`
Stores the system's role definitions.
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `uuid` | No | `gen_random_uuid()` | Primary Key |
| `name` | `varchar(50)` | No | - | Unique role identifier (`CITIZEN`, `DEPARTMENT_OFFICER`, `SENIOR_OFFICER`, `ADMINISTRATOR`) |
| `description` | `text` | Yes | - | Human-readable role description |
| `created_at` | `timestamptz` | No | `now()` | Record creation timestamp |

#### Table: `users`
Master user account table for citizens, officers, and administrators.
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `uuid` | No | `gen_random_uuid()` | Primary Key |
| `phone_number` | `varchar(15)` | No | - | Unique mobile phone number in E.164 format (+91XXXXXXXXXX) |
| `full_name` | `varchar(100)` | No | - | Full legal name of user |
| `email` | `varchar(255)` | Yes | - | Unique email address (optional for citizens, mandatory for officers) |
| `photo_url` | `text` | Yes | - | Supabase Storage path for user profile avatar |
| `is_active` | `boolean` | No | `true` | Account active flag |
| `is_verified` | `boolean` | No | `false` | Mobile verification flag |
| `primary_role` | `varchar(50)` | No | `'CITIZEN'` | Default active role for user |
| `created_at` | `timestamptz` | No | `now()` | Registration timestamp |
| `updated_at` | `timestamptz` | No | `now()` | Last profile update timestamp |

#### Table: `user_roles`
Composite mapping table supporting multi-role assignment.
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `user_id` | `uuid` | No | - | FK to `users.id` (ON DELETE CASCADE) |
| `role_id` | `uuid` | No | - | FK to `roles.id` (ON DELETE CASCADE) |
| `assigned_by` | `uuid` | Yes | - | FK to `users.id` who granted this role |
| `assigned_at` | `timestamptz` | No | `now()` | Role grant timestamp |
| *Constraint* | `PRIMARY KEY (user_id, role_id)` | | | Composite primary key |

#### Table: `user_sessions`
Active and historical user authentication sessions for token revocation.
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `uuid` | No | `gen_random_uuid()` | Session ID |
| `user_id` | `uuid` | No | - | FK to `users.id` |
| `refresh_token_hash` | `text` | No | - | SHA-256 hash of active refresh token |
| `device_info` | `text` | Yes | - | Device OS, Flutter app version, device model |
| `ip_address` | `inet` | Yes | - | Client IP at login |
| `is_revoked` | `boolean` | No | `false` | Revocation status flag |
| `expires_at` | `timestamptz` | No | - | Refresh token expiration timestamp |
| `created_at` | `timestamptz` | No | `now()` | Session issue timestamp |

---

### 2. Geographical Jurisdiction Entities

#### Table: `states`
Administrative state entities (Root: Arunachal Pradesh).
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `uuid` | No | `gen_random_uuid()` | Primary Key |
| `state_code` | `varchar(10)` | No | - | ISO / national state code (`AR`) |
| `state_name` | `varchar(100)` | No | - | State name (`Arunachal Pradesh`) |

#### Table: `districts`
Districts within Arunachal Pradesh.
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `uuid` | No | `gen_random_uuid()` | Primary Key |
| `state_id` | `uuid` | No | - | FK to `states.id` |
| `district_code` | `varchar(20)` | No | - | District code (e.g., `PAPUM_PARE`, `ITANAGAR`) |
| `district_name` | `varchar(100)` | No | - | District Name (e.g., `Papum Pare`, `Capital Complex Itanagar`) |
| `headquarters` | `varchar(100)` | Yes | - | District HQ town |

#### Table: `administrative_areas`
Subdivisions, circles, blocks, or wards under districts.
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `uuid` | No | `gen_random_uuid()` | Primary Key |
| `district_id` | `uuid` | No | - | FK to `districts.id` |
| `area_name` | `varchar(100)` | No | - | Area name (e.g., `Ward 1 - Ganga`, `Ward 2 - Bank Tinali`) |
| `area_type` | `varchar(50)` | No | `'WARD'` | Area type (`WARD`, `CIRCLE`, `SUBDIVISION`, `GRAM_PANCHAYAT`) |
| `boundary_polygon` | `geography(Polygon, 4326)` | Yes | - | Spatial boundary polygon for GIS boundary intersection |

#### Table: `jurisdictions`
Officer operational jurisdiction boundary entity.
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `uuid` | No | `gen_random_uuid()` | Primary Key |
| `name` | `varchar(100)` | No | - | Jurisdiction identifier (e.g., `Itanagar Capital Central Zone`) |
| `district_id` | `uuid` | No | - | FK to `districts.id` |
| `administrative_area_id`| `uuid` | Yes | - | FK to `administrative_areas.id` (null if district-wide) |
| `boundary` | `geography(MultiPolygon, 4326)` | Yes | - | PostGIS MultiPolygon boundary |

---

### 3. Department & Category Entities

#### Table: `departments`
Master record of municipal and state civic departments.
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `uuid` | No | `gen_random_uuid()` | Primary Key |
| `department_code` | `varchar(50)` | No | - | Unique system code (`WATER_SUPPLY`, `ROADS`, etc.) |
| `name` | `varchar(100)` | No | - | Display Name (e.g., `Public Health Engineering & Water Supply`) |
| `description` | `text` | Yes | - | Mandate and operational description |
| `helpline_phone` | `varchar(20)` | Yes | - | Public contact number |
| `is_active` | `boolean` | No | `true` | Operational status |

#### Table: `grievance_categories`
Master table of grievance categories and subcategories.
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `uuid` | No | `gen_random_uuid()` | Primary Key |
| `category_key` | `varchar(50)` | No | - | Unique category slug (`potholes`, `pipeline_damage`) |
| `name` | `varchar(100)` | No | - | Human readable title (`Potholes & Broken Roads`) |
| `default_priority` | `varchar(20)` | No | `'MEDIUM'` | Default priority (`LOW`, `MEDIUM`, `HIGH`, `CRITICAL`) |
| `default_sla_hours`| `integer` | No | `72` | Standard target resolution turnaround in hours |
| `icon_name` | `varchar(50)` | Yes | - | UI icon token |

#### Table: `department_categories`
Mapping binding categories directly to their responsible departments.
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `department_id` | `uuid` | No | - | FK to `departments.id` |
| `category_id` | `uuid` | No | - | FK to `grievance_categories.id` |
| *Constraint* | `PRIMARY KEY (department_id, category_id)` | | | Composite primary key |

#### Table: `officer_assignments`
Maps government officers to their department and jurisdiction scope.
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `uuid` | No | `gen_random_uuid()` | Primary Key |
| `user_id` | `uuid` | No | - | FK to `users.id` (Officer account) |
| `department_id` | `uuid` | No | - | FK to `departments.id` |
| `jurisdiction_id` | `uuid` | No | - | FK to `jurisdictions.id` |
| `designation` | `varchar(100)` | No | - | Official title (e.g., `Junior Engineer Water Supply`) |
| `officer_level` | `integer` | No | `1` | Level: 1 = Field Officer, 2 = Senior Officer/SDO, 3 = Executive Engineer |
| `is_active` | `boolean` | No | `true` | Assignment status |

---

### 4. Grievance Core & Lifecycle Entities

#### Table: `grievances`
Core civic complaint master record.
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `uuid` | No | `gen_random_uuid()` | Primary Key |
| `reference_number` | `varchar(50)` | No | - | Unique reference number `GRV-YYYY-XXXXX` |
| `citizen_id` | `uuid` | No | - | FK to `users.id` (Citizen creator) |
| `department_id` | `uuid` | No | - | FK to `departments.id` |
| `category_id` | `uuid` | No | - | FK to `grievance_categories.id` |
| `title` | `varchar(255)` | No | - | Short summary of problem |
| `description` | `text` | No | - | Comprehensive incident description |
| `location_address` | `text` | No | - | Human readable address from reverse geocoder |
| `location_point` | `geography(Point, 4326)` | No | - | PostGIS Point geometry `ST_Point(lng, lat)` |
| `latitude` | `double precision` | No | - | Cached latitude for fast client rendering |
| `longitude` | `double precision` | No | - | Cached longitude for fast client rendering |
| `district_id` | `uuid` | Yes | - | FK to `districts.id` (auto-derived via PostGIS) |
| `jurisdiction_id` | `uuid` | Yes | - | FK to `jurisdictions.id` (auto-derived via PostGIS) |
| `status` | `varchar(50)` | No | `'SUBMITTED'` | Current lifecycle status |
| `priority` | `varchar(20)` | No | `'MEDIUM'` | Severity: `LOW`, `MEDIUM`, `HIGH`, `CRITICAL` |
| `sla_deadline` | `timestamptz` | Yes | - | Computed deadline for resolution |
| `is_escalated` | `boolean` | No | `false` | SLA breach escalation flag |
| `escalation_level` | `integer` | No | `0` | Current escalation level (0=None, 1=L1, 2=L2, 3=L3) |
| `assigned_officer_id`| `uuid` | Yes | - | FK to `users.id` (Currently assigned officer) |
| `resolved_at` | `timestamptz` | Yes | - | Timestamp when proposed or marked resolved |
| `closed_at` | `timestamptz` | Yes | - | Timestamp when verified closed |
| `created_at` | `timestamptz` | No | `now()` | Submission timestamp |
| `updated_at` | `timestamptz` | No | `now()` | Last modification timestamp |

#### Table: `grievance_attachments`
Media evidence linked to grievances (initial submission or resolution proof).
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `uuid` | No | `gen_random_uuid()` | Primary Key |
| `grievance_id` | `uuid` | No | - | FK to `grievances.id` (ON DELETE CASCADE) |
| `uploaded_by` | `uuid` | No | - | FK to `users.id` |
| `storage_bucket` | `varchar(50)` | No | `'grievance-evidence'`| Supabase Storage bucket name |
| `file_path` | `text` | No | - | Storage object path |
| `file_type` | `varchar(50)` | No | - | MIME type (`image/jpeg`, `image/png`, `video/mp4`) |
| `file_size_bytes` | `bigint` | No | - | Attachment file size |
| `attachment_type` | `varchar(50)` | No | `'CITIZEN_EVIDENCE'`| Type: `CITIZEN_EVIDENCE`, `FIELD_INSPECTION`, `RESOLUTION_PROOF` |
| `created_at` | `timestamptz` | No | `now()` | Upload timestamp |

#### Table: `grievance_status_history`
Append-only immutable audit trail of grievance status transitions.
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `uuid` | No | `gen_random_uuid()` | Primary Key |
| `grievance_id` | `uuid` | No | - | FK to `grievances.id` (ON DELETE CASCADE) |
| `from_status` | `varchar(50)` | Yes | - | Previous status (null on initial creation) |
| `to_status` | `varchar(50)` | No | - | New updated status |
| `changed_by` | `uuid` | No | - | FK to `users.id` who initiated change |
| `remarks` | `text` | Yes | - | Officer or citizen remarks accompanying status update |
| `metadata` | `jsonb` | Yes | `'{}'::jsonb` | Additional contextual payload |
| `created_at` | `timestamptz` | No | `now()` | Event occurrence timestamp |

#### Table: `grievance_comments`
Investigation notes, internal remarks, and public citizen notices.
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `uuid` | No | `gen_random_uuid()` | Primary Key |
| `grievance_id` | `uuid` | No | - | FK to `grievances.id` (ON DELETE CASCADE) |
| `author_id` | `uuid` | No | - | FK to `users.id` |
| `content` | `text` | No | - | Comment text |
| `is_internal` | `boolean` | No | `false` | If true, visible ONLY to officers & admins |
| `created_at` | `timestamptz` | No | `now()` | Creation timestamp |

---

### 5. SLA, Escalation & Governance Entities

#### Table: `sla_policies`
Dynamic resolution duration thresholds.
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `uuid` | No | `gen_random_uuid()` | Primary Key |
| `department_id` | `uuid` | Yes | - | FK to `departments.id` (null = system default) |
| `category_id` | `uuid` | Yes | - | FK to `grievance_categories.id` (null = dept default)|
| `priority` | `varchar(20)` | No | `'MEDIUM'` | Severity priority level |
| `target_resolution_hours`|`integer`| No | `72` | Hours until SLA breach |
| `warning_hours` | `integer` | No | `48` | Hours until pre-breach warning alert |
| `is_active` | `boolean` | No | `true` | Policy active status |

#### Table: `escalation_records`
Logged events when an SLA threshold is breached.
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `uuid` | No | `gen_random_uuid()` | Primary Key |
| `grievance_id` | `uuid` | No | - | FK to `grievances.id` |
| `escalated_from_user`| `uuid` | Yes | - | FK to `users.id` (Officer assigned before breach) |
| `escalated_to_user` | `uuid` | Yes | - | FK to `users.id` (Senior officer receiving escalation) |
| `escalation_level` | `integer` | No | `1` | Escalation tier (1, 2, or 3) |
| `reason` | `text` | No | - | Reason (e.g., `SLA breach: 72 hours exceeded`) |
| `escalated_at` | `timestamptz` | No | `now()` | Escalation trigger timestamp |

#### Table: `audit_logs`
System-wide security and compliance event ledger.
| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | `uuid` | No | `gen_random_uuid()` | Primary Key |
| `actor_id` | `uuid` | Yes | - | FK to `users.id` (null if anonymous/failed login) |
| `actor_role` | `varchar(50)` | Yes | - | Active role during action |
| `action` | `varchar(100)` | No | - | Action identifier (e.g., `GRIEVANCE_STATUS_CHANGE`) |
| `entity_type` | `varchar(50)` | No | - | Affected table (e.g., `grievances`) |
| `entity_id` | `varchar(100)` | No | - | ID of affected entity |
| `ip_address` | `inet` | Yes | - | Request client IP address |
| `user_agent` | `text` | Yes | - | Request User-Agent header |
| `payload_before` | `jsonb` | Yes | - | State snapshot prior to change |
| `payload_after` | `jsonb` | Yes | - | State snapshot following change |
| `created_at` | `timestamptz` | No | `now()` | Audit record timestamp |
