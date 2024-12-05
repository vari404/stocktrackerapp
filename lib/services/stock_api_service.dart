import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class StockApiService {
  static const String _apiKey = 'ct318m9r01qkff71167gct318m9r01qkff711680';
  static const String _baseUrl = 'https://finnhub.io/api/v1';
  static const String _websocketUrl = 'wss://ws.finnhub.io';

  // WebSocket channel for real-time updates
  static late WebSocketChannel _channel;

  // Fetch all stock symbols
  static Future<List<String>> fetchAllStockSymbols() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/stock/symbol?exchange=US&token=$_apiKey'),
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((symbolData) => symbolData['symbol'] as String)
            .toList();
      } catch (e) {
        throw FormatException('Failed to decode JSON: $e');
      }
    } else {
      throw Exception(
          'Failed to load stock symbols. Status Code: ${response.statusCode}');
    }
  }

  // Fetch stock overview (price, change, etc.) for a single stock symbol
  static Future<Map<String, dynamic>> fetchStockOverview(String symbol) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/quote?symbol=$symbol&token=$_apiKey'),
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        return {
          'symbol': symbol,
          'price': data['c'], // Current price
          'high': data['h'], // High price of the day
          'low': data['l'], // Low price of the day
          'open': data['o'], // Open price
          'change': data['d'], // Price change
          'percentChange': data['dp'], // Percentage change
        };
      } catch (e) {
        throw FormatException('Failed to decode JSON: $e');
      }
    } else {
      throw Exception(
          'Failed to load stock overview for $symbol. Status Code: ${response.statusCode}');
    }
  }

  // Subscribe to real-time updates for stock prices
  static Stream<Map<String, dynamic>> subscribeToRealTimeUpdates(
      String symbol) {
    _channel =
        WebSocketChannel.connect(Uri.parse('$_websocketUrl?token=$_apiKey'));

    // Send subscription message
    _channel.sink.add(jsonEncode({'type': 'subscribe', 'symbol': symbol}));

    // Listen for real-time updates
    return _channel.stream.map((event) {
      final data = jsonDecode(event as String);
      return {
        'symbol': data['s'], // Symbol
        'price': data['p'], // Current price
        'time': data['t'], // Timestamp
      };
    });
  }

  // Close WebSocket connection
  static void closeWebSocketConnection() {
    _channel.sink.close();
  }

  static fetchTrendingStocks() {}
}
