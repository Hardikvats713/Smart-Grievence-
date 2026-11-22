# 05 — Data model (initial proposal)

This is a conceptual model, not a finalized database migration.

## User
- id (UUID)
- full_name
- phone_number (unique, normalized)
- email (nullable)
- preferred_language
- account_status
- created_at
- updated_at

## Role / Department
- roles: CITIZEN, OFFICER, SENIOR_OFFICER, ADMIN (final names subject to approval)
- departments: id, name, active
- user_roles: user_id, role_id, department_id (where applicable)

## Grievance
- id (UUID)
- reference_number (unique, non-sequential or otherwise protected from enumeration)
- citizen_id
- category_id
- title
- description
- latitude / longitude (nullable until location is captured)
- location_label (nullable)
- current_status
- submitted_at
- updated_at
- assigned_department_id (nullable)
- assigned_officer_id (nullable)

## Attachments
- id
- grievance_id
- storage_key
- media_type
- file_size
- checksum
- uploaded_by
- created_at
- scan_status

Do not store public object URLs for private evidence.

## Workflow events
- id
- grievance_id
- actor_user_id
- event_type
- previous_status
- new_status
- public_message (nullable)
- internal_note (restricted)
- created_at

## Additional entities
- grievance_categories
- grievance_assignments
- grievance_feedback
- notifications
- escalation_rules
- audit_logs

## Data rules
- Use UUIDs for internal identifiers.
- Enforce foreign keys and uniqueness.
- Store timestamps in UTC; display in the user's local timezone.
- Validate latitude/longitude ranges.
- Restrict access to phone numbers, exact locations and evidence.
- Define retention and deletion rules before production.
