/// Typed model for the Open Exchange Rates API response.
///
/// JSON shape (https://open.er-api.com/v6/latest/PHP):
/// {
///   "result": "success",
///   "base_code": "PHP",
///   "time_last_update_utc": "Wed, 18 Mar 2026 00:02:31 +0000",
///   "rates": { "USD": 0.0174, "EUR": 0.016, ... }
/// }
class ExchangeRate {
  final String result;
  final String baseCode;
  final String lastUpdated;
  final Map<String, double> rates;

  const ExchangeRate({
    required this.result,
    required this.baseCode,
    required this.lastUpdated,
    required this.rates,
  });

  bool get isSuccess => result == 'success';

  /// Returns the rate for [currency], or `null` if not found.
  double? rateFor(String currency) => rates[currency.toUpperCase()];

  /// Convenience: convert [phpAmount] to [currency].
  double? convert(double phpAmount, String currency) {
    final r = rateFor(currency);
    return r == null ? null : phpAmount * r;
  }

  // ── JSON parsing ──────────────────────────────────────────────────────────
  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    // Safely coerce the nested "rates" map to Map<String, double>
    final rawRates = json['rates'] as Map<String, dynamic>? ?? {};
    final parsedRates = rawRates.map(
      (k, v) => MapEntry(k, (v as num).toDouble()),
    );

    return ExchangeRate(
      result      : json['result']             as String? ?? '',
      baseCode    : json['base_code']          as String? ?? 'PHP',
      lastUpdated : json['time_last_update_utc'] as String? ?? '',
      rates       : parsedRates,
    );
  }

  Map<String, dynamic> toJson() => {
    'result'               : result,
    'base_code'            : baseCode,
    'time_last_update_utc' : lastUpdated,
    'rates'                : rates,
  };

  @override
  String toString() =>
      'ExchangeRate(base: $baseCode, rateCount: ${rates.length}, updated: $lastUpdated)';
}
