import 'dart:convert';
import 'dart:io';

import 'package:expenser/data/repositories/exchange_rate_repository.dart';
import 'package:expenser/models/exchange_rates.dart';
import 'package:expenser/services/currency/currency_api_exception.dart';
import 'package:expenser/services/currency/fastforex_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _body = {
  'base': 'USD',
  'results': {'EUR': 0.9, 'GHS': 15.0, 'USD': 1},
  'updated': '2026-11-13T09:00:00Z',
  'ms': 4,
};

FastForexApiClient _client(
  MockClientHandler handler, {
  String apiKey = 'test-key',
  DateTime Function()? clock,
}) => FastForexApiClient(
  httpClient: MockClient(handler),
  apiKey: apiKey,
  baseUrl: 'https://api.example.test',
  clock: clock ?? DateTime.now,
);

Future<http.Response> _ok(http.Request _) async =>
    http.Response(jsonEncode(_body), 200);

Matcher _apiError(CurrencyApiErrorType type) =>
    isA<CurrencyApiException>().having((e) => e.type, 'type', type);

void main() {
  group('ExchangeRates', () {
    final rates = ExchangeRates.fromApiJson(
      _body,
      fetchedAt: DateTime.utc(2026),
    );

    test('computes cross rates through the base', () {
      expect(rates.rate('USD', 'GHS'), 15.0);
      expect(rates.rate('EUR', 'GHS'), closeTo(16.6667, 0.0001));
      expect(rates.rate('GHS', 'GHS'), 1);
      expect(rates.rate('USD', 'XXX'), isNull);
    });

    test('round-trips through cache JSON', () {
      final restored = ExchangeRates.fromCacheJson(
        jsonDecode(jsonEncode(rates.toCacheJson())) as Map<String, dynamic>,
      );
      expect(restored, rates);
    });
  });

  group('FastForexApiClient', () {
    test('sends key as header and parses fetch-all', () async {
      late http.Request sent;
      final client = _client((request) {
        sent = request;
        return _ok(request);
      });

      final rates = await client.fetchAll(base: 'USD');

      expect(sent.url.path, '/fetch-all');
      expect(sent.url.queryParameters, {'from': 'USD'});
      expect(sent.url.query, isNot(contains('test-key')));
      expect(sent.headers['X-API-Key'], 'test-key');
      expect(rates.rates['GHS'], 15.0);
      expect(rates.updatedAt, DateTime.utc(2026, 11, 13, 9));
    });

    test('fails fast without an API key', () {
      final client = _client(
        (_) => fail('should not call network'),
        apiKey: '',
      );
      expect(
        client.fetchAll(base: 'USD'),
        throwsA(_apiError(CurrencyApiErrorType.notConfigured)),
      );
    });

    final statusCases = {
      401: CurrencyApiErrorType.unauthorized,
      403: CurrencyApiErrorType.unauthorized,
      429: CurrencyApiErrorType.rateLimited,
      400: CurrencyApiErrorType.badRequest,
      503: CurrencyApiErrorType.server,
    };
    statusCases.forEach((status, type) {
      test('maps HTTP $status to ${type.name}', () {
        final client = _client((_) async => http.Response('{}', status));
        expect(client.fetchAll(base: 'USD'), throwsA(_apiError(type)));
      });
    });

    test('maps transport failures to network', () {
      final client = _client((_) => throw http.ClientException('offline'));
      expect(
        client.fetchAll(base: 'USD'),
        throwsA(_apiError(CurrencyApiErrorType.network)),
      );
    });

    test('maps malformed bodies to invalidResponse', () {
      final client = _client((_) async => http.Response('not json', 200));
      expect(
        client.fetchAll(base: 'USD'),
        throwsA(_apiError(CurrencyApiErrorType.invalidResponse)),
      );
    });
  });

  group('ExchangeRateRepository', () {
    late Directory hiveDir;
    late Box<String> box;
    var now = DateTime.utc(2026, 11, 13, 10);
    var calls = 0;
    var fail = false;

    ExchangeRateRepository repository() => ExchangeRateRepository(
      client: _client((request) async {
        calls++;
        if (fail) throw http.ClientException('offline');
        return _ok(request);
      }, clock: () => now),
      cacheBox: box,
      clock: () => now,
    );

    setUp(() async {
      hiveDir = await Directory.systemTemp.createTemp('fx_test');
      Hive.init(hiveDir.path);
      box = await Hive.openBox<String>(
        'fx_${DateTime.now().microsecondsSinceEpoch}',
      );
      now = DateTime.utc(2026, 11, 13, 10);
      calls = 0;
      fail = false;
    });

    tearDown(() async {
      await Hive.close();
      await hiveDir.delete(recursive: true);
    });

    test('serves cache within TTL without a network call', () async {
      final repo = repository();
      await repo.getRates();
      now = now.add(const Duration(minutes: 30));
      final result = await repo.getRates();
      expect(calls, 1);
      expect(result.isStale, isFalse);
    });

    test('refetches after TTL expires', () async {
      final repo = repository();
      await repo.getRates();
      now = now.add(const Duration(hours: 2));
      await repo.getRates();
      expect(calls, 2);
    });

    test('falls back to stale cache when refresh fails', () async {
      final repo = repository();
      await repo.getRates();
      now = now.add(const Duration(hours: 2));
      fail = true;
      final result = await repo.getRates();
      expect(result.isStale, isTrue);
      expect(result.rates.rates['GHS'], 15.0);
    });

    test('throws when there is no cache and the fetch fails', () {
      fail = true;
      expect(
        repository().getRates(),
        throwsA(_apiError(CurrencyApiErrorType.network)),
      );
    });

    test('throttles forced refreshes inside the minimum interval', () async {
      final repo = repository();
      await repo.getRates();
      await repo.getRates(forceRefresh: true);
      expect(calls, 1);
      now = now.add(const Duration(minutes: 2));
      await repo.getRates(forceRefresh: true);
      expect(calls, 2);
    });

    test('shares one request between concurrent callers', () async {
      final repo = repository();
      await Future.wait([repo.getRates(), repo.getRates()]);
      expect(calls, 1);
    });
  });
}
