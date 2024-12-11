import 'package:flutter/foundation.dart';
import '../models/stock_model.dart';
import '../services/stock_api_service.dart';

class StockProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<StockModel> _stocks = [];
  List<StockModel> get stocks => _stocks;

  Future<void> fetchStocks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final symbols = await StockApiService.fetchAllStockSymbols();
      final fetchedStocks = <StockModel>[];

      // Limit the number of symbols for testing or remove the .take(10) in production
      for (final symbol in symbols.take(10)) {
        final overview = await StockApiService.fetchStockOverview(symbol);
        fetchedStocks.add(
          StockModel(
            symbol: overview['symbol'],
            price: (overview['price'] as num).toDouble(),
            high: (overview['high'] as num).toDouble(),
            low: (overview['low'] as num).toDouble(),
            open: (overview['open'] as num).toDouble(),
            change: (overview['change'] as num).toDouble(),
            percentChange: (overview['percentChange'] as num).toDouble(),
          ),
        );
      }

      _stocks = fetchedStocks;
    } catch (e) {
      // Handle or log error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
