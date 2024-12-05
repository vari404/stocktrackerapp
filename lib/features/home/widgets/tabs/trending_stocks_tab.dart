import 'package:flutter/material.dart';
import 'package:stocktrackerapp/features/home/widgets/stock_card.dart';
import 'package:stocktrackerapp/services/stock_api_service.dart';

class TrendingStocksTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: StockApiService.fetchTrendingStocks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No trending stock data available.'));
        } else {
          final trendingStocks = snapshot.data!;
          return ListView.builder(
            itemCount: trendingStocks.length,
            itemBuilder: (context, index) {
              return StockCard(stock: trendingStocks[index]);
            },
          );
        }
      },
    );
  }
}
