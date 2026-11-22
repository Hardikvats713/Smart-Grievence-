<p align="center">
  <img src="mobile/assets/images/smart_grievance_logo.png" alt="Smart Grievance Logo" width="160" />
</p>

<h1 align="center">Smart Grievance</h1>

<p align="center">
  <b>A Modern, Mobile-First Public Civic Grievance Submission, Redressal & GIS Tracking Platform</b>
</p>

<p align="center">
  <a href="#-screens-gallery"><img src="https://img.shields.io/badge/Screens-25%20Completed-17645F?style=for-the-badge&logo=flutter" alt="Screens: 25 Completed" /></a>
  <a href="#-automated-testing--quality-gates"><img src="https://img.shields.io/badge/Tests-138%2B%20Passing%20(100%25)-368568?style=for-the-badge&logo=checkmarx" alt="Tests: 138+ Passing" /></a>
  <a href="#-security--privacy-first-posture"><img src="https://img.shields.io/badge/Security-Audited%20%26%20Zero%20Leaks-E46A3D?style=for-the-badge&logo=shield" alt="Security: Zero Leaks" /></a>
  <a href="#-technology-stack"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter" alt="Flutter 3.x" /></a>
  <a href="#-technology-stack"><img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart" alt="Dart 3.x" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-gray?style=for-the-badge" alt="MIT License" /></a>
</p>

---

## 📌 Executive Summary

**Smart Grievance** is a next-generation civic engagement platform engineered to bridge the gap between citizens and municipal authorities. Built with Flutter and Clean Architecture, it empowers citizens to report public infrastructure issues, pinpoint real-time GIS locations, monitor live department workflows, provide feedback upon resolution, or request transparent grievance reopening.

The design strictly implements the warm-ivory / deep-teal civic aesthetic outlined in the official design system, guaranteeing zero-clutter mobile layouts, WCAG 2.2 accessibility, and a seamless 25-screen user journey.

---

## 📱 Master Storyboard Overview

The entire 25-screen mobile experience was designed and engineered from the ground up to match the official design specification:

<p align="center">
  <img src="mobile/assets/images/Smart%20Grievance%20App%20Storyboard.png" alt="Smart Grievance Master 25-Screen Storyboard" width="100%" style="border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.1);" />
</p>

---

## 📸 Screen Gallery (All 25 Screens)

Every screen is fully implemented, responsive across mobile form factors, verified against device safe areas, and golden-tested.

### Phase 1: Onboarding, Authentication & Permissions (Screens 01–07)

| 01. Splash Screen | 02. Welcome / Onboarding | 03. Login / Register | 04. OTP Verification |
| :---: | :---: | :---: | :---: |
| <img src="mobile/test/features/splash/goldens/splash_screen.png" width="200" /> | <img src="mobile/test/features/onboarding/goldens/welcome_screen.png" width="200" /> | <img src="mobile/test/features/auth/goldens/get_started_screen.png" width="200" /> | <img src="mobile/test/features/auth/goldens/verify_otp_screen.png" width="200" /> |
| *Brand identity & tagline* | *Carousel explaining civic impact* | *Citizen mobile authentication* | *6-digit auto-advancing code entry* |

| 05. Profile Setup | 06. System Permissions | 07. Citizen Home Dashboard |
| :---: | :---: | :---: |
| <img src="mobile/test/features/profile/goldens/setup_profile_screen.png" width="200" /> | <img src="mobile/test/features/permissions/goldens/allow_access_screen.png" width="200" /> | <img src="mobile/test/features/home/goldens/home_dashboard_375x812.png" width="200" /> |
| *Avatar upload & district picker* | *Location, Camera & Push notifications* | *Core action cards & quick navigation* |

---

### Phase 2: 5-Stage Grievance Submission Flow (Screens 08–12)

| 08. Select Category | 09. Grievance Details | 10. Location GIS Pin |
| :---: | :---: | :---: |
| <img src="mobile/test/features/grievances/goldens/screen_08_select_category.png" width="200" /> | <img src="mobile/test/features/grievances/goldens/screen_09_grievance_details.png" width="200" /> | <img src="mobile/test/features/grievances/goldens/screen_10_grievance_location.png" width="200" /> |
| *7 civic categories with Burnt Ember focus* | *Title, character counter & photo upload* | *Interactive map & GPS auto-detect* |

| 11. Review & Submit | 12. Submission Confirmed |
| :---: | :---: |
| <img src="mobile/test/features/grievances/goldens/screen_11_review_submit.png" width="200" /> | <img src="mobile/test/features/grievances/goldens/screen_12_submission_confirmation.png" width="200" /> |
| *Pre-submission audit & editable sections* | *Unique Reference ID (`SG...`) & copy button* |

---

### Phase 3: Tracking, Timeline & Interactive GIS Map (Screens 13–16)

| 13. My Grievances | 14. Status Timeline | 15. GIS Map Overview | 16. Profile & Settings |
| :---: | :---: | :---: | :---: |
| <img src="mobile/test/features/grievances/goldens/screen_13_my_grievances.png" width="200" /> | <img src="mobile/test/features/grievances/goldens/screen_14_grievance_details_timeline.png" width="200" /> | <img src="mobile/test/features/grievances/goldens/screen_15_grievance_map.png" width="200" /> | <img src="mobile/test/features/grievances/goldens/screen_16_profile_settings.png" width="200" /> |
| *Status filters (All, Active, Resolved)* | *Audit trail with timestamped checkpoints* | *Live markers, category chips & nearby radius* | *Citizen preferences & account management* |

---

### Phase 4: Category-Specific Forms & Citizen Lifecycle (Screens 17–25)

| 17. Notifications | 18. How It Works | 19. Electricity Form |
| :---: | :---: | :---: |
| <img src="mobile/test/features/grievances/goldens/screen_17_notifications.png" width="200" /> | <img src="mobile/test/features/grievances/goldens/screen_18_how_it_works.png" width="200" /> | <img src="mobile/test/features/grievances/goldens/screen_19_electricity_form.png" width="200" /> |
| *Date-grouped alerts (Today/Yesterday)* | *Vertical timeline explaining resolution steps* | *Consumer No, Outage & Pole hazard fields* |

| 20. Water Supply Form | 21. Sanitation Form | 22. Edit Profile |
| :---: | :---: | :---: |
| <img src="mobile/test/features/grievances/goldens/screen_20_water_supply_form.png" width="200" /> | <img src="mobile/test/features/grievances/goldens/screen_21_sanitation_form.png" width="200" /> | <img src="mobile/test/features/grievances/goldens/screen_22_edit_profile.png" width="200" /> |
| *Pipeline leak, low pressure & meter inputs* | *Waste overflow, dump site & vehicle tracking* | *Update citizen metadata & district association* |

| 23. Saved Addresses | 24. Resolution Feedback | 25. Reopen Grievance |
| :---: | :---: | :---: |
| <img src="mobile/test/features/grievances/goldens/screen_23_saved_addresses.png" width="200" /> | <img src="mobile/test/features/grievances/goldens/screen_24_resolution_feedback.png" width="200" /> | <img src="mobile/test/features/grievances/goldens/screen_25_reopen_grievance.png" width="200" /> |
| *Home, Work & Custom locations for fast entry* | *Interactive 5-star rating & citizen notes* | *Reason dropdown, evidence upload & re-evaluation* |

---

## 🔒 Security & Privacy-First Posture

Security and data confidentiality are fundamental to the Smart Grievance architecture.

> [!IMPORTANT]
> **Repository Security Audit Verified:**
> - **Zero Hardcoded Secrets:** No API keys, personal access tokens (`ghp_`), database passwords, or private encryption keys exist in tracked files or commit history.
> - **Sanitized Git Remotes:** Authentication tokens are never saved inside repository configurations (`.git/config`).
> - **Defensive `.gitignore`:** Standardized ignoring of all local environments (`.env`, `.env.*`), build artifacts, keyrings, credentials, and debug dumps.
> - **Role-Based Access Control (RBAC):** Strict separation of privileges among Citizens, Field Officers, and Department Supervisors.
> - **PII & Media Protection:** Citizen phone numbers, names, and uploaded media attachments are handled in accordance with privacy guidelines without insecure public caching.

---

## 🎨 Design System & Visual Tokens

The user interface adheres to the approved Smart Grievance Design System, inspired by organic civic warmth and clear readability:

<div align="center">

| Token Name | Hex Code | Visual Sample | Usage |
| :--- | :---: | :---: | :--- |
| **Warm Ivory** | `#F3EEE8` | ![#F3EEE8](https://via.placeholder.com/15/F3EEE8/000000?text=+) | Primary screen background, card surfaces |
| **Deep Teal Green** | `#17645F` | ![#17645F](https://via.placeholder.com/15/17645F/000000?text=+) | Primary buttons, headers, active navigation |
| **Burnt Ember** | `#E46A3D` | ![#E46A3D](https://via.placeholder.com/15/E46A3D/000000?text=+) | Action buttons, active progress step, alerts |
| **Mint Sage** | `#DDEEE9` | ![#DDEEE9](https://via.placeholder.com/15/DDEEE9/000000?text=+) | Selected card highlights, badges, chips |
| **Primary Text** | `#263B38` | ![#263B38](https://via.placeholder.com/15/263B38/000000?text=+) | High-contrast body, titles, headings |
| **Secondary Text**| `#78847F` | ![#78847F](https://via.placeholder.com/15/78847F/000000?text=+) | Subtitles, timestamps, helper text |
| **Card Border** | `#E5E9E6` | ![#E5E9E6](https://via.placeholder.com/15/E5E9E6/000000?text=+) | Subtle separators, field outlines |

</div>

- **Typography**: Google Font **Poppins** exclusively across all weights (Regular 400, Medium 500, SemiBold 600, Bold 700).
- **Spacing Scale**: Strict 8-point harmonic grid (4px, 8px, 12px, 16px, 20px, 24px, 32px).
- **Touch Ergonomics**: All interactive elements satisfy minimum $48 \times 48\text{ px}$ touch targets.

---

## 🏗️ Architectural Topology

The project follows Clean Architecture with strict separation between UI, domain business logic, and data sources:

```
SMART-GRIEVANCE/
├── mobile/                           # Flutter mobile client (Screens 01-25)
│   ├── assets/                       # Vector illustrations, icons & brand waves
│   ├── lib/
│   │   ├── core/
│   │   │   ├── constants/            # Design tokens, colors, typography scales
│   │   │   ├── network/              # REST client & error interceptors
│   │   │   ├── router/               # Declarative navigation & route guards
│   │   │   └── widgets/              # Reusable buttons, inputs, cards & headers
│   │   └── features/
│   │       ├── auth/                 # OTP generation, login & profile setup
│   │       ├── home/                 # Citizen dashboard & quick links
│   │       ├── grievances/           # Submission, tracking, GIS map, forms 17-25
│   │       └── profile/              # Account settings, saved addresses
│   └── test/                         # 131+ Golden, unit, and widget test suites
├── backend/                          # NestJS REST API & Civic Workflow Engine
│   ├── src/
│   │   ├── modules/                  # Auth, Grievances, Escalation, Notifications
│   │   └── common/                   # Guards, interceptors, filters
│   └── test/                         # Backend e2e & contract tests
├── ai-service/                       # FastAPI ML Service (Optional classifier)
├── infrastructure/                   # Docker Compose & local database definitions
└── docs/                             # Architecture blueprints, data models, APIs
```

---

## 🚀 Quickstart Guide

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.19.0` or higher)
- [Dart SDK](https://dart.dev/get-dart) (`^3.3.0` or higher)
- Chrome Browser (for web preview) or Android Studio / Xcode

### 1. Clone & Setup
```bash
git clone https://github.com/Hardikvats713/Smart-Grievence-.git
cd Smart-Grievence-/mobile
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run Automated Tests
Execute the entire test suite including all 25 golden screen validations:
```bash
flutter test
```
*Expected: 131+ test cases passing with 100% green exit code.*

### 4. Launch Application
To launch the application locally in responsive preview mode:
```bash
flutter run -d chrome
```

---

## 🧪 Automated Testing & Quality Gates

The codebase enforces strict test-driven development and visual regression protection:

- **131+ Unit & Widget Tests**: Validating form validation, category switching, timeline progression, and address persistence.
- **Golden File Visual Tests**: Ensuring all 25 screens render pixel-accurately across iPhone, Android, and Web resolutions without text truncation or overflow errors.
- **Null Safety**: 100% sound null safety enabled.
- **Lint Compliance**: Zero analyzer warnings under `flutter_lints`.

---

## 📄 License & Attribution

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

Developed with ❤️ for transparent, responsive, and citizen-empowering civic administration.
