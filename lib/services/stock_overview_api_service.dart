import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class StockOverviewApiService {
  static const String _apiKey = "ct318m9r01qkff71167gct318m9r01qkff711680";
  static const String _baseUrl = "https://finnhub.io/api/v1";

  // Fetch Basic Financials
  Future<Map<String, dynamic>> fetchBasicFinancials(String symbol) async {
    final url = Uri.parse(
        "$_baseUrl/stock/metric?symbol=$symbol&metric=all&token=$_apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch financials for $symbol");
    }
  }

  // Fetch Market Status
  Future<Map<String, dynamic>> fetchMarketStatus(String exchange) async {
    final url = Uri.parse(
        "$_baseUrl/stock/market-status?exchange=$exchange&token=$_apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch market status for $exchange");
    }
  }

  // Open WebSocket for real-time trades
  WebSocketChannel? _channel;

  WebSocketChannel connectRealTimeTrades(String symbol) {
    try {
      final String websocketUrl =
          'wss://ws.finnhub.io?token=ct318m9r01qkff71167gct318m9r01qkff711680';

      _channel = WebSocketChannel.connect(Uri.parse(websocketUrl));

      // Subscribe to the symbol
      _channel!.sink.add('{"type":"subscribe","symbol":"$symbol"}');
      return _channel!;
    } catch (e) {
      throw Exception('Failed to connect to WebSocket: $e');
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
      throw Exception("No data available for $symbol");
    } else {
      throw Exception("Failed to fetch candle data for $symbol");
    }
  }

  void closeConnection(dynamic status) {
    _channel?.sink.close(status.normalClosure);
  }
}
