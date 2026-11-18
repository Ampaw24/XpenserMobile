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

## Exchange rates (ExchangeRate-API)

The currency converter uses daily mid-market rates from the keyless
[ExchangeRate-API open access endpoint](https://www.exchangerate-api.com/docs/free) (`https://open.er-api.com/v6/latest/USD`).
No API key or `.env` setup is required.

Terms to respect: the rates must be shown with the attribution "Rates by ExchangeRate-API" (rendered under the
converter result), the data may be cached but not redistributed, and the endpoint is IP-throttled (HTTP 429 for 20 minutes).

Rates are fetched once against USD, cached in Hive for 6 hours, and crossed locally, so one API call serves every
currency pair. Manual refreshes within 15 minutes reuse the cache. If a refresh fails, the last cached rates are shown
and marked as offline. Rates are indicative, not suitable for settlement. Tuning lives in
`lib/core/config/exchange_rate_api_config.dart`; the base URL can be overridden with
`--dart-define=EXCHANGE_RATE_API_BASE_URL=...`.
