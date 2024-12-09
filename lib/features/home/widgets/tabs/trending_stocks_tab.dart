import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stocktrackerapp/features/home/widgets/tabs/trending_stocks_tab_details.dart';
import 'package:stocktrackerapp/features/home/widgets/trending_stocks_card.dart';
import 'package:stocktrackerapp/services/trending_stocks_api_service.dart';

class TrendingStocksTab extends StatefulWidget {
  const TrendingStocksTab({Key? key}) : super(key: key);

  @override
  _TrendingStocksTabState createState() => _TrendingStocksTabState();
}

class _TrendingStocksTabState extends State<TrendingStocksTab> {
  final TrendingStocksApiService _apiService = TrendingStocksApiService();
  List<Map<String, dynamic>> _trendingStocks = [];
  bool _isLoading = true;
  String _searchQuery = "";
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchTrendingStocks(); // Initial fetch of trending stocks
  }

  // Fetch trending stocks
  Future<void> _fetchTrendingStocks() async {
    setState(() {
      _isLoading = true;
      _trendingStocks = [];
      _errorMessage = "";
    });

    try {
      final displaySymbols = await _apiService.fetchAllDisplaySymbols();
      final limitedSymbols = displaySymbols.take(100).toList(); // Limit symbols

      final results = await Future.wait(
        limitedSymbols.map((symbol) async {
          try {
            final stockData =
                await _apiService.fetchStockRecommendation(symbol);
            return {
              'symbol': symbol,
              'buy': stockData['recommendations']['buy'],
              'hold': stockData['recommendations']['hold'],
              'sell': stockData['recommendations']['sell'],
              'strongBuy': stockData['recommendations']['strongBuy'],
              'strongSell': stockData['recommendations']['strongSell'],
            };
          } catch (e) {
            debugPrint("No recommendation data for $symbol: $e");
            return null; // Skip invalid symbols
          }
        }),
      );

      setState(() {
        _trendingStocks = results.whereType<Map<String, dynamic>>().toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error fetching trending stocks.";
      });
    }
  }

  // Search functionality when typing in the search bar
  Future<void> _searchTrendingStock(String query) async {
    setState(() {
      _searchQuery = query;
      _isLoading = true;
      _errorMessage = ""; // Reset error message during search
    });

    if (_searchQuery.isNotEmpty) {
      try {
        final stockData =
            await _apiService.fetchStockRecommendation(_searchQuery);
        setState(() {
          _trendingStocks = [
            {
              'symbol': _searchQuery,
              'buy': stockData['recommendations']['buy'],
              'hold': stockData['recommendations']['hold'],
              'sell': stockData['recommendations']['sell'],
              'strongBuy': stockData['recommendations']['strongBuy'],
              'strongSell': stockData['recommendations']['strongSell'],
            }
          ];
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No recommendation data for $_searchQuery.';
        });
      }
    } else {
      // If search query is empty, fetch the default trending stocks again
      _fetchTrendingStocks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trending Stocks"),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search for a stock symbol',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged:
                  _searchTrendingStock, // Trigger search when the query changes
            ),
          ),

          // Display loading spinner or error message
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage.isNotEmpty)
            Center(child: Text(_errorMessage))
          else if (_trendingStocks.isEmpty)
            const Center(child: Text("No trending stocks available."))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _trendingStocks.length,
                itemBuilder: (context, index) {
                  final stock = _trendingStocks[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the details screen and pass the stock data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrendingStocksTabDetails(
                            symbol: stock['symbol'],
                            buy: stock['buy'],
                            hold: stock['hold'],
                            sell: stock['sell'],
                            strongBuy: stock['strongBuy'],
                            strongSell: stock['strongSell'],
                          ),
                        ),
                      );
                    },
                    child: TrendingStocksCard(
                      symbol: stock['symbol'],
                      buy: stock['buy'],
                      hold: stock['hold'],
                      sell: stock['sell'],
                      strongBuy: stock['strongBuy'],
                      strongSell: stock['strongSell'],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
