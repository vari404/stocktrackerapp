import 'package:flutter/material.dart';
import 'package:stocktrackerapp/features/home/widgets/stock_card.dart';
import 'package:stocktrackerapp/features/home/widgets/tabs/stock_overview_details.dart';
import 'package:stocktrackerapp/services/search_epi_service.dart';
import 'package:stocktrackerapp/services/stocks_api_service.dart';
import 'package:stocktrackerapp/services/stock_overview_api_service.dart';

class StockOverviewTab extends StatefulWidget {
  const StockOverviewTab({Key? key}) : super(key: key);

  @override
  _StockOverviewTabState createState() => _StockOverviewTabState();
}

class _StockOverviewTabState extends State<StockOverviewTab> {
  final StocksApiService _stocksApiService = StocksApiService();
  final StockOverviewApiService _apiService = StockOverviewApiService();
  final SearchApiService _searchApiService = SearchApiService();

  late Stream<Map<String, Map<String, dynamic>>> _stockStream;
  final Map<String, Map<String, dynamic>> _stockData = {};
  List<String> _symbols = [];
  List<String> _filteredSymbols = [];

  List<Map<String, String>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _initializeStocks();
  }

  Future<void> _initializeStocks() async {
    try {
      final allSymbols = await _stocksApiService.getStockSymbols();

      if (allSymbols.isNotEmpty) {
        setState(() {
          _symbols = allSymbols;
          _filteredSymbols = allSymbols; // Initially display all symbols
        });

        // Start the WebSocket connection
        _stockStream = _apiService.connectRealTimeUpdates(_symbols);
        _stockStream.listen((data) {
          setState(() {
            _stockData.addAll(data);
          });
        });
      } else {
        // Handle the case where no symbols are found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No stock symbols found in Firestore.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing stocks: $e')),
      );
    }
  }

  void _onSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    try {
      final results = await _searchApiService.searchSymbols(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    }
  }

  void _addSymbol(String symbol) {
    if (!_symbols.contains(symbol)) {
      setState(() {
        _symbols.add(symbol);
        _filteredSymbols = _symbols;
        _stockStream = _apiService.connectRealTimeUpdates(_symbols);
      });
    }
  }

  @override
  void dispose() {
    _apiService.closeWebSocketConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search Stocks',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _onSearch,
          ),
        ),
        if (_searchResults.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return ListTile(
                  title: Text(result['symbol']!),
                  subtitle: Text(result['description']!),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StockOverviewDetails(symbol: result['symbol']!),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        if (_searchResults.isEmpty)
          Expanded(
            child: _filteredSymbols.isEmpty
                ? const Center(child: Text('No results found.'))
                : ListView.builder(
                    itemCount: _filteredSymbols.length,
                    itemBuilder: (context, index) {
                      final symbol = _filteredSymbols[index];
                      final stock = _stockData[symbol];
                      if (stock == null) return const SizedBox.shrink();
                      return StockCard(
                        symbol: stock['symbol'] as String,
                        price: stock['price'] as double,
                        change: stock['change'] as double,
                        volume: stock['volume'] as int,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StockOverviewDetails(
                                  symbol: stock['symbol'] as String),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
      ],
    );
  }
}
