import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/exchange_rate_model.dart';

/// Centralised API service.
///
/// Currently wraps the Open Exchange Rates public endpoint to fetch
/// live PHP-based currency rates.  All HTTP and JSON work lives here
/// so the rest of the app stays decoupled from transport details.
class ApiService {
  // ── Configuration ─────────────────────────────────────────────────────────
  static const String _baseUrl    = 'https://open.er-api.com/v6/latest';
  static const String _baseCurrency = 'PHP';
  static const Duration _timeout  = Duration(seconds: 12);

  // ── Public API ────────────────────────────────────────────────────────────

  /// Fetches the latest exchange rates with PHP as the base currency.
  ///
  /// Returns a typed [ExchangeRate] on success.
  /// Throws an [ApiException] on any network or HTTP error.
  static Future<ExchangeRate> fetchExchangeRates() async {
    final raw = await _get('$_baseUrl/$_baseCurrency');
    return ExchangeRate.fromJson(raw);
  }

  /// Low-level helper: performs a GET request and returns the decoded JSON.
  ///
  /// Throws [ApiException] for:
  ///  - [SocketException]  — no internet / DNS failure
  ///  - [HttpException]    — non-200 status codes
  ///  - [FormatException]  — body is not valid JSON
  ///  - Timeout            — request exceeded [_timeout]
  static Future<Map<String, dynamic>> _get(String url) async {
    late http.Response response;

    try {
      response = await http
          .get(Uri.parse(url))
          .timeout(_timeout);
    } on SocketException catch (e) {
      throw ApiException(
        'No internet connection. Please check your network.',
        original: e,
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        'Network error: ${e.message}',
        original: e,
      );
    } catch (e) {
      // Covers TimeoutException and anything else
      throw ApiException('Request failed: $e', original: e);
    }

    // ── HTTP status check ──────────────────────────────────────────────────
    if (response.statusCode != 200) {
      throw ApiException(
        'Server returned ${response.statusCode}: ${response.reasonPhrase}',
        statusCode: response.statusCode,
      );
    }

    // ── JSON decoding ──────────────────────────────────────────────────────
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object at root level.');
      }
      return decoded;
    } on FormatException catch (e) {
      throw ApiException('Invalid JSON from server: ${e.message}', original: e);
    }
  }
}

// ── Custom exception ───────────────────────────────────────────────────────
/// Thrown by [ApiService] for any HTTP / network / parsing failure.
class ApiException implements Exception {
  final String message;
  final int?   statusCode;
  final Object? original;

  const ApiException(this.message, {this.statusCode, this.original});

  @override
  String toString() => 'ApiException($message)';
}
