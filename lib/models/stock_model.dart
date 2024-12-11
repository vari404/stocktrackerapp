class Stock {
  final String symbol;
  final String description;
  final String exchange;
  final String currency;
  final String mic;

  Stock({
    required this.symbol,
    required this.description,
    required this.exchange,
    required this.currency,
    required this.mic,
  });

  // Factory to create a Stock from a JSON object
  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['symbol'] as String,
      description: json['description'] as String,
      exchange: json['mic'] as String,
      currency: json['currency'] as String,
      mic: json['mic'] as String,
    );
  }

  // Method to convert a Stock object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'description': description,
      'exchange': exchange,
      'currency': currency,
      'mic': mic,
    };
  }
}
