import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class StockOverviewApiService {
  static const String _apiKey = "ct318m9r01qkff71167gct318m9r01qkff711680";
  static const String _webSocketUrl = "wss://ws.finnhub.io";
  WebSocketChannel? _webSocketChannel;

  // Connect to WebSocket for real-time updates
  Stream<Map<String, Map<String, dynamic>>> connectRealTimeUpdates(
      List<String> symbols) {
    _webSocketChannel ??=
        WebSocketChannel.connect(Uri.parse("$_webSocketUrl?token=$_apiKey"));

    // Subscribe to the stock symbols
    for (var symbol in symbols) {
      _webSocketChannel!.sink
          .add(jsonEncode({"type": "subscribe", "symbol": symbol}));
    }

    return _webSocketChannel!.stream.map((message) {
      final data = jsonDecode(message) as Map<String, dynamic>;
      if (data['type'] == 'trade') {
        final trades = <String, Map<String, dynamic>>{};
        for (var trade in data['data'] as List<dynamic>) {
          trades[trade['s']] = {
            'symbol': trade['s'] as String,
            'price': (trade['p'] as num).toDouble(),
            'change': (trade['p'] as num).toDouble() *
                0.01, // Example change calculation
            'volume': trade['v'] as int,
          };
        }
        return trades;
      }
      return {};
    });
  }

  // Close WebSocket connection
  void closeWebSocketConnection() {
    _webSocketChannel?.sink.close();
  }
}
