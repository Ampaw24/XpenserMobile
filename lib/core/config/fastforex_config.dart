/// Build-time configuration for the fastFOREX exchange-rate API.
///
/// Values come from the gitignored `.env` (template: `.env.example`):
/// `flutter run --dart-define-from-file=.env`
abstract final class FastForexConfig {
  static const String apiKey = String.fromEnvironment('API_URL_KEY');

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.fastforex.io',
  );

  /// All rates are fetched against this base and crossed locally,
  /// so one API call serves every currency pair.
  static const String rateBase = 'USD';

  static const Duration requestTimeout = Duration(seconds: 10);

  /// Rates are indicative for budgeting, so hourly freshness is sufficient
  /// and keeps quota usage to at most ~720 calls per device per month.
  static const Duration cacheTtl = Duration(hours: 1);

  /// Manual refreshes inside this window reuse the cache; upstream
  /// rates refresh at most every 60 seconds on the entry plan.
  static const Duration minRefreshInterval = Duration(minutes: 1);

  static bool get isConfigured => apiKey.isNotEmpty;
}
