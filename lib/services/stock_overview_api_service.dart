import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class StockOverviewApiService {
  static const String _apiKey = "ct318m9r01qkff71167gct318m9r01qkff711680";
  static const String _baseUrl = "https://finnhub.io/api/v1";
  WebSocketChannel? _channel;

  Future<Map<String, dynamic>> fetchQuote(String symbol) async {
    final url = Uri.parse("$_baseUrl/quote?symbol=$symbol&token=$_apiKey");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load quote for $symbol");
    }
  }

  Future<List<double>> fetchStockCandleData(String symbol) async {
    final now = DateTime.now();
    final oneMonthAgo = now.subtract(const Duration(days: 30));

    final url = Uri.parse(
        "$_baseUrl/stock/candle?symbol=$symbol&resolution=D&from=${oneMonthAgo.millisecondsSinceEpoch ~/ 1000}&to=${now.millisecondsSinceEpoch ~/ 1000}&token=$_apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['s'] == 'ok') {
        return List<double>.from(data['c']); // Closing prices
      }
      throw Exception("No candle data available for $symbol");
    } else {
      throw Exception("Failed to fetch candle data for $symbol");
    }
  }

  WebSocketChannel connectRealTimeTrades(String symbol) {
    try {
      final String websocketUrl = 'wss://ws.finnhub.io?token=$_apiKey';
      _channel = WebSocketChannel.connect(Uri.parse(websocketUrl));
      _channel!.sink.add('{"type":"subscribe","symbol":"$symbol"}');
      return _channel!;
    } catch (e) {
      throw Exception('Failed to connect to WebSocket: $e');
    }
  }

  void closeConnection(dynamic status) {
    _channel?.sink.close(status.normalClosure);
  }
}
