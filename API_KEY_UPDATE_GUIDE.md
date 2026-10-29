# API key update guide

Credentials are no longer stored in Dart source. To configure Gemini,
OpenWeatherMap, or Data.gov.in for a local run, follow
[API_KEY_SETUP.md](./API_KEY_SETUP.md) and pass the needed
`--dart-define` values to Flutter.

Never commit provider credentials. Revoke and replace any key that was
previously committed or shared. Client app keys can be extracted from a build;
use a server-side proxy for production secrets.