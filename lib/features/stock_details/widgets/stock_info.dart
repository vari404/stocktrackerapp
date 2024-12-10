import 'package:flutter/material.dart';
import 'package:stocktrackerapp/models/stock_model.dart';

class StockInfo extends StatefulWidget {
  final StockModel stock;
  const StockInfo({Key? key, required this.stock}) : super(key: key);

  @override
  State<StockInfo> createState() => _StockInfoState();
}

class _StockInfoState extends State<StockInfo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.stock.symbol,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text('Price: ${widget.stock.price}'),
        Text('High: ${widget.stock.high}'),
        Text('Low: ${widget.stock.low}'),
        Text('Open: ${widget.stock.open}'),
        Text('Change: ${widget.stock.change}'),
        Text('Percent Change: ${widget.stock.percentChange}%'),
      ],
    );
  }
}
