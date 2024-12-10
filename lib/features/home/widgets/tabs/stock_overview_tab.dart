import 'package:flutter/material.dart';
import 'package:stocktrackerapp/features/home/widgets/stock_card.dart';
import 'package:stocktrackerapp/services/stock_overview_api_service.dart';

class StockOverviewTab extends StatefulWidget {
  const StockOverviewTab({Key? key}) : super(key: key);

  @override
  _StockOverviewTabState createState() => _StockOverviewTabState();
}

class _StockOverviewTabState extends State<StockOverviewTab> {
  final StockOverviewApiService _apiService = StockOverviewApiService();
  late Stream<Map<String, Map<String, dynamic>>> _stockStream;
  final Map<String, Map<String, dynamic>> _stockData = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _stockStream = _apiService
        .connectRealTimeUpdates(["AAPL", "GOOGL", "AMZN"]); // Example symbols
    _stockStream.listen((data) {
      setState(() {
        _stockData.addAll(data);
      });
    });
  }

  @override
  void dispose() {
    _apiService.closeWebSocketConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStocks = _stockData.values
        .where((stock) => stock['symbol']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search Stocks',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.search),
            ),
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
          ),
        ),
        Expanded(
          child: filteredStocks.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: filteredStocks.length,
                  itemBuilder: (context, index) {
                    final stock = filteredStocks[index];
                    return StockCard(
                      symbol: stock['symbol'] as String,
                      price: stock['price'] as double,
                      change: stock['change'] as double,
                      volume: stock['volume'] as int,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
