import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stocktrackerapp/features/home/widgets/tabs/stock_overview_details.dart';
import 'package:stocktrackerapp/widgets/bottom_nav_bar.dart';
import 'package:stocktrackerapp/widgets/custom_app_bar.dart';
import 'package:stocktrackerapp/widgets/app_drawer.dart';
import 'package:stocktrackerapp/features/watchlist/widgets/watchlist_card.dart';
import 'package:stocktrackerapp/services/watchlist_api_service.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({Key? key}) : super(key: key);

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final WatchlistApiService _apiService = WatchlistApiService();
  List<String> _symbols = [];
  final Map<String, dynamic> _stockData = {};

  @override
  void initState() {
    super.initState();
    _fetchWatchlistSymbols();
    _apiService.updates.listen((data) {
      if (data['type'] == 'trade' && data['data'] != null) {
        setState(() {
          for (var trade in data['data']) {
            _stockData[trade['s']] = {
              'price': trade['p'],
              'volume': trade['v'],
            };
          }
        });
      }
    });
  }

  Future<void> _fetchWatchlistSymbols() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('watchlist')
        .get();

    final symbols =
        snapshot.docs.map((doc) => doc['symbol'] as String).toList();
    setState(() {
      _symbols = symbols;
    });
    _apiService.subscribeToSymbols(symbols);
  }

  Future<void> _removeSymbol(String symbol) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('watchlist')
        .doc(symbol)
        .delete();

    setState(() {
      _symbols.remove(symbol);
      _stockData.remove(symbol);
    });
    _apiService.unsubscribeFromSymbols([symbol]);
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  void _onTabSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;

      case 1:
        Navigator.pushReplacementNamed(context, '/watchlist');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/newsfeed');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Watchlist'),
      drawer: AppDrawer(),
      body: _symbols.isEmpty
          ? const Center(child: Text('No symbols in your watchlist.'))
          : ListView.builder(
              itemCount: _symbols.length,
              itemBuilder: (context, index) {
                final symbol = _symbols[index];
                final stock = _stockData[symbol] ?? {};
                return WatchlistCard(
                  symbol: symbol,
                  price: stock['price']?.toString() ?? 'N/A',
                  volume: stock['volume']?.toString() ?? 'N/A',
                  onDelete: () => _removeSymbol(symbol),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StockOverviewDetails(symbol: symbol),
                      ),
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTabSelected: (index) => _onTabSelected(context, index),
      ),
    );
  }
}
