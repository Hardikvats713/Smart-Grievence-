# 08 — Antigravity implementation instructions

## First instruction
Read:
- `AGENTS.md`
- `README.md`
- `docs/00_PROJECT_OVERVIEW.md`
- `docs/01_SCOPE_AND_REQUIREMENTS.md`
- `docs/02_DESIGN_SYSTEM.md`
- `docs/03_ARCHITECTURE.md`
- `docs/04_WORKFLOW.md`

Do not start by generating all screens.

## Milestone 1 — Inspect and report
1. Inspect the repository and existing code.
2. Identify missing tools and dependencies.
3. Report the current state.
4. Propose the smallest safe implementation plan.
5. Do not overwrite existing work.

## Milestone 2 — Design foundation
Implement:
- AppColors
- AppTypography
- AppDimensions
- AppTheme
- GlassButton
- PrimaryButton
- SecondaryButton
- AppCard
- AppInput
- AppHeader
- BottomNavigation
- StatusChip
- Loading, empty and error components

Use only the exact design tokens in `docs/02_DESIGN_SYSTEM.md`.

Create a component showcase/preview screen and verify it before building feature screens.

## Milestone 3 — Citizen UI
Build one screen at a time, in this order:
1. Splash
2. Welcome/onboarding
3. Login/register
4. OTP verification
5. Profile setup
6. Permissions
7. Home
8. Category selection
9. Grievance details
10. Location
11. Review and submit
12. Confirmation
13. My grievances
14. Grievance details/timeline
15. Map
16. Profile/settings
17. Notifications

After each screen:
- Run formatter and analyzer.
- Check layout on at least one small and one large mobile viewport.
- Check loading, empty, error and success states.
- Verify all interactions.
- Compare against approved reference.
- Report deviations and wait for approval before moving to the next screen when requested.

## Milestone 4 — Backend
Implement auth, user/profile, category reference data, grievance creation, attachments, tracking, officer workflow, notifications and audit logging in small increments.

## Milestone 5 — Integration
Connect Flutter to staging API. Test permission boundaries, retries, uploads, offline/error conditions and notification behavior.

## Milestone 6 — Release preparation
Run automated tests, security checks, accessibility checks, device testing and build signing.

## Required completion report
For every task, report:
- Files created/changed.
- Functionality implemented.
- Commands and tests run.
- Test results.
- Known limitations.
- Next recommended task.

## Hard prohibitions
- Do not invent design tokens.
- Do not change approved logo or branding.
- Do not invent production data.
- Do not invent policy, department routing or escalation rules.
- Do not fake API success.
- Do not bypass server authorization.
- Do not implement excluded platform modules.
- Do not add unrequested dependencies or features.
