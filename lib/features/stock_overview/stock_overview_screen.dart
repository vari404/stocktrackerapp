import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocktrackerapp/models/stock_model.dart';
import 'package:stocktrackerapp/providers/stock_provider.dart';
import 'package:stocktrackerapp/services/stock_overview_api_service.dart';
import 'package:stocktrackerapp/features/stock_details/widgets/stock_chart.dart';
import 'package:stocktrackerapp/features/stock_details/widgets/stock_info.dart';

class StockOverviewScreen extends StatefulWidget {
  const StockOverviewScreen({Key? key}) : super(key: key);

  @override
  State<StockOverviewScreen> createState() => _StockOverviewScreenState();
}

class _StockOverviewScreenState extends State<StockOverviewScreen> with SingleTickerProviderStateMixin {
  String? _selectedSymbol;
  Future<List<double>>? _candleFuture;
  final _stockOverviewApiService = StockOverviewApiService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    Provider.of<StockProvider>(context, listen: false).fetchStocks();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _selectStock(StockModel stock) {
    _selectedSymbol = stock.symbol;
    _candleFuture = _stockOverviewApiService.fetchStockCandleData(stock.symbol);
    if (mounted) {
      setState(() {});
    }
    // If you want to switch to the Chart tab automatically, you can:
    // if (mounted) {
    //   _tabController.animateTo(1);
    // }
  }

  Widget _buildStockList(List<StockModel> stocks, bool isLoading) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (stocks.isEmpty) {
      return const Center(child: Text('No stocks available'));
    }
    return ListView.builder(
      itemCount: stocks.length,
      itemBuilder: (context, index) {
        final stock = stocks[index];
        return ListTile(
          title: Text(stock.symbol),
          subtitle: Text('Price: ${stock.price}'),
          onTap: () => _selectStock(stock),
        );
      },
    );
  }

  Widget _buildChartTab() {
    if (_selectedSymbol == null) {
      return const Center(child: Text('Select a stock to view chart'));
    }

    return FutureBuilder<List<double>>(
      future: _candleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No chart data available'));
        }
        final candles = snapshot.data!;
        final stock = Provider.of<StockProvider>(context, listen: false)
            .stocks
            .firstWhere((s) => s.symbol == _selectedSymbol,
                orElse: () => StockModel(
                      symbol: _selectedSymbol!,
                      price: 0,
                      high: 0,
                      low: 0,
                      open: 0,
                      change: 0,
                      percentChange: 0,
                    ));

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
                  child: StockChart(data: candles),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      // Use the controller we initialized so we can switch tabs programmatically if needed
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stock Overview'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Stocks'),
              Tab(text: 'Chart'),
            ],
          ),
        ),
        body: Consumer<StockProvider>(
          builder: (context, stockProvider, child) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildStockList(stockProvider.stocks, stockProvider.isLoading),
                _buildChartTab(),
              ],
            );
          },
        ),
      ),
    );
  }
}
