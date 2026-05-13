# RunK Flutter App

RunK is a Korean social running MVP built with Flutter. The app focuses on a
simple login flow, running records, a social-style feed, friends UI, records,
and app settings with light/dark theme switching.

## Current Scope

- Splash screen and session restoration
- Email/password login and signup UI
- Signup validation for email, nickname, password, and password confirmation
- Duplicate email/nickname check through the backend API
- Home, friends, feed, records, running map, record form, profile, and settings screens
- Light and dark app themes
- Local token/session persistence with `shared_preferences`
- REST API integration with the FastAPI backend

## Run Locally

Start the backend first, then run the Flutter app:

```powershell
flutter pub get
flutter run -d windows
```

For Android emulator testing:

```powershell
flutter devices
flutter run -d <device-id>
```

The API base URL is selected in `lib/services/api_client.dart`.

## Validation

```powershell
dart format lib test
flutter analyze
flutter test
flutter build windows --debug
```

## Notes

This is still an MVP. Real social login, GPS route recording, friend relation
APIs, likes/comments, and production deployment are planned for later phases.
