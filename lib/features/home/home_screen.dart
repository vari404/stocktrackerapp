import 'package:flutter/material.dart';
import 'package:stocktrackerapp/widgets/app_drawer.dart'; // Import for AppDrawer
import 'package:stocktrackerapp/widgets/custom_app_bar.dart'; // Import for CustomAppBar
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stocktrackerapp/features/home/widgets/tabs/stock_overview_tab.dart';
import 'package:stocktrackerapp/features/home/widgets/tabs/trending_stocks_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [
    StockOverviewTab(),
    TrendingStocksTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final greeting = _getGreeting();

    return Scaffold(
      appBar:
          CustomAppBar(title: 'Stock Tracker'), // CustomAppBar with gradient
      drawer: AppDrawer(),
      body: Stack(
        children: [
          // Background design matching WelcomeScreen (white background)
          Container(
            color: Colors.white, // Set body background to white
          ),

          // Background design with circles
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            top: 150,
            right: -80,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            top: 400,
            left: -100,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Greeting Text
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    '$greeting, ${user?.displayName ?? 'User'}!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color:
                          Colors.black, // Change to black for text visibility
                    ),
                  ),
                ),

                // Tab Navigation
                Expanded(
                  child: DefaultTabController(
                    length: _tabs.length,
                    child: Column(
                      children: [
                        TabBar(
                          onTap: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          labelColor: Theme.of(context)
                              .colorScheme
                              .primary, // Label color
                          unselectedLabelColor:
                              Colors.grey, // Unselected label color
                          indicatorColor: Theme.of(context)
                              .colorScheme
                              .primary, // Indicator color
                          tabs: const [
                            Tab(text: 'Stock Overview'),
                            Tab(text: 'Trending Stocks'),
                          ],
                        ),
                        Expanded(child: _tabs[_currentIndex]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
