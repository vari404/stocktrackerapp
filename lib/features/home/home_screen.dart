import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stocktrackerapp/widgets/app_drawer.dart';
import 'package:stocktrackerapp/widgets/custom_app_bar.dart';
import 'package:stocktrackerapp/widgets/bottom_nav_bar.dart';
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

  void _onTabSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/portfolio');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/watchlist');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/newsfeed');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final greeting = _getGreeting();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Stock Tracker'),
      drawer: AppDrawer(),
      body: Stack(
        children: [
          // Background design matching WelcomeScreen
          Container(
            color: Colors.white,
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
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
                          labelColor: Theme.of(context).colorScheme.primary,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Theme.of(context).colorScheme.primary,
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
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0, // Home is the first tab
        onTabSelected: (index) => _onTabSelected(context, index),
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
