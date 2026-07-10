# Mentallico — Flutter App

The patient/therapist mobile app: mood tracking, journaling, AI chat, therapist
booking, and VR therapy sessions (via an embedded Unity library on Android).

## Setup

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) and
   run `flutter pub get`.
2. **Firebase config (required, not committed):**
   - Android: copy `android/app/google-services.json.example` to
     `android/app/google-services.json` and fill in real values from the
     Firebase console (Project settings → Your apps → Android app).
   - iOS: download `GoogleService-Info.plist` from the Firebase console and
     place it at `ios/Runner/GoogleService-Info.plist`.
   - `lib/firebase_options.dart` (FlutterFire-CLI generated) is committed and
     already has working values for Web/Android/iOS/Windows — the native
     config files above are only needed for a few native-only Firebase
     features.
3. `android/local.properties` and `android/unityLibrary/**/local.properties`
   are machine-specific (Flutter/Android SDK paths) — Flutter regenerates
   these automatically on first build.

## VR / Unity (Android only)

`android/unityLibrary/` contains an exported Unity Android library. The
IL2CPP-generated C++ source (`Il2CppOutputProject/`) and compiled
`libil2cpp.so` are **not committed** (regenerated automatically on first
build by the `:unityLibrary:buildIl2Cpp` Gradle task) — expect the first
build to take significantly longer while it compiles.

If `android/unityLibrary/unityLibrary/unityLibrary/` is missing entirely
(rather than just its generated output), the Unity project needs to be
re-exported from Unity Editor (Android Build Support module) into
`android/unityLibrary/`.

## Running

```
flutter run
```

For a physical Android device with limited RAM, IL2CPP's native compile
can crash from running too many parallel jobs. If that happens, lower
`--jobs=N` in the `buildIl2CppImpl` function inside
`android/unityLibrary/unityLibrary/unityLibrary/build.gradle`.
