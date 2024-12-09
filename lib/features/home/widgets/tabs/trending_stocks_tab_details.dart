import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TrendingStocksTabDetails extends StatelessWidget {
  final String symbol;
  final int buy;
  final int hold;
  final int sell;
  final int strongBuy;
  final int strongSell;

  const TrendingStocksTabDetails({
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
    return Scaffold(
      appBar: AppBar(
        title: Text('$symbol Recommendations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title above the chart
            Text(
              '$symbol Recommendation Trends',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium, // Updated to 'headlineMedium'
            ),
            const SizedBox(height: 16.0),

            // Chart
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text(
                                'Strong Buy',
                                style: TextStyle(color: Colors.green),
                              );
                            case 1:
                              return const Text(
                                'Buy',
                                style: TextStyle(color: Colors.lightGreen),
                              );
                            case 2:
                              return const Text(
                                'Hold',
                                style: TextStyle(color: Colors.orange),
                              );
                            case 3:
                              return const Text(
                                'Sell',
                                style: TextStyle(color: Colors.red),
                              );
                            case 4:
                              return const Text(
                                'Strong Sell',
                                style: TextStyle(color: Colors.deepOrange),
                              );
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  gridData: FlGridData(show: true),
                  barGroups: [
                    _buildBarChartGroup('Strong Buy', strongBuy, Colors.green),
                    _buildBarChartGroup('Buy', buy, Colors.lightGreen),
                    _buildBarChartGroup('Hold', hold, Colors.orange),
                    _buildBarChartGroup('Sell', sell, Colors.red),
                    _buildBarChartGroup(
                        'Strong Sell', strongSell, Colors.deepOrange),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Create the bar chart group
  BarChartGroupData _buildBarChartGroup(String label, int count, Color color) {
    return BarChartGroupData(
      x: _getIndexForLabel(label),
      barRods: [
        BarChartRodData(
          toY: count.toDouble(),
          color: color,
          width: 30,
        ),
      ],
      showingTooltipIndicators: [0],
    );
  }

  // Map labels to x-axis index for proper grouping
  int _getIndexForLabel(String label) {
    switch (label) {
      case 'Strong Buy':
        return 0;
      case 'Buy':
        return 1;
      case 'Hold':
        return 2;
      case 'Sell':
        return 3;
      case 'Strong Sell':
        return 4;
      default:
        return 0;
    }
  }
}
