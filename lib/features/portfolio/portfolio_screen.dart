import 'package:flutter/material.dart';
import 'package:stocktrackerapp/widgets/app_drawer.dart';
import 'package:stocktrackerapp/widgets/bottom_nav_bar.dart';
import 'package:stocktrackerapp/widgets/custom_app_bar.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

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
    return Scaffold(
      appBar: const CustomAppBar(title: 'Portfolio'),
      drawer: AppDrawer(),
      body: const Center(
        child: Text('Portfolio Screen Content'),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTabSelected: (index) => _onTabSelected(context, index),
      ),
    );
  }
}
