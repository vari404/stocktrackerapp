import 'package:flutter/material.dart';
import 'package:stocktrackerapp/models/stock_model.dart';
import 'package:stocktrackerapp/services/stock_api_service.dart';
import 'package:stocktrackerapp/services/stock_overview_api_service.dart';
import 'widgets/stock_chart.dart';
import 'widgets/stock_info.dart';

class StockDetailsScreen extends StatefulWidget {
  final String symbol;
  const StockDetailsScreen({Key? key, required this.symbol}) : super(key: key);

  @override
  State<StockDetailsScreen> createState() => _StockDetailsScreenState();
}

class _StockDetailsScreenState extends State<StockDetailsScreen> {
  late Future<Map<String, dynamic>> _overviewFuture;
  late Future<List<double>> _candleFuture;
  final _stockOverviewApiService = StockOverviewApiService();

  @override
  void initState() {
    super.initState();
    _overviewFuture = StockApiService.fetchStockOverview(widget.symbol);
    _candleFuture = _stockOverviewApiService.fetchStockCandleData(widget.symbol);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
      ),
      body: FutureBuilder(
        future: Future.wait([_overviewFuture, _candleFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.hasError) {
            return const Center(child: Text('Error loading stock details'));
          }
          final results = snapshot.data as List<dynamic>;
          final overview = results[0] as Map<String, dynamic>;
          final candles = results[1] as List<double>;
          final stock = StockModel(
            symbol: overview['symbol'],
            price: (overview['price'] as num).toDouble(),
            high: (overview['high'] as num).toDouble(),
            low: (overview['low'] as num).toDouble(),
            open: (overview['open'] as num).toDouble(),
            change: (overview['change'] as num).toDouble(),
            percentChange: (overview['percentChange'] as num).toDouble(),
          );
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StockInfo(stock: stock),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: candles.isNotEmpty
                        ? StockChart(data: candles)
                        : const Center(child: Text('No chart data')),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
