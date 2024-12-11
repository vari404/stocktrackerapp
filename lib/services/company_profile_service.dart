import 'dart:convert';
import 'package:http/http.dart' as http;

class CompanyProfileService {
  static const String _baseUrl = "https://finnhub.io/api/v1";
  static const String _apiKey = "ctcf6d1r01qjor98f3hgctcf6d1r01qjor98f3i0";

  Future<Map<String, dynamic>> fetchCompanyProfile(String symbol) async {
    final response = await http.get(
      Uri.parse("$_baseUrl/stock/profile2?symbol=$symbol&token=$_apiKey"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("Failed to load company profile");
    }
  }
}
