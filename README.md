# Smart Grievance

A mobile-first public grievance submission and redressal platform.

**Current phase:** Smart Grievance only. Disaster Management and Rural Development modules are out of scope.

## Product principles
- Citizen-first, simple reporting and tracking.
- Role-based officer workflows.
- Transparent status history and escalation.
- Accessible, responsive Flutter mobile UI.
- Consistent warm-ivory / deep-teal design system.
- Glassmorphism used selectively on interactive controls.

## Repository map
- `mobile/` — Flutter Android/iOS application.
- `backend/` — NestJS REST API and workflow services.
- `ai-service/` — Python/FastAPI classification service (optional integration).
- `infrastructure/` — local development and deployment configuration.
- `docs/` — product, architecture, API, security, workflow and build documentation.
- `design/` — approved references, tokens and asset guidance.

## Getting started
Read these in order:
1. `docs/00_PROJECT_OVERVIEW.md`
2. `docs/01_SCOPE_AND_REQUIREMENTS.md`
3. `docs/02_DESIGN_SYSTEM.md`
4. `docs/03_ARCHITECTURE.md`
5. `docs/04_WORKFLOW.md`
6. `docs/08_ANTIGRAVITY_INSTRUCTIONS.md`

This repository is a structured project scaffold and implementation specification. It does not claim that production authentication, APIs, database migrations, AI models or deployment have already been implemented.

## Technology baseline
- Mobile: Flutter / Dart
- Backend: Node.js / NestJS / TypeScript
- Database: PostgreSQL (+ PostGIS when GIS queries are implemented)
- AI service: Python / FastAPI (optional, separately deployable)
- Push notifications: Firebase Cloud Messaging (FCM), subject to platform setup
- File storage: private object storage, selected during deployment

## Important implementation rule
Do not invent policy rules, departments, SLA durations, escalation authorities, legal text or production data. Keep policy-driven values configurable and obtain approval from the project owner.
