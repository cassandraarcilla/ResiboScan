import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/exchange_rate_model.dart';

class ApiService {
  // ── Configuration ──────────────────────────────────────────────────────────
  static const String _goodUrl      = 'https://open.er-api.com/v6/latest';
  static const String _badUrl       = 'https://open.er-api.com/v6/WRONG_ENDPOINT';
  static const String _baseCurrency = 'PHP';
  static const Duration _timeout    = Duration(seconds: 12);

  // ── Runtime test flags (toggled via debug button in UI) ────────────────────
  static bool simulateError = false; // uses wrong URL → real 404
  static bool simulateNoNet = false; // skips request → mimics no internet

  // ── Public API ─────────────────────────────────────────────────────────────
  static Future<ExchangeRate> fetchExchangeRates() async {
    // Simulate no internet — skip the request entirely
    if (simulateNoNet) {
      await Future.delayed(const Duration(seconds: 1));
      throw const ApiException(
        'No internet connection. Please check your network.',
      );
    }

    // Simulate wrong URL — hits a real 404 from the server
    final url = simulateError
        ? '$_badUrl/$_baseCurrency'
        : '$_goodUrl/$_baseCurrency';

    final raw = await _get(url);
    return ExchangeRate.fromJson(raw);
  }

  static Future<Map<String, dynamic>> scanReceiptOcr(Uint8List imageBytes) async {
    final String base64Image = base64Encode(imageBytes);
    final url = Uri.parse('http://YOUR_SERVER_IP:5000/scan');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image_base64': base64Image}),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException('Failed to scan receipt. HTTP Status: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('OCR Request failed: $e');
    }
  }

  // ── Low-level GET ──────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> _get(String url) async {
    late http.Response response;

    try {
      response = await http
          .get(Uri.parse(url))
          .timeout(_timeout);
    } on TimeoutException {
      throw const ApiException(
        'Request timed out. Check your internet connection.',
      );
    } catch (e) {
      // Flutter Web surfaces network failures as generic ClientException.
      // We inspect the message to show something useful.
      final msg = e.toString().toLowerCase();
      if (msg.contains('failed host lookup') ||
          msg.contains('network') ||
          msg.contains('connection') ||
          msg.contains('socketexception') ||
          msg.contains('errno = 7') ||
          msg.contains('no address')) {
        throw const ApiException(
          'No internet connection. Please check your network.',
        );
      }
      throw ApiException('Request failed: $e');
    }

    // HTTP status check
    if (response.statusCode != 200) {
      throw ApiException(
        'Server error ${response.statusCode}: ${response.reasonPhrase}',
        statusCode: response.statusCode,
      );
    }

    // JSON decode
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object.');
      }
      return decoded;
    } on FormatException catch (e) {
      throw ApiException('Invalid response from server: ${e.message}');
    }
  }
}

// ── Custom exception ────────────────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int?   statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($message)';
}