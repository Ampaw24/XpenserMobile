enum CurrencyApiErrorType {
  notConfigured,
  unauthorized,
  rateLimited,
  badRequest,
  network,
  server,
  invalidResponse,
}

class CurrencyApiException implements Exception {
  const CurrencyApiException(this.type, {this.statusCode});

  final CurrencyApiErrorType type;
  final int? statusCode;

  /// User-facing copy; deliberately omits credentials or raw server text.
  String get userMessage => switch (type) {
    CurrencyApiErrorType.network =>
      'No internet connection. Check your network and try again.',
    CurrencyApiErrorType.rateLimited =>
      'Too many requests right now. Please try again shortly.',
    CurrencyApiErrorType.notConfigured || CurrencyApiErrorType.unauthorized =>
      'Exchange rates are unavailable at the moment.',
    CurrencyApiErrorType.badRequest ||
    CurrencyApiErrorType.server ||
    CurrencyApiErrorType
        .invalidResponse => 'Could not load exchange rates. Please try again.',
  };

  @override
  String toString() =>
      'CurrencyApiException(${type.name}${statusCode == null ? '' : ', $statusCode'})';
}
