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

  // Store all subscriptions for multiple symbols if needed
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStocks();
  }

  @override
  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();

    _realTimeStreamController.close();
    _tabController.dispose();
    super.dispose();
  }

  void _loadStocks() async {
    // Some example symbols:
    final symbols = ['AAPL', 'GOOGL', 'MSFT'];

    for (var symbol in symbols) {
      try {
        // Fetch quote data for price and percent change
        final quoteData = await _apiService.fetchQuote(symbol);
        debugPrint('Quote for $symbol: $quoteData');

        final price = quoteData['c'] ?? 0.0;
        final percentChange = quoteData['dp'] ?? 0.0;

        // Fetch candle data for historical info
        final historicalData = await _apiService.fetchStockCandleData(symbol);
        debugPrint('Candle data for $symbol: $historicalData');

        setState(() {
          _stocks.add({
            'symbol': symbol,
            'companyName': symbol, // Replace with a proper name if needed
            'price': price,
            'changePercent': percentChange,
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

    final subscription = channel.stream.listen((rawEvent) {
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
