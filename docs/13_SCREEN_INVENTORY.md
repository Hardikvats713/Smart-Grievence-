# 13 — Screen inventory

This is the approved citizen-side screen inventory. Implement one screen at a time. Screen details and business rules must follow the requirements and workflow documents.

| ID | Screen | Main contents | Key actions |
|---|---|---|---|
| C01 | Splash | Brand mark, app name, tagline | Continue based on auth state |
| C02 | Welcome | Value proposition, language entry | Sign in / register |
| C03 | Login / Register | Phone number and consent | Request OTP |
| C04 | OTP verification | OTP input, resend timer | Verify |
| C05 | Profile setup | Approved profile fields | Save profile |
| C06 | Permissions | Explanations for location/notifications | Allow / skip where possible |
| C07 | Home | Greeting, submit CTA, quick links, summary | Submit, track, map, updates |
| C08 | Category selection | Approved categories and subcategories | Select category |
| C09 | Complaint details | Title, description, evidence picker | Continue |
| C10 | Location | Current location, map/manual pin | Confirm location |
| C11 | Review & submit | Read-only summary and consent | Submit |
| C12 | Confirmation | Reference number and next steps | View grievance / home |
| C13 | My grievances | Filterable list and statuses | Open grievance |
| C14 | Grievance detail | Status, timeline, permitted remarks/evidence | Feedback / reopen if allowed |
| C15 | Grievance map | Privacy-filtered map and filters | View permitted grievance |
| C16 | Profile & settings | Account, language, preferences, help | Edit / sign out |
| C17 | Notifications | In-app notification list | Open related record |

## Officer-side screens (separate implementation milestone)
- O01 Officer dashboard
- O02 Assigned grievance queue
- O03 Grievance review
- O04 Assignment
- O05 Investigation and progress update
- O06 Evidence upload
- O07 Resolution submission
- O08 Escalation queue
- O09 Reports (only approved metrics)

## Screen acceptance checklist
Every screen must define:
- Purpose and user role.
- Entry point and exit/navigation.
- Required data.
- Primary and secondary actions.
- Loading, empty, error and success states.
- Validation and permission behavior.
- Accessibility labels and touch targets.
- Tests and approved reference image.
