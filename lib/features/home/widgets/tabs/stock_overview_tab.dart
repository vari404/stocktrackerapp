import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stocktrackerapp/services/stock_overview_api_service.dart';
import 'package:stocktrackerapp/features/home/widgets/stock_card.dart';

class StockOverviewTab extends StatefulWidget {
  const StockOverviewTab({Key? key}) : super(key: key);

  @override
  _StockOverviewTabState createState() => _StockOverviewTabState();
}

class _StockOverviewTabState extends State<StockOverviewTab>
    with SingleTickerProviderStateMixin {
  final StockOverviewApiService _apiService = StockOverviewApiService();
  final List<Map<String, dynamic>> _stocks = [];
  final StreamController<Map<String, dynamic>> _realTimeStreamController =
      StreamController.broadcast();

  late StreamSubscription _webSocketSubscription;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this); // Ensure matching tab count
    _loadStocks();
  }

  @override
  void dispose() {
    _realTimeStreamController.close();
    _webSocketSubscription.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _loadStocks() async {
    final symbols = ['AAPL', 'GOOGL', 'MSFT']; // Example symbols

    for (var symbol in symbols) {
      try {
        final financials = await _apiService.fetchBasicFinancials(symbol);
        final price = financials['metric']['lastPrice'] ?? 0.0;
        final changePercent = financials['metric']['percentChange'] ?? 0.0;
        final historicalData = await _apiService.fetchStockCandleData(symbol);

        setState(() {
          _stocks.add({
            'symbol': symbol,
            'companyName': financials['symbol'],
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

    _webSocketSubscription = channel.stream.listen((message) {
      final data = jsonDecode(message);

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
    });
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
                final index = _stocks
                    .indexWhere((stock) => stock['symbol'] == update['symbol']);
                if (index != -1) {
                  _stocks[index]['price'] = update['price'];
                }
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
