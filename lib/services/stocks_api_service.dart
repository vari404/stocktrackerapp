import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stocktrackerapp/models/stock_model.dart';

class StocksApiService {
  final String apiKey = 'ctcf6d1r01qjor98f3hgctcf6d1r01qjor98f3i0';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch stock symbols from Finnhub API
  Future<List<Stock>> fetchStockSymbols(String exchange) async {
    final url =
        'https://finnhub.io/api/v1/stock/symbol?exchange=$exchange&token=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((symbolData) => Stock.fromJson(symbolData)).toList();
    } else {
      throw Exception('Failed to load stock symbols');
    }
  }

  // Add or update a stock symbol in Firestore
  Future<void> addStockSymbol(Stock stock) async {
    final stocksRef = _firestore.collection('stocks');

    // Check if symbol already exists
    final docSnapshot = await stocksRef.doc(stock.symbol).get();

    if (!docSnapshot.exists) {
      await stocksRef.doc(stock.symbol).set(stock.toMap());
    }
  }

  // Sync stock symbols to Firestore from API
  Future<void> syncStockSymbols(String exchange) async {
    try {
      final stockSymbols = await fetchStockSymbols(exchange);
      for (var stock in stockSymbols) {
        await addStockSymbol(stock);
      }
    } catch (e) {
      print('Error syncing stock symbols: $e');
    }
  }
}
