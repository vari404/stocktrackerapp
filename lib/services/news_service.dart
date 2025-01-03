import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  final String _apiKey = 'ctcf6d1r01qjor98f3hgctcf6d1r01qjor98f3i0';

  Future<List<Map<String, dynamic>>> fetchMarketNews(String category) async {
    final url = Uri.parse(
        'https://finnhub.io/api/v1/news?category=$category&token=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List news = json.decode(response.body);
      return news.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load market news');
    }
  }
}
