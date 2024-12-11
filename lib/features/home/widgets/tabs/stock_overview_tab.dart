import 'package:flutter/material.dart';
import 'package:stocktrackerapp/features/home/widgets/stock_card.dart';
import 'package:stocktrackerapp/services/stock_overview_api_service.dart';
import 'package:stocktrackerapp/features/home/widgets/tabs/stock_overview_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StockOverviewTab extends StatefulWidget {
  const StockOverviewTab({Key? key}) : super(key: key);

  @override
  _StockOverviewTabState createState() => _StockOverviewTabState();
}

class _StockOverviewTabState extends State<StockOverviewTab> {
  final StockOverviewApiService _apiService = StockOverviewApiService();
  late Stream<Map<String, Map<String, dynamic>>> _stockStream;
  final Map<String, Map<String, dynamic>> _stockData = {};
  List<String> _symbols = [];
  List<String> _filteredSymbols = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchStockSymbols();
  }

  Future<void> _fetchStockSymbols() async {
    try {
      // Fetch stock symbols from Firestore
      final snapshot =
          await FirebaseFirestore.instance.collection('stocks').get();
      final symbols = snapshot.docs.map((doc) => doc.id).toList();

      if (symbols.isNotEmpty) {
        setState(() {
          _symbols = symbols;
          _filteredSymbols = symbols; // Initially display all symbols
        });

        // Start the WebSocket connection
        _stockStream = _apiService.connectRealTimeUpdates(symbols);
        _stockStream.listen((data) {
          setState(() {
            _stockData.addAll(data);
          });
        });
      } else {
        // Handle empty symbols case
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No stock symbols found in Firestore.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching stock symbols: $e')),
      );
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.trim();
      _filteredSymbols = _symbols
          .where((symbol) =>
              symbol.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _apiService.closeWebSocketConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_symbols.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredStocks = _filteredSymbols
        .map((symbol) => _stockData[symbol])
        .where((data) => data != null)
        .toList();

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
        Expanded(
          child: filteredStocks.isEmpty
              ? const Center(child: Text('No results found.'))
              : ListView.builder(
                  itemCount: filteredStocks.length,
                  itemBuilder: (context, index) {
                    final stock = filteredStocks[index]!;
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
