import 'package:cloud_firestore/cloud_firestore.dart';

class StocksApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add frequently accessed stocks manually to Firestore
  Future<void> addFrequentlyAccessedStocks(List<String> symbols) async {
    try {
      final stocksRef = _firestore.collection('stocks');
      final batch = _firestore.batch();

      for (var symbol in symbols) {
        final docRef = stocksRef.doc(symbol);
        batch.set(docRef, {'symbol': symbol}); // Store only the symbol
      }

      await batch.commit();
      print('Frequently accessed stocks added successfully.');
    } catch (e) {
      print('Error adding frequently accessed stocks: $e');
    }
  }

  // Static method to initialize frequently accessed stocks
  static Future<void> initializeFrequentlyAccessedStocks() async {
    final stocksApiService = StocksApiService();
    final frequentlyAccessedStocks = [
      'AAPL',
      'MSFT',
      'GOOGL',
      'AMZN',
      'TSLA',
      'META',
      'NFLX',
      'NVDA',
      'ADBE',
      'INTC',
      'JPM',
      'V',
      'NVDA',
      'DIS',
      'PYPL',
      'BA',
      'GS',
      'WMT',
      'KO',
      'IBM',
      'SBUX',
      'TWTR',
      'BABA',
      'CSCO',
      'NKE',
      'PEP',
      'GE',
      'XOM',
      'MCD',
      'HSBC',
      'UNH',
      'CVX',
      'HD',
      'INTU',
      'CRM',
      'ORCL',
      'T',
      'LMT',
      'CAT',
      'MMM',
      'GE',
      'HON',
      'AMGN',
      'BMY',
      'ABBV',
      'GILD',
      'F',
      'FISV',
      'MU',
      'TXN',
      'QCOM',
      'ATVI',
      'GM',
      'ZTS',
      'MDT',
      'LOW',
      'CVS',
      'PM',
      'NOK',
      'LRCX',
      'VZ',
      'PLD',
      'NEE',
      'MELI',
      'MSI',
      'FIS',
      'TMO',
      'AIG',
      'SYK',
      'APD',
      'SPGI',
      'AXP',
      'SNY',
      'COP',
      'DE',
      'ISRG',
      'DHR',
      'CHTR',
      'REGN',
      'ADP',
      'AMT',
      'EQIX',
      'CSX',
      'VLO',
      'EBAY',
      'MRK',
      'WBA',
      'BDX',
      'SYF',
      'XEL',
      'KMB',
      'USB',
      'ICE',
      'C',
      'PFE',
      'MTCH',
      'ADSK',
      'VTRS',
      'VRTX',
      'ALL',
      'CSGP',
      'IQV',
      'DOW',
      'RMD',
      'CL',
      'MMC',
      'LUV',
      'TMUS',
      'TJX',
      'SWKS',
      'FTNT',
      'IDXX',
      'ALGN',
      'UAL',
      'RCL',
      'CB',
      'MSCI',
      'ZBH',
      'STZ',
      'CHD',
      'MDLZ',
      'TGT',
      'RDS.A',
      'DISCK',
      'WFC',
      'ZION',
      'MKC',
      'COF',
      'EXC',
      'KMI',
      'HCA',
      'MET'
    ]; // 100 symbols

    await stocksApiService
        .addFrequentlyAccessedStocks(frequentlyAccessedStocks);
  }

  // Fetch stock symbols from Firestore
  Future<List<String>> getStockSymbols() async {
    try {
      final stocksCollection = _firestore.collection('stocks');
      final snapshot = await stocksCollection.get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => doc.id).toList();
      } else {
        return []; // Return an empty list if no documents are found
      }
    } catch (e) {
      throw Exception('Error fetching stock symbols: $e');
    }
  }
}
