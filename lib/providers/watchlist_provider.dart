import 'package:flutter/foundation.dart';

class WatchlistProvider with ChangeNotifier {
  List<String> _watchlist = [];
  List<String> get watchlist => _watchlist;

  void addToWatchlist(String symbol) {
    if (!_watchlist.contains(symbol)) {
      _watchlist.add(symbol);
      notifyListeners();
    }
  }

  void removeFromWatchlist(String symbol) {
    _watchlist.remove(symbol);
    notifyListeners();
  }
}
