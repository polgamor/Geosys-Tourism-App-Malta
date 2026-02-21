# GeoSYS — Smart Tourism Platform

> A refactored version of an **Erasmus+ collaborative project** focused on Smart Tourism and Big Data visualisation. GeoSYS is a professional-grade mobile application that helps tourists explore Malta through an interactive ArcGIS-powered map, personalised itineraries, and a rich user-profiling system.

---

## Table of Contents

1. [Overview](#overview)
2. [Tech Stack](#tech-stack)
3. [Architecture](#architecture)
4. [Project Structure](#project-structure)
5. [Setup Instructions](#setup-instructions)
6. [Environment Variables](#environment-variables)
7. [Features](#features)
8. [Contributing](#contributing)

---

## Overview

GeoSYS delivers a smart-tourism experience on mobile (Android & iOS) by combining real-time geospatial data from **ArcGIS Maps SDK** with a **Supabase** backend. The app supports multi-language navigation across English, Spanish, French, Italian, German and Maltese.

Key capabilities:
- Email/password, Google, and Facebook authentication
- Multi-step onboarding to capture travel preferences
- Interactive ArcGIS web map with route calculation (walk / drive / cycle)
- Persistent user profile with avatar upload
- Fully localised UI (6 languages)

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | [Flutter](https://flutter.dev) 3.x / Dart 3.x |
| **Backend & Auth** | [Supabase](https://supabase.com) (PostgreSQL, Storage, Auth) |
| **Maps** | [ArcGIS Maps SDK for Flutter](https://developers.arcgis.com/flutter/) v200.7 |
| **State Management** | [Provider](https://pub.dev/packages/provider) (MVVM pattern) |
| **Localisation** | Flutter Intl / `flutter_localizations` (6 locales) |
| **OAuth** | Google Sign-In · Facebook Auth |
| **Secure Storage** | `flutter_secure_storage` |
| **Image Handling** | `image_picker` · `cached_network_image` |
| **Web Views** | `webview_flutter` |

---

## Architecture

GeoSYS follows **Clean Architecture** principles organised around a feature-first directory layout. Concerns are separated into three distinct layers:

```
┌─────────────────────────────┐
│         Presentation        │  ← Views (Screens) + ViewModels
├─────────────────────────────┤
│           Domain            │  ← Business rules, entities, interfaces
├─────────────────────────────┤
│            Data             │  ← Services, repositories, remote sources
└─────────────────────────────┘
```

### Design Decisions

| Decision | Rationale |
|---|---|
| **MVVM + Provider** | Lightweight, testable, and idiomatic for Flutter. Each feature owns its `ViewModel` (`ChangeNotifier`) which the View observes via `Consumer`. |
| **Repository via Service layer** | `AuthService` acts as the single data-access point for all Supabase calls, keeping ViewModels free of SDK details. |
| **Feature-first folders** | Each feature (`login`, `map`, `profile`, etc.) is self-contained with its own `screens/` and `viewmodel/` directories, enabling independent development and testing. |
| **Enum-driven transport modes** | `TransportMode` encapsulates ArcGIS impedance values, display names, icons and colours in a single, type-safe enum — eliminating scattered string literals. |
| **Typed exceptions** | A custom `AuthServiceException` hierarchy allows ViewModels to catch and surface specific error messages without leaking SDK internals to the UI. |

---

## Project Structure

```
lib/
├── main.dart                          # App entry point, DI setup
├── colors.dart                        # Global colour palette (AppColors)
├── webview_screen.dart                # Generic WebView screen
│
├── data/
│   └── services/
│       ├── auth_service.dart          # All Supabase auth & profile calls
│       ├── auth_exceptions.dart       # Typed exception hierarchy
│       └── auth_gate.dart             # Auth-state router
│
├── localization/
│   ├── locale_provider.dart           # ChangeNotifier for locale switching
│   └── generated/                     # Auto-generated ARB translations
│
└── features/
    ├── splash/                        # Splash screen + animations
    ├── login/
    │   ├── screens/                   # LoginScreen, NewPasswordScreen
    │   └── viewmodel/                 # LoginViewModel, NewPasswordViewModel
    ├── onboarding/
    │   ├── screens/                   # 6-step onboarding flow
    │   └── viewmodel/                 # OnboardingViewModel
    ├── map/
    │   ├── map_screen.dart            # Bottom-nav host
    │   ├── map_view.dart              # ArcGIS map + controls
    │   ├── map_config.dart            # Map constants & factory helpers
    │   ├── map_interactions.dart      # Tap handling, feature popups
    │   ├── map_location.dart          # GPS / location display
    │   ├── route_service.dart         # ArcGIS route calculation
    │   └── custom_map_widget.dart     # Reusable map wrappers
    ├── profile/
    │   ├── screens/                   # ProfileScreen, EditProfileScreen
    │   └── viewmodel/                 # ProfileViewModel
    ├── events/                        # EventsScreen (placeholder)
    ├── favorites/                     # FavoritePlacesScreen (placeholder)
    ├── itineraries/                   # ItinerariesScreen (placeholder)
    └── widgets/
        └── language_picker_widget.dart
```

---

## Setup Instructions

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.7.2
- Dart SDK ≥ 3.0
- Android Studio or Xcode (for device/emulator targets)
- A [Supabase](https://supabase.com) project with the `profiles` table and required RPC functions
- An [ArcGIS Developer](https://developers.arcgis.com) account with a valid API key

### 1. Clone the repository

```bash
git clone https://github.com/your-org/geosys-app.git
cd geosys-app
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure environment variables

Create a `.env` file at the project root (see [Environment Variables](#environment-variables)):

```bash
cp .env.example .env
# then fill in your values
```

### 4. Generate localisation files

```bash
flutter gen-l10n
```

### 5. Run the app

```bash
# Android
flutter run -d android

# iOS (requires macOS + Xcode)
flutter run -d ios
```

### 6. Build a release APK

```bash
flutter build apk --release
```

---

## Environment Variables

The app reads configuration from a `.env` file at the project root via `flutter_dotenv`.

| Variable | Description |
|---|---|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | Your Supabase anonymous (public) API key |

> **Note:** The ArcGIS API key is currently embedded in `main.dart` for development purposes. For production, move it to `.env` and load it via `dotenv.env['ARCGIS_API_KEY']`.

---

## Features

### Authentication
- Email/password sign-in and registration
- Google OAuth (via `google_sign_in`)
- Facebook OAuth (via `flutter_facebook_auth`)
- OTP-based password reset flow
- Persistent sessions via `flutter_secure_storage`

### Onboarding (6 steps)
1. Name & surname
2. Country of origin
3. Age & gender
4. Travel style & budget tier
5. Trip date range
6. Interests (multi-select)

### Interactive Map
- ArcGIS web map centred on Malta
- Zoom in / out controls
- GPS location tracking with auto-pan
- Tap to select a destination
- Route calculation: walking, driving, cycling
- Route info dialog (distance, time, mode)

### User Profile
- View and edit all onboarding data
- Upload a profile avatar from gallery
- Delete account with password confirmation

### Localisation

Supports: English · Spanish · Maltese · French · Italian · German

---

## Contributing

This project was developed as part of an **Erasmus+ programme** collaborative initiative on Smart Tourism and Big Data visualisation. Contributions are welcome — please open an issue first to discuss the change you would like to make.

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m "feat: add my feature"`
4. Push to the branch: `git push origin feature/my-feature`
5. Open a Pull Request

---