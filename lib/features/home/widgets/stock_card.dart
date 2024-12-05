import 'package:flutter/material.dart';

class StockCard extends StatelessWidget {
  final Map<String, dynamic> stock;

  const StockCard({required this.stock});

  @override
  Widget build(BuildContext context) {
    // Safely access stock data and provide default values for null
    String stockName = stock['symbol'] ?? 'Unknown Stock';
    String stockPrice = stock['price'] != null ? '\$${stock['price']}' : 'N/A';
    String stockChange = stock['change'] != null
        ? '${stock['change']} (${stock['percentChange']}%)'
        : 'N/A';

    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 5,
      child: ListTile(
        title: Text(stockName),
        subtitle: Text(stockChange),
        trailing: Text(stockPrice),
      ),
    );
  }
}
