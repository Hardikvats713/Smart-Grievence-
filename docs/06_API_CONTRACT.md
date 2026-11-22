# 06 — API contract (proposed)

Base path: `/api/v1`

All endpoints require HTTPS outside local development. Response formats and exact DTOs must be finalized during backend implementation.

## Authentication
- POST `/auth/otp/request`
- POST `/auth/otp/verify`
- POST `/auth/refresh`
- POST `/auth/logout`

## Citizen
- GET `/me`
- PATCH `/me`
- GET `/grievances`
- POST `/grievances`
- GET `/grievances/{id}`
- POST `/grievances/{id}/attachments`
- POST `/grievances/{id}/feedback`
- POST `/grievances/{id}/reopen` (only if policy allows)

## Reference data
- GET `/categories`
- GET `/departments` (only where appropriate for client use)

## Officer
- GET `/officer/grievances`
- GET `/officer/grievances/{id}`
- POST `/officer/grievances/{id}/review`
- POST `/officer/grievances/{id}/assign`
- POST `/officer/grievances/{id}/updates`
- POST `/officer/grievances/{id}/resolve`

## Notifications and map
- GET `/notifications`
- PATCH `/notifications/{id}/read`
- GET `/map/grievances` (privacy-filtered and permission-checked)

## API conventions
- Use pagination for collections.
- Validate request DTOs server-side.
- Return stable machine-readable error codes and safe human-readable messages.
- Use idempotency keys for grievance submission and other retry-sensitive writes.
- Never expose internal notes in citizen endpoints.
- Never rely on client-supplied role claims.
- Document authentication, authorization, request/response examples and error cases with OpenAPI.
