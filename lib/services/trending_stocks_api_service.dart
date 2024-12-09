import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class TrendingStocksApiService {
  static const String _apiKey = "ct318m9r01qkff71167gct318m9r01qkff711680";
  static const String _baseUrl = "https://finnhub.io/api/v1";
  WebSocketChannel? _webSocketChannel;

  // Fetch all display symbols from the US exchange
  Future<List<String>> fetchAllDisplaySymbols() async {
    final url = Uri.parse("$_baseUrl/stock/symbol?exchange=US&token=$_apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((stock) => stock['displaySymbol'] as String).toList();
    } else {
      throw Exception("Failed to fetch display symbols");
    }
  }

  // Fetch stock recommendation data
  Future<Map<String, dynamic>> fetchStockRecommendation(String symbol) async {
    final url = Uri.parse(
        "$_baseUrl/stock/recommendation?symbol=$symbol&token=$_apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      if (data.isNotEmpty) {
        return {
          'recommendations': {
            'strongBuy': data[0]['strongBuy'],
            'buy': data[0]['buy'],
            'hold': data[0]['hold'],
            'sell': data[0]['sell'],
            'strongSell': data[0]['strongSell'],
          },
        };
      } else {
        throw Exception("No recommendation data found for $symbol");
      }
    } else {
      throw Exception("Failed to fetch recommendations for $symbol");
    }
  }

  // Initialize the WebSocket connection
  WebSocketChannel connectRealTimeTrades(String symbol) {
    if (_webSocketChannel == null) {
      final String websocketUrl = 'wss://ws.finnhub.io?token=$_apiKey';

      _webSocketChannel = WebSocketChannel.connect(Uri.parse(websocketUrl));
      _webSocketChannel!.sink.add('{"type":"subscribe","symbol":"$symbol"}');
    }
    return _webSocketChannel!;
  }

  // Close the WebSocket connection safely
  void closeWebSocketConnection() {
    _webSocketChannel?.sink.close();
  }
}
