# Homiva Mobile App (MVP Skeleton)

This repository hosts the Flutter + Firebase mobile application for the Homiva smart water management system. The project follows the product/technical specification provided for the MVP release and includes the following highlights:

- Flutter project layout aligned with the required feature folders (`core`, `domain`, `data`, `ui`, `services`, `features`).
- Riverpod state management with GoRouter navigation scaffolding for all MVP screens (Auth, Home, Analytics, Alerts, Settings, Onboarding, Profile, Diagnostics).
- Firebase data models and repositories reflecting the defined Firestore and Realtime Database schema.
- Command + safety interlock wiring for manual pump operations with 5-minute timeout payloads.
- Placeholder implementations for device onboarding, notifications, and analytics visualisation.

> **Note:** This is a scaffolded codebase. Firebase configuration files, native flavour setup, assets, and CI scripts should be added during integration with real infrastructure.

## Getting Started

1. Install Flutter (3.16+) and Dart SDK on your machine.
2. Run `flutter pub get` to fetch dependencies.
3. Configure Firebase using `flutterfire configure` and replace `lib/firebase_options.dart` with generated options for each flavour.
4. Use `flutter run --flavor dev -t lib/main.dart` to launch the development flavour once native projects are configured.

## CI Build Steps

Add the following high-level steps to your CI system (e.g., GitHub Actions, Bitrise, Codemagic):

1. **Flutter environment setup** – Install Flutter 3.16+, run `flutter pub get`, and cache the SDK and pub packages.
2. **Dev flavour build** – Execute `flutter build apk --flavor dev -t lib/main.dart --debug` to produce a debug APK for internal testing.
3. **Prod flavour build** – Execute `flutter build appbundle --flavor prod -t lib/main.dart --release` for Android. For iOS, run `flutter build ipa --flavor prod -t lib/main.dart --release` after configuring signing.
4. **Signing guidance** – Supply `android/key.properties` with keystore paths and passwords injected via CI secrets. Store the keystore securely (e.g., in your secrets manager) and download during the build.
5. **iOS codesign** – Configure Xcode with your Apple Developer account, register bundle IDs for each flavour, and export the provisioning profiles/certificates. Provide them to CI using secure environment variables or encrypted files.
6. **Artifacts & distribution** – Upload the debug APK to internal testers (Firebase App Distribution/TestFlight) and keep the release bundle/IPA ready for store submission.

## Project Structure

```
lib/
  core/            // Routing, theming
  domain/          // Entities for Firestore/RTDB models
  data/            // Firebase repositories and adapters
  features/        // State controllers and Riverpod providers per feature
  services/        // Cross-cutting services (Firebase, notifications)
  ui/              // Screens and widgets grouped by feature
```

Additional documentation for CI/CD, Firebase rules, and Cloud Functions should be added in follow-up tasks.
