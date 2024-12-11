import 'package:flutter/material.dart';
import 'package:stocktrackerapp/models/stock_model.dart';

class StockInfo extends StatelessWidget {
  final StockModel stock;
  const StockInfo({Key? key, required this.stock}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(stock.symbol, style: Theme.of(context).textTheme.titleLarge),
        Text('Price: ${stock.price}'),
        Text('High: ${stock.high}'),
        Text('Low: ${stock.low}'),
        Text('Open: ${stock.open}'),
        Text('Change: ${stock.change}'),
        Text('Percent Change: ${stock.percentChange}%'),
      ],
    );
  }
}
