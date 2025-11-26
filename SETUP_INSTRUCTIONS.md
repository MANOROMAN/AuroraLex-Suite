# AuroraLex Suite - Setup Instructions

## Required API Keys

This project requires the following API keys to function:

### 1. Google Gemini API Key
- Get your API key from: https://makersuite.google.com/app/apikey
- Replace `YOUR_GEMINI_API_KEY_HERE` in `lib/src/screens/ai_legal_chat_screen.dart` (line 51)

### 2. Firebase Configuration

#### For Android:
1. Create a Firebase project at https://console.firebase.google.com
2. Add an Android app to your Firebase project
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

#### For iOS:
1. Add an iOS app to your Firebase project
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/GoogleService-Info.plist`

#### Update Firebase Options:
Replace `YOUR_FIREBASE_API_KEY` in `lib/src/core/config/firebase_options.dart` with your actual Firebase API keys for each platform.

## Installation Steps

1. Install dependencies:
```bash
flutter pub get
```

2. Generate splash screen:
```bash
dart run flutter_native_splash:create
```

3. Generate launcher icons:
```bash
dart run flutter_launcher_icons
```

4. Run the app:
```bash
flutter run
```

## Important Notes

- The `assets/images/icon.png` is used for both splash screen and app icon
- Firebase Authentication, Firestore, Storage, and Functions must be enabled in your Firebase project
- Enable Google Sign-In in Firebase Authentication
