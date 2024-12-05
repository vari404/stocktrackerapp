import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stocktrackerapp/services/stock_api_service.dart';

class StockOverviewTab extends StatefulWidget {
  @override
  _StockOverviewTabState createState() => _StockOverviewTabState();
}

class _StockOverviewTabState extends State<StockOverviewTab> {
  late Future<List<String>> _stockSymbolsFuture;
  final TextEditingController _searchController = TextEditingController();
  final StreamController<List<String>> _filteredSymbolsStreamController =
      StreamController<List<String>>();
  StreamController<Map<String, dynamic>>? _realTimeStreamController;
  List<String> _allSymbols = [];

  @override
  void initState() {
    super.initState();
    _stockSymbolsFuture = StockApiService.fetchAllStockSymbols();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filteredSymbolsStreamController.close();
    _realTimeStreamController?.close();
    StockApiService.closeWebSocketConnection();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    final filtered = _allSymbols
        .where((symbol) => symbol.toLowerCase().contains(query))
        .toList();
    _filteredSymbolsStreamController.add(filtered);
  }

  void _startRealTimeUpdates(String symbol) {
    _realTimeStreamController?.close(); // Close any existing stream
    _realTimeStreamController =
        StreamController<Map<String, dynamic>>.broadcast();
    StockApiService.subscribeToRealTimeUpdates(symbol).listen((event) {
      _realTimeStreamController?.add(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Stock',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<String>>(
            future: _stockSymbolsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No stock symbols available.'));
              } else {
                _allSymbols = snapshot.data!;
                _filteredSymbolsStreamController.add(_allSymbols);

                return StreamBuilder<List<String>>(
                  stream: _filteredSymbolsStreamController.stream,
                  builder: (context, streamSnapshot) {
                    if (!streamSnapshot.hasData ||
                        streamSnapshot.data!.isEmpty) {
                      return Center(child: Text('No matching stocks found.'));
                    }

                    final filteredSymbols = streamSnapshot.data!;
                    return ListView.builder(
                      itemCount: filteredSymbols.length,
                      itemBuilder: (context, index) {
                        final symbol = filteredSymbols[index];
                        _startRealTimeUpdates(symbol);

                        return StreamBuilder<Map<String, dynamic>>(
                          stream: _realTimeStreamController?.stream,
                          builder: (context, realTimeSnapshot) {
                            if (realTimeSnapshot.hasData) {
                              final stockData = realTimeSnapshot.data!;
                              return ListTile(
                                title: Text(stockData['symbol']),
                                subtitle: Text(
                                    'Price: ${stockData['price']} (Updated at: ${DateTime.fromMillisecondsSinceEpoch(stockData['time'])})'),
                              );
                            } else {
                              return ListTile(
                                title: Text(symbol),
                                subtitle: Text('Fetching real-time data...'),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
