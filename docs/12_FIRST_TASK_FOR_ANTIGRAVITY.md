# First task for Antigravity

Do not implement all product screens yet.

## Task
Inspect this repository and implement only the Flutter design foundation.

## Read first
- `AGENTS.md`
- `docs/02_DESIGN_SYSTEM.md`
- `docs/08_ANTIGRAVITY_INSTRUCTIONS.md`

## Deliver
1. Flutter project scaffold if absent.
2. Exact color tokens.
3. Poppins font integration (use licensed/local font assets or documented package source).
4. Theme and spacing tokens.
5. Glass button with accessible fallback.
6. Primary and secondary buttons.
7. Card and input components.
8. Header and four-item bottom navigation.
9. A component showcase screen demonstrating default, pressed, disabled and loading states.

## Do not
- Build all screens.
- Connect production services.
- Invent logo assets.
- Change palette or typography.
- Add fake authentication or complaint data.

## Acceptance
- `flutter analyze` passes.
- Widget tests cover shared controls.
- Preview matches `docs/02_DESIGN_SYSTEM.md`.
- Small and large mobile layouts do not overflow.
- Report exact files changed, commands run and known gaps.
