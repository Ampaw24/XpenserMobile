import 'dart:async';
import 'dart:convert';

import 'package:expenser/core/config/fastforex_config.dart';
import 'package:expenser/models/exchange_rates.dart';
import 'package:expenser/services/currency/currency_api_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Thin HTTP client for fastFOREX. Throws [CurrencyApiException] only.
class FastForexApiClient {
  FastForexApiClient({
    required http.Client httpClient,
    String apiKey = FastForexConfig.apiKey,
    String baseUrl = FastForexConfig.baseUrl,
    Duration timeout = FastForexConfig.requestTimeout,
    DateTime Function() clock = DateTime.now,
  }) : _http = httpClient,
       _apiKey = apiKey,
       _baseUri = Uri.parse(baseUrl),
       _timeout = timeout,
       _clock = clock;

  final http.Client _http;
  final String _apiKey;
  final Uri _baseUri;
  final Duration _timeout;
  final DateTime Function() _clock;

  Future<ExchangeRates> fetchAll({required String base}) async {
    final json = await _get('/fetch-all', {'from': base});
    try {
      return ExchangeRates.fromApiJson(json, fetchedAt: _clock());
    } on FormatException {
      throw const CurrencyApiException(CurrencyApiErrorType.invalidResponse);
    }
  }

  Future<Map<String, dynamic>> _get(
    String path,
    Map<String, String> query,
  ) async {
    if (_apiKey.isEmpty) {
      debugPrint(
        'API_URL_KEY is not set. Run with --dart-define-from-file=.env '
        '(full restart required; hot reload does not apply dart-defines).',
      );
      throw const CurrencyApiException(CurrencyApiErrorType.notConfigured);
    }
    final basePath =
        _baseUri.path.endsWith('/')
            ? _baseUri.path.substring(0, _baseUri.path.length - 1)
            : _baseUri.path;
    final uri = _baseUri.replace(
      path: '$basePath$path',
      queryParameters: query,
    );

    final http.Response response;
    try {
      // Key goes in a header, not the URL, so it never lands in URL logs.
      response = await _http
          .get(
            uri,
            headers: {'X-API-Key': _apiKey, 'Accept': 'application/json'},
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const CurrencyApiException(CurrencyApiErrorType.network);
    } on http.ClientException {
      throw const CurrencyApiException(CurrencyApiErrorType.network);
    }

    final status = response.statusCode;
    if (status != 200) {
      throw CurrencyApiException(_errorTypeFor(status), statusCode: status);
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      // Falls through to invalidResponse.
    }
    throw const CurrencyApiException(CurrencyApiErrorType.invalidResponse);
  }

  static CurrencyApiErrorType _errorTypeFor(int status) => switch (status) {
    401 || 403 => CurrencyApiErrorType.unauthorized,
    429 => CurrencyApiErrorType.rateLimited,
    >= 400 && < 500 => CurrencyApiErrorType.badRequest,
    _ => CurrencyApiErrorType.server,
  };
}

final fastForexApiClientProvider = Provider<FastForexApiClient>((ref) {
  final httpClient = http.Client();
  ref.onDispose(httpClient.close);
  return FastForexApiClient(httpClient: httpClient);
});
