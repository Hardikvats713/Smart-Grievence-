# 14 — Definition of done

A screen or feature is not complete merely because it renders.

## UI quality
- Uses exact tokens from `docs/02_DESIGN_SYSTEM.md` and `design/design_tokens.json`.
- Matches the approved reference direction.
- No overflow on small and large supported mobile sizes.
- SafeArea, keyboard and system text scaling are handled.
- Touch targets are at least 48 × 48 logical pixels.
- Icon-only controls have accessibility labels.
- Loading, empty, error, disabled and success states are considered.

## Functional quality
- Every visible control performs its stated action.
- Navigation is correct and back behavior is predictable.
- Forms validate input and explain errors.
- Failed network requests do not show false success.
- Retry-sensitive operations prevent accidental duplicates.
- No fake production records or fabricated API responses.

## Engineering quality
- Formatter and static analysis pass.
- Relevant unit/widget/integration tests pass.
- No secrets in source control.
- Backend authorization is enforced server-side.
- Documentation and API contracts are updated.
- Known limitations are documented.

## Handoff report
For each completed task, report:
1. Summary.
2. Files created or changed.
3. Tests and commands executed.
4. Results.
5. Known gaps.
6. Next task requiring approval.
