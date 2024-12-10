class StockModel {
  final String symbol;
  final double price;
  final double high;
  final double low;
  final double open;
  final double change;
  final double percentChange;

  StockModel({
    required this.symbol,
    required this.price,
    required this.high,
    required this.low,
    required this.open,
    required this.change,
    required this.percentChange,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: json['symbol'],
      price: (json['price'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      open: (json['open'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
      percentChange: (json['percentChange'] as num).toDouble(),
    );
  }
}
