import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ── Selected API Endpoint ─────────────────────────────────────────────────
  static const String apiEndpoint = 'https://open.er-api.com/v6/latest/PHP';

  static Future<Map<String, dynamic>> fetchData() async {
    final response = await http
        .get(Uri.parse(apiEndpoint))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch data (${response.statusCode})');
    }
  }
}