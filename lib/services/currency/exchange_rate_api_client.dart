import 'dart:async';
import 'dart:convert';

import 'package:expenser/core/config/exchange_rate_api_config.dart';
import 'package:expenser/models/exchange_rates.dart';
import 'package:expenser/services/currency/currency_api_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Thin HTTP client for ExchangeRate-API. Throws [CurrencyApiException] only.
class ExchangeRateApiClient {
  ExchangeRateApiClient({
    required http.Client httpClient,
    String baseUrl = ExchangeRateApiConfig.baseUrl,
    Duration timeout = ExchangeRateApiConfig.requestTimeout,
    DateTime Function() clock = DateTime.now,
  }) : _http = httpClient,
       _baseUri = Uri.parse(baseUrl),
       _timeout = timeout,
       _clock = clock;

  final http.Client _http;
  final Uri _baseUri;
  final Duration _timeout;
  final DateTime Function() _clock;

  Future<ExchangeRates> fetchAll({required String base}) async {
    final json = await _get('/v6/latest/${Uri.encodeComponent(base)}');
    if (json['result'] != 'success') {
      throw CurrencyApiException(_errorTypeForResult(json['error-type']));
    }
    try {
      return ExchangeRates.fromApiJson(json, fetchedAt: _clock());
    } on FormatException {
      throw const CurrencyApiException(CurrencyApiErrorType.invalidResponse);
    }
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final basePath =
        _baseUri.path.endsWith('/')
            ? _baseUri.path.substring(0, _baseUri.path.length - 1)
            : _baseUri.path;
    final uri = _baseUri.replace(path: '$basePath$path');

    final http.Response response;
    try {
      response = await _http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);
    } on TimeoutException {
      throw const CurrencyApiException(CurrencyApiErrorType.network);
    } on http.ClientException {
      throw const CurrencyApiException(CurrencyApiErrorType.network);
    }

    final status = response.statusCode;
    if (status != 200) {
      throw CurrencyApiException(
        _errorTypeForStatus(status),
        statusCode: status,
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      // Falls through to invalidResponse.
    }
    throw const CurrencyApiException(CurrencyApiErrorType.invalidResponse);
  }

  static CurrencyApiErrorType _errorTypeForStatus(int status) =>
      switch (status) {
        401 || 403 => CurrencyApiErrorType.unauthorized,
        429 => CurrencyApiErrorType.rateLimited,
        >= 400 && < 500 => CurrencyApiErrorType.badRequest,
        _ => CurrencyApiErrorType.server,
      };

  static CurrencyApiErrorType _errorTypeForResult(Object? errorType) =>
      switch (errorType) {
        'unsupported-code' ||
        'malformed-request' => CurrencyApiErrorType.badRequest,
        null => CurrencyApiErrorType.invalidResponse,
        _ => CurrencyApiErrorType.server,
      };
}

final exchangeRateApiClientProvider = Provider<ExchangeRateApiClient>((ref) {
  final httpClient = http.Client();
  ref.onDispose(httpClient.close);
  return ExchangeRateApiClient(httpClient: httpClient);
});
