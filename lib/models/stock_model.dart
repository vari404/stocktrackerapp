class Stock {
  final String symbol;

  Stock({required this.symbol});

  // Factory to create a Stock from a Firestore document
  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['symbol'] as String,
    );
  }

  // Method to convert a Stock object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
    };
  }
}
