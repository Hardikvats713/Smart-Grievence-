# Repository-wide agent instructions

You are working on Smart Grievance, a mobile-only grievance redressal product for this phase.

## Mandatory rules
1. Read `README.md` and relevant documents under `docs/` before coding.
2. `docs/02_DESIGN_SYSTEM.md` is the source of truth for visual tokens and UI behavior.
3. Do not change approved colors, typography, logo, navigation or component styling without explicit approval.
4. Implement one agreed milestone at a time. Do not generate the entire application in one pass.
5. Reuse shared components. Do not duplicate design tokens or create parallel button/card systems.
6. Do not add Disaster Management or Rural Development functionality in this phase.
7. Never hardcode real credentials, API keys, OTPs, user data or secrets.
8. Never present mock data as real production data. Mark fixtures and demo data clearly.
9. Every interactive control must have a real action, a disabled state where appropriate, and loading/success/error handling.
10. Validate forms on both client and server.
11. Enforce authorization on the server; hiding a UI element is not access control.
12. Do not silently invent department mappings, escalation rules, legal policy or SLA values. Make these configurable and request approval.
13. Add or update tests and documentation with every meaningful implementation change.
14. Avoid destructive changes. Inspect existing code before replacing files.
15. Ask a concise clarification when requirements are ambiguous rather than guessing.

## Before marking a task complete
- Run relevant formatter, analyzer/linter and tests.
- Check small and large mobile layouts.
- Check loading, empty, error and success states.
- Confirm accessibility labels and touch targets.
- Summarize files changed, tests run, known gaps and next step.
