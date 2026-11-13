# expenser

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Exchange rates (fastFOREX)

The currency converter uses live mid-market rates from [fastFOREX](https://www.fastforex.io/docs).
The API key is supplied at build time and is never committed:

```sh
cp .env.example .env   # .env is gitignored
# set API_URL_KEY (and optionally API_BASE_URL) in .env, then:
flutter run --dart-define-from-file=.env
```

Rates are fetched once against USD (`/fetch-all`), cached in Hive for 1 hour, and crossed locally,
so one API call serves every currency pair. If a refresh fails, the last cached rates are shown and marked as offline.
Tuning lives in `lib/core/config/fastforex_config.dart`.
