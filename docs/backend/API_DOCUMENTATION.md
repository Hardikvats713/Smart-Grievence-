# API Documentation (`/api/v1/`)

## Response Envelope
All `/api/v1/` endpoints return a consistent JSON envelope:
```json
{
  "success": true,
  "message": "Operation completed",
  "data": {},
  "meta": { "correlationId": "req-..." }
}
```

## Endpoint Groups
- **Auth:** `POST /api/v1/auth/send-otp`, `POST /api/v1/auth/verify-otp`, `POST /api/v1/auth/refresh`, `POST /api/v1/auth/logout`, `GET /api/v1/auth/me`, `GET /api/v1/auth/permissions`
- **Users:** `GET /api/v1/users/me`, `PATCH /api/v1/users/me`, `POST /api/v1/users/me/profile-photo`, `GET/POST /api/v1/users/me/saved-addresses`
- **Departments:** `GET /api/v1/departments`, `GET /api/v1/departments/:id/categories`, `GET /api/v1/departments/:id/jurisdictions`
- **Grievances (Citizen):** `POST /api/v1/grievances`, `GET /api/v1/grievances`, `GET /api/v1/grievances/:id`, `GET /api/v1/grievances/:id/timeline`, `POST /api/v1/grievances/:id/feedback`, `POST /api/v1/grievances/:id/reopen`
- **Officer:** `GET /api/v1/officer/dashboard`, `GET /api/v1/officer/grievances`, `POST /api/v1/officer/grievances/:id/review`, `POST /api/v1/officer/grievances/:id/progress`, `POST /api/v1/officer/grievances/:id/propose-resolution`, `GET /api/v1/officer/map/grievances`
- **Geography:** `GET /api/v1/geography/states`, `GET /api/v1/geography/districts`, `GET /api/v1/geography/jurisdictions`, `GET /api/v1/geography/nearby`
- **Analytics:** `GET /api/v1/analytics/department-summary`, `GET /api/v1/analytics/category-summary`
