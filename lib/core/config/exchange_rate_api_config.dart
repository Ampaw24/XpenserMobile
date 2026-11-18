/// Configuration for the keyless ExchangeRate-API open access endpoint.
///
/// Terms: https://www.exchangerate-api.com/docs/free — attribution is
/// required wherever the rates are shown, and the endpoint is IP-throttled
/// (HTTP 429 for 20 minutes), so requests are cached aggressively.
abstract final class ExchangeRateApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'EXCHANGE_RATE_API_BASE_URL',
    defaultValue: 'https://open.er-api.com',
  );

  /// All rates are fetched against this base and crossed locally,
  /// so one API call serves every currency pair.
  static const String rateBase = 'USD';

  static const Duration requestTimeout = Duration(seconds: 10);

  /// Upstream rates update once a day, so a 6-hour cache keeps rates
  /// at most a few hours behind while staying far below the throttle.
  static const Duration cacheTtl = Duration(hours: 6);

  /// Manual refreshes inside this window reuse the cache.
  static const Duration minRefreshInterval = Duration(minutes: 15);

  static const String attributionLabel = 'Rates by ExchangeRate-API';
}
