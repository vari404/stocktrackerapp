import 'package:flutter/material.dart';

class TrendingStocksCard extends StatelessWidget {
  final String symbol;
  final int buy;
  final int hold;
  final int sell;
  final int strongBuy;
  final int strongSell;

  const TrendingStocksCard({
    Key? key,
    required this.symbol,
    required this.buy,
    required this.hold,
    required this.sell,
    required this.strongBuy,
    required this.strongSell,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              symbol,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTrendInfo(context, "Strong Buy", strongBuy, Colors.green),
                _buildTrendInfo(context, "Buy", buy, Colors.lightGreen),
                _buildTrendInfo(context, "Hold", hold, Colors.orange),
                _buildTrendInfo(context, "Sell", sell, Colors.red),
                _buildTrendInfo(
                    context, "Strong Sell", strongSell, Colors.deepOrange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendInfo(
      BuildContext context, String label, int count, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: color),
        ),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
