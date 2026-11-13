import 'package:equatable/equatable.dart';

/// Mid-market rates for one base currency, as returned by `/fetch-all`.
class ExchangeRates extends Equatable {
  const ExchangeRates({
    required this.base,
    required this.rates,
    required this.updatedAt,
    required this.fetchedAt,
  });

  final String base;

  /// Units of each currency per one unit of [base].
  final Map<String, double> rates;

  /// When the provider last updated the rates (UTC).
  final DateTime updatedAt;

  /// When this device received the rates (UTC); drives cache expiry.
  final DateTime fetchedAt;

  bool supports(String code) => code == base || rates.containsKey(code);

  /// Cross rate: units of [to] per one unit of [from]; null if unsupported.
  double? rate(String from, String to) {
    if (from == to) return 1;
    final fromRate = from == base ? 1.0 : rates[from];
    final toRate = to == base ? 1.0 : rates[to];
    if (fromRate == null || toRate == null || fromRate == 0) return null;
    return toRate / fromRate;
  }

  /// Parses a fastFOREX `/fetch-all` response body.
  factory ExchangeRates.fromApiJson(
    Map<String, dynamic> json, {
    required DateTime fetchedAt,
  }) {
    final base = json['base'];
    final results = json['results'];
    final updated = json['updated'];
    if (base is! String || results is! Map || updated is! String) {
      throw const FormatException('Unexpected fetch-all response shape');
    }
    return ExchangeRates(
      base: base,
      rates: _parseRates(results),
      updatedAt: DateTime.parse(updated).toUtc(),
      fetchedAt: fetchedAt.toUtc(),
    );
  }

  factory ExchangeRates.fromCacheJson(Map<String, dynamic> json) {
    return ExchangeRates(
      base: json['base'] as String,
      rates: _parseRates(json['rates'] as Map),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    );
  }

  Map<String, dynamic> toCacheJson() => {
    'base': base,
    'rates': rates,
    'updatedAt': updatedAt.toIso8601String(),
    'fetchedAt': fetchedAt.toIso8601String(),
  };

  static Map<String, double> _parseRates(Map<dynamic, dynamic> raw) {
    return {
      for (final entry in raw.entries)
        if (entry.key is String && entry.value is num)
          entry.key as String: (entry.value as num).toDouble(),
    };
  }

  @override
  List<Object?> get props => [base, rates, updatedAt, fetchedAt];
}
