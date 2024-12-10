import 'package:flutter/material.dart';

class StockCard extends StatelessWidget {
  final String symbol;
  final double price;
  final double change;
  final int volume;

  const StockCard({
    Key? key,
    required this.symbol,
    required this.price,
    required this.change,
    required this.volume,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title:
            Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Price: \$${price.toStringAsFixed(2)}"),
            Text("Volume: $volume"),
          ],
        ),
        trailing: Text(
          "${isPositive ? "+" : ""}${change.toStringAsFixed(2)}%",
          style: TextStyle(
            color: isPositive ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
