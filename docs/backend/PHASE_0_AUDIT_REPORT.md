# Phase 0 — Existing System Audit Report

## 1. Executive Summary
This audit evaluates the current state of the **Smart Grievance** repository (`SMART-GRIEVANCE-READY`) across the Flutter mobile/web client, Node.js/Express backend, and Supabase PostgreSQL configuration against the target enterprise specification.

---

## 2. Existing Working Modules
- **Flutter Client (`mobile/`):**
  - All 25 citizen screens implemented and routed (`splash`, `onboarding`, `auth`, `permissions`, `profile`, `home`, `grievances`, `notifications`, `how_it_works`).
  - Clean service abstractions (`AuthController`, `ProfileController`, `GrievanceService`, `NotificationController`).
  - Camera/Gallery media pickers (`image_picker`), local persistence (`SharedPreferences`), interactive Google Maps (`SmartGoogleMapView`), GPS (`geolocator`), and debounced address autocomplete (`PlacesService` with OpenStreetMap Nominatim fallback).
  - Automated verification: `flutter analyze` (0 issues), `flutter test` (138/138 passed).
- **Backend API (`backend/`):**
  - Node.js + Express (`backend/src/server.js`) running on port 3000 with `cors`, `jsonwebtoken`, `@supabase/supabase-js`, and `dotenv`.
  - Basic endpoints operational: `/api/health`, `/api/auth/send-otp`, `/api/auth/verify-otp`, `/api/profile`, `/api/grievances`, `/api/grievances/nearby`, `/api/grievances/:id/feedback`, `/api/grievances/:id/reopen`, `/api/notifications`.
  - Automated verification: `npm test` (4/4 passed).
- **Supabase Configuration:**
  - `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, and `SUPABASE_SECRET_KEY` configured in gitignored `backend/.env`.
  - Initial draft schema created at `backend/supabase/schema.sql`.

---

## 3. Partially Implemented & Missing Modules (Gap Analysis)
1. **API Versioning & Envelope:**
   - Current routes are under `/api/...` instead of `/api/v1/...` with standardized `{ success, message, data, meta }` envelopes and request correlation IDs.
2. **Role-Based Access Control (RBAC):**
   - Missing `roles`, `user_roles`, `user_sessions` (refresh-token rotation), and server-side RBAC middleware for `CITIZEN`, `DEPARTMENT_OFFICER`, `SENIOR_OFFICER`, and `ADMINISTRATOR`.
3. **Department & Category Management:**
   - Missing `departments` and `department_categories` tables; routing is not yet database-driven.
4. **Geographical Jurisdiction & PostGIS:**
   - Missing `states`, `districts`, `administrative_areas`, `jurisdictions` (PostGIS `geography(Point, 4326)` / polygon boundaries), and `officer_assignments`.
5. **Normalized Grievance Schema & Lifecycle:**
   - Current `schema.sql` uses `text` primary keys instead of `UUID`, stores `attachments`/`timeline` in JSONB rather than `grievance_attachments` and append-only `grievance_status_history`, and lacks `grievance_comments`, `grievance_assignments`, `sla_policies`, `escalation_records`, `audit_logs`, `feedback`, `reopen_requests`, `saved_addresses`, and `notification_preferences`.
   - Tables have not yet been applied in the live Supabase SQL Editor (`GET /api/grievances` returns 500).
6. **Private Media Storage:**
   - Missing Supabase Storage private bucket upload pipeline with MIME/size validation and short-lived signed URLs.
7. **Officer & Admin Flutter Screens:**
   - Flutter app currently only has Citizen screens; role-based routing to Department Officer, Senior Officer, and Admin dashboards is not yet implemented.
8. **Flutter-to-Backend Wiring:**
   - Flutter controllers still use local stubs (`StubGrievanceService`, `StubAuthController`, `StubProfileController`) rather than calling `/api/v1/...`.

---

## 4. Security Weaknesses Identified
- Dev OTP is hardcoded (`123456`) without expiry, attempt limits, or rate limiting.
- `authenticate` middleware currently falls back to a default phone number if no `Bearer` token is provided.
- Profile photos are stored as `photoBase64` strings instead of private Supabase Storage object references.
- No rate limiting, Helmet headers, or audit logging middleware.

---

## 5. Next Phase
Proceed to **Phase 1 — Architecture & Database Design** (`docs/backend/` documentation, Mermaid diagrams, OpenAPI spec) and **Phase 2 — Normalized Supabase SQL Migrations**.
