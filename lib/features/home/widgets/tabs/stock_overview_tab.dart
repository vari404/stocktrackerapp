import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stocktrackerapp/services/stock_overview_api_service.dart';
import 'package:stocktrackerapp/features/home/widgets/stock_card.dart';

class StockOverviewTab extends StatefulWidget {
  const StockOverviewTab({Key? key}) : super(key: key);

  @override
  State<StockOverviewTab> createState() => _StockOverviewTabState();
}

class _StockOverviewTabState extends State<StockOverviewTab> with SingleTickerProviderStateMixin {
  final StockOverviewApiService _apiService = StockOverviewApiService();
  final List<Map<String, dynamic>> _stocks = [];
  final StreamController<Map<String, dynamic>> _realTimeStreamController = StreamController.broadcast();
  late TabController _tabController;

  // We'll store multiple subscriptions here if we subscribe to multiple symbols.
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStocks();
  }

  @override
  void dispose() {
    // Cancel all subscriptions
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();

    _realTimeStreamController.close();
    _tabController.dispose();
    super.dispose();
  }

  void _loadStocks() async {
    // Just a few example symbols to test
    final symbols = ['AAPL', 'GOOGL', 'MSFT'];

    for (var symbol in symbols) {
      try {
        final financials = await _apiService.fetchBasicFinancials(symbol);

        // Print the fetched financials for troubleshooting
        debugPrint("Financials for $symbol: $financials");

        // Adjust keys if needed based on what your API returns
        final price = (financials['metric']?['lastPrice'] ?? 0.0) as double;
        final changePercent = (financials['metric']?['percentChange'] ?? 0.0) as double;
        final historicalData = await _apiService.fetchStockCandleData(symbol);

        debugPrint("Historical data for $symbol: $historicalData");

        setState(() {
          _stocks.add({
            'symbol': symbol,
            'companyName': financials['symbol'] ?? symbol,
            'price': price,
            'changePercent': changePercent,
            'historicalData': historicalData,
          });
        });

        _startRealTimeUpdates(symbol);
      } catch (e) {
        debugPrint("Error fetching data for $symbol: $e");
      }
    }
  }

  void _startRealTimeUpdates(String symbol) {
    final channel = _apiService.connectRealTimeTrades(symbol);

    // Listen to the WebSocket stream for real-time updates
    final subscription = channel.stream.listen((rawEvent) {
      // If the incoming data is a string, decode it
      final data = rawEvent is String ? jsonDecode(rawEvent) : rawEvent;

      if (data['type'] == 'trade' && data['data'] != null) {
        final updates = data['data'];
        for (var update in updates) {
          if (update['s'] == symbol) {
            _realTimeStreamController.add({
              'symbol': symbol,
              'price': update['p'],
              'volume': update['v'],
            });
          }
        }
      }
    }, onError: (error) {
      debugPrint("WebSocket error for $symbol: $error");
    });

    _subscriptions.add(subscription);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock Overview"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Stocks"),
            Tab(text: "Charts"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          StreamBuilder<Map<String, dynamic>>(
            stream: _realTimeStreamController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final update = snapshot.data!;
                final index = _stocks.indexWhere((stock) => stock['symbol'] == update['symbol']);
                if (index != -1) {
                  setState(() {
                    _stocks[index]['price'] = update['price'];
                  });
                }
              }

              if (_stocks.isEmpty) {
                return const Center(child: Text("No stocks available or still loading..."));
              }

              return ListView.builder(
                itemCount: _stocks.length,
                itemBuilder: (context, index) {
                  final stock = _stocks[index];
                  return StockCard(
                    symbol: stock['symbol'],
                    companyName: stock['companyName'],
                    price: stock['price'],
                    changePercent: stock['changePercent'],
                    historicalData: stock['historicalData'],
                  );
                },
              );
            },
          ),
          const Center(child: Text("Charts View (Optional placeholder)")),
        ],
      ),
    );
  }
}

