// lib/services/search_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchApiService {
  static const String _baseUrl = "https://finnhub.io/api/v1/search";
  static const String _apiKey = "ctcf6d1r01qjor98f3hgctcf6d1r01qjor98f3i0";

  Future<List<Map<String, String>>> searchSymbols(String query) async {
    final url = Uri.parse("$_baseUrl?q=$query&token=$_apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['result'] as List<dynamic>;

      return results
          .map((item) => {
                "symbol": item['symbol'] as String,
                "description": item['description'] as String,
              })
          .toList();
    } else {
      throw Exception("Failed to fetch symbols: ${response.reasonPhrase}");
    }
  }
}
