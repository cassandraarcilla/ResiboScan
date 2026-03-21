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

  // Check kung success ang response galing sa API
  bool get isSuccess => result == 'success';

  // Kukunin yung specific rate base sa currency code 
  double? rateFor(String currency) => rates[currency.toUpperCase()];

  // Dito ginagawa yung conversion: PHP amount multiplied sa target rate
  double? convert(double phpAmount, String currency) {
    final r = rateFor(currency);
    return r == null ? null : phpAmount * r;
  }

  // Factory para i-transform yung raw JSON data papuntang ExchangeRate object
  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    // makes sures doubles values
    final rawRates = json['rates'] as Map<String, dynamic>? ?? {};
    final parsedRates = rawRates.map(
      (k, v) => MapEntry(k, (v as num).toDouble()),
    );

    return ExchangeRate(
      result: json['result'] as String? ?? '',
      baseCode: json['base_code'] as String? ?? 'PHP',
      lastUpdated: json['time_last_update_utc'] as String? ?? '',
      rates: parsedRates,
    );
  }

  // use this pag kailangan isave ulit yung data as JSON format
  Map<String, dynamic> toJson() => {
        'result': result,
        'base_code': baseCode,
        'time_last_update_utc': lastUpdated,
        'rates': rates,
      };

  @override
  String toString() =>
      'ExchangeRate(base: $baseCode, count: ${rates.length}, updated: $lastUpdated)';
}
