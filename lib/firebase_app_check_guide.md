# Firebase AppCheck Setup Guide

## Error: "Firebase App Check API has not been used in project or is disabled"

If you're seeing this error, follow these steps to enable the Firebase App Check API in your Google Cloud Console:

### Step 1: Enable the Firebase App Check API

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Navigate to "APIs & Services" > "Library"
4. Search for "Firebase App Check API"
5. Click on it and press "Enable"

### Step 2: Configure Debug Mode in Your Flutter App

The app is already configured to use debug providers for both Android and iOS:

```dart
await FirebaseAppCheck.instance.activate(
  androidProvider: AndroidProvider.debug,
  appleProvider: AppleProvider.debug,
);
```

### Step 3: Debug Token for Development Testing

When testing in debug mode, you'll need a debug token:

1. For Android:
   - The first time your app runs with App Check in debug mode, a dialog will appear
   - Copy the debug token and save it

2. For iOS:
   - The debug token will be printed in the console logs
   - Look for a message with the debug token

3. Add the debug token to your Firebase Console:
   - Go to Firebase Console > Project Settings > App Check
   - Scroll to "Apps" section and select your app
   - Click "Add debug token" and paste your token

### Step 4: Production Setup

Before deploying to production, configure your app to use real attestation providers:

```dart
await FirebaseAppCheck.instance.activate(
  androidProvider: AndroidProvider.playIntegrity,
  appleProvider: AppleProvider.deviceCheck,
);
```

## Troubleshooting

If you continue to see issues:
1. Verify you have the latest version of firebase_app_check package
2. Make sure Firebase App Check is properly initialized before any Firebase service calls
3. Check Firebase Console for any error logs related to App Check
4. Ensure your app has internet connectivity when initializing Firebase