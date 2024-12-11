import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WatchlistApiService {
  final String _apiKey = 'ctcf6d1r01qjor98f3hgctcf6d1r01qjor98f3i0';
  late final WebSocketChannel _channel;

  WatchlistApiService() {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://ws.finnhub.io?token=$_apiKey'),
    );
  }

  void subscribeToSymbols(List<String> symbols) {
    for (var symbol in symbols) {
      final message = json.encode({'type': 'subscribe', 'symbol': symbol});
      _channel.sink.add(message);
    }
  }

  void unsubscribeFromSymbols(List<String> symbols) {
    for (var symbol in symbols) {
      final message = json.encode({'type': 'unsubscribe', 'symbol': symbol});
      _channel.sink.add(message);
    }
  }

  Stream<dynamic> get updates => _channel.stream.map((event) {
        return json.decode(event);
      });

  void dispose() {
    _channel.sink.close();
  }
}
