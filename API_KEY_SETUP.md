# API key configuration

The app reads provider credentials from Dart compile-time environment values.
Do not put real keys in source files, documentation, or committed environment
files.

## Run locally

Create keys with the providers you use, then pass them to Flutter:

```powershell
flutter run `
  --dart-define=GEMINI_API_KEY=your_gemini_key `
  --dart-define=OPENWEATHER_API_KEY=your_openweather_key `
  --dart-define=DATA_GOV_API_KEY=your_data_gov_key
```

Only the keys required by the features you are testing need to be supplied.

## Security note

Compile-time values are included in client app builds and can be extracted.
For production, call paid or privileged APIs through a server-side service,
store credentials on that server, and restrict client keys with each provider.
If a key was ever committed or shared, revoke it and create a replacement.