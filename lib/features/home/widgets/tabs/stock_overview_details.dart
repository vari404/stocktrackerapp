import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:stocktrackerapp/widgets/app_drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stocktrackerapp/widgets/custom_app_bar.dart';
import 'package:stocktrackerapp/widgets/bottom_nav_bar.dart';
import 'package:stocktrackerapp/services/stock_overview_api_service.dart';
import 'package:stocktrackerapp/services/company_profile_service.dart';
import 'package:stocktrackerapp/services/firebase_service.dart';

class StockOverviewDetails extends StatefulWidget {
  final String symbol;

  const StockOverviewDetails({Key? key, required this.symbol})
      : super(key: key);

  @override
  _StockOverviewDetailsState createState() => _StockOverviewDetailsState();
}

class _StockOverviewDetailsState extends State<StockOverviewDetails> {
  final StockOverviewApiService _apiService = StockOverviewApiService();
  final CompanyProfileService _profileService = CompanyProfileService();
  final FirebaseService _firebaseService = FirebaseService();

  late Stream<Map<String, Map<String, dynamic>>> _stockStream;

  Map<String, dynamic> _stockData = {};
  Map<String, dynamic> _companyProfile = {};
  List<FlSpot> _priceHistory = [];
  List<String> _timestamps = [];
  bool _isInWatchlist = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeStockData();
    _fetchCompanyProfile(widget.symbol);
    _checkWatchlistStatus();
  }

  void _initializeStockData() {
    try {
      _stockStream = _apiService.connectRealTimeUpdates([widget.symbol]);
      _stockStream.listen((data) {
        if (data.containsKey(widget.symbol)) {
          setState(() {
            _stockData = data[widget.symbol]!;
            double currentPrice = _stockData['price'] ?? 0;
            String timestamp = DateFormat('HH:mm:ss').format(DateTime.now());

            _priceHistory
                .add(FlSpot(_priceHistory.length.toDouble(), currentPrice));
            _timestamps.add(timestamp);

            if (_priceHistory.length > 100) {
              _priceHistory.removeAt(0);
              _timestamps.removeAt(0);
            }
            _hasError = false; // Reset error state on successful data fetch
          });
        } else {
          setState(() {
            _hasError = true; // Mark as error if data not found
          });
        }
      }, onError: (error) {
        setState(() {
          _hasError = true;
        });
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  void _fetchCompanyProfile(String symbol) async {
    try {
      final profile = await _profileService.fetchCompanyProfile(symbol);
      setState(() {
        _companyProfile = profile;
      });
    } catch (error) {
      print('Error fetching company profile: $error');
    }
  }

  void _checkWatchlistStatus() async {
    final isInWatchlist =
        await _firebaseService.isSymbolInWatchlist(widget.symbol);
    setState(() {
      _isInWatchlist = isInWatchlist;
    });
  }

  void _toggleWatchlist() async {
    if (_isInWatchlist) {
      await _firebaseService.removeFromWatchlist(widget.symbol);
    } else {
      await _firebaseService.addToWatchlist(widget.symbol);
    }
    _checkWatchlistStatus();
  }

  void _openWebsite(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Could not launch $url");
    }
  }

  @override
  void dispose() {
    _apiService.closeWebSocketConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        appBar: const CustomAppBar(title: "Stock Overview Details"),
        drawer: AppDrawer(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                'Failed to load details for "${widget.symbol}".',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text('Please try again later or check the stock symbol.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Stocks'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: "Stock Overview Details"),
      drawer: AppDrawer(),
      body: _stockData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Price: \$${_stockData['price']?.toStringAsFixed(2) ?? 'N/A'}",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Change: ${(_stockData['change'] ?? 0) >= 0 ? "+" : ""}${_stockData['change']?.toStringAsFixed(2) ?? 'N/A'}%",
                    style: TextStyle(
                      color: (_stockData['change'] ?? 0) >= 0
                          ? Colors.green
                          : Colors.red,
                      fontSize: 18,
                    ),
                  ),
                  Text("Volume: ${_stockData['volume'] ?? 'N/A'}"),
                  const SizedBox(height: 20),
                  const Text("Price History",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _priceHistory.isEmpty
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          height: 250,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) => Text(
                                      '\$${value.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 10),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 32,
                                    getTitlesWidget: (value, meta) {
                                      int index = value.toInt();
                                      return index < _timestamps.length
                                          ? Text(
                                              _timestamps[index],
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10),
                                            )
                                          : const Text('');
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _priceHistory,
                                  isCurved: true,
                                  color: Colors.blue,
                                  barWidth: 4,
                                  belowBarData: BarAreaData(show: false),
                                ),
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                  const Text("Company Profile",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _companyProfile.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Stack(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_companyProfile['logo'] != null)
                                      SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: Image.network(
                                          _companyProfile['logo'],
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              "Name: ${_companyProfile['name'] ?? 'N/A'}"),
                                          Text(
                                              "Industry: ${_companyProfile['finnhubIndustry'] ?? 'N/A'}"),
                                          Text(
                                              "Market Cap: \$${_companyProfile['marketCapitalization'] ?? 'N/A'}B"),
                                          Text(
                                              "IPO Date: ${_companyProfile['ipo'] ?? 'N/A'}"),
                                          if (_companyProfile['weburl'] != null)
                                            GestureDetector(
                                              onTap: () => _openWebsite(
                                                  _companyProfile['weburl']),
                                              child: Text(
                                                "Website: ${_companyProfile['weburl']}",
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  right: 16,
                                  top: 50, // Adjust vertical position as needed
                                  child: IconButton(
                                    icon: Icon(
                                      _isInWatchlist
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: _isInWatchlist
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.grey,
                                      size: 30, // Increased size
                                    ),
                                    onPressed: _toggleWatchlist,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTabSelected: (index) {
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
        },
      ),
    );
  }
}
