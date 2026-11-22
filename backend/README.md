# NestJS backend

Recommended feature modules:
- auth
- users
- roles
- departments
- categories
- grievances
- attachments
- assignments
- workflow
- notifications
- gis
- audit

Each module should separate controller, service, DTO, entity/repository and tests.

Requirements:
- DTO validation.
- Authentication guards.
- Resource-level authorization.
- Database migrations.
- OpenAPI documentation.
- Structured safe logging.
- Centralized error handling.

Do not put business logic in controllers.
Do not trust role or user IDs supplied by the client.
