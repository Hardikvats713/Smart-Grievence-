# 07 — Security and privacy requirements

## Authentication
- Use a reputable OTP provider or approved identity provider.
- Rate-limit OTP request and verification endpoints.
- Use short-lived access tokens and controlled refresh-token rotation.
- Store tokens in platform-secure storage.
- Never log OTPs, tokens or secrets.

## Authorization
- Enforce role and resource-level authorization on the backend.
- Citizen: own grievance records only.
- Officer: assigned/department scope only, as approved.
- Senior officer/admin: only approved elevated permissions.
- Test direct API access, not only UI visibility.

## Evidence uploads
- Private object storage.
- Allowlisted media types.
- Size and count limits configurable by policy.
- Verify actual file content, not only extension.
- Malware scanning where available.
- Strip unnecessary EXIF metadata before public display.
- Use short-lived signed access URLs.
- Never expose private evidence through guessable public paths.

## Location privacy
- Request location only when needed and explain why.
- Allow manual location selection where feasible.
- Do not publish exact citizen coordinates by default.
- Define map aggregation and location precision rules.

## Privacy
- Collect only necessary information.
- Provide a privacy notice and consent where required.
- Define retention, deletion, access and correction policies.
- Avoid sensitive personal data in analytics and logs.

## Audit
Record important actions:
- Authentication events (without secrets).
- Grievance creation.
- Assignment changes.
- Status transitions.
- Officer remarks and resolution events.
- Permission and configuration changes.

Protect audit logs against unauthorized modification.

## Production readiness
Complete threat modeling, dependency scanning, security testing, backup/restore testing and privacy review before production.
