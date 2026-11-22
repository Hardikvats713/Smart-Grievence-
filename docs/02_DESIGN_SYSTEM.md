# 02 — Smart Grievance design system

This document is the single source of truth for visual design.

## Brand palette — locked
| Token | Hex | Use |
|---|---|---|
| Warm Ivory | `#F3EEE8` | Default page background |
| Deep Teal Green | `#17645F` | Primary brand, headings, primary actions |
| Burnt Ember | `#E46A3D` | Restrained accent, small highlights |
| Mint Sage | `#DDEEE9` | Secondary surfaces |
| White | `#FFFFFF` | Cards and form surfaces |
| Primary Text | `#263B38` | Main body text |
| Secondary Text | `#78847F` | Supporting text |
| Border | `#E5E9E6` | Dividers and outlines |
| Disabled | `#B8C2BE` | Disabled controls |
| Success | `#368568` | Success state |
| Warning | `#D9A441` | Warning state |
| Error | `#C94D4D` | Error state |
| Information | `#5189B5` | Informational state |

Do not invent brand colors or alter these values without approval.

## Color balance
Use the palette as a visual guide: ivory is dominant, teal establishes identity, mint supports, and ember is used sparingly. Do not force percentages on every screen.

## Typography
- Family: Poppins only.
- Display/greeting: 28 px, 700.
- Screen heading: 22 px, 600.
- Section heading: 18 px, 600.
- Card heading: 16 px, 500.
- Body: 14 px, 400.
- Supporting: 12 px, 400.
- Button: 15 px, 600.
- Metadata: 11 px, 500.
- Line height: headings 1.25; body 1.5; supporting 1.4.

Use local font assets or a pinned package version. Avoid relying on runtime font downloads.

## Layout
- 8-point spacing scale: 4, 8, 12, 16, 24, 32, 40 logical px.
- Default horizontal page padding: 20 px.
- Section gap: 20–24 px.
- Card padding: 16 px.
- Card radius: 16–20 px.
- Input radius: 12–16 px.
- Primary button height: 50–56 px.
- Minimum touch target: 48 × 48 logical px.
- Respect SafeArea and keyboard insets.
- Avoid fixed positioning that causes clipping on smaller devices.

## Glassmorphism
Use selectively on interactive buttons and selected interactive surfaces, not every card.
- Translucent white surface, approximately 65–80% opacity.
- Blur sigma approximately 12–18.
- Subtle white border, approximately 50–70% opacity.
- Soft diffuse shadow.
- Clip blur to rounded corners.
- Primary glass action: teal base, subtle translucent overlay, white label/icon; ember may be used for a small action detail.
- Secondary glass action: translucent white surface, teal label/icon.
- Press: scale approximately 0.98.
- Transition: 180–250 ms.
- Ensure text contrast and provide a non-blurred fallback if blur is unsupported or costly.

## Icons
- Use one consistent outline icon family throughout.
- Default icon color: Deep Teal.
- Active/selected icon may use Teal or restrained Ember.
- Use semantic icons; do not use decorative emoji as interface icons.
- Icon-only controls require accessibility labels.

## Navigation
Citizen bottom navigation has exactly four destinations:
1. Home
2. My Grievances
3. Map
4. Profile

Notifications are accessed from the home header. Do not add bottom tabs without approval.

## Screen consistency
- Use shared components and theme tokens.
- Keep one dominant primary action per screen.
- Keep layouts calm, readable and uncluttered.
- Include loading, empty, error and success states.
- Authentication screens do not show citizen bottom navigation.
- Submission screens show a consistent progress indicator.
- Do not recreate or distort the approved logo.
