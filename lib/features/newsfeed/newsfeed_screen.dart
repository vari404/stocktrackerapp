import 'package:flutter/material.dart';
import 'package:stocktrackerapp/widgets/bottom_nav_bar.dart';
import 'package:stocktrackerapp/widgets/custom_app_bar.dart';
import 'package:stocktrackerapp/widgets/app_drawer.dart';

class NewsfeedScreen extends StatelessWidget {
  const NewsfeedScreen({Key? key}) : super(key: key);

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
      appBar: const CustomAppBar(title: 'Newsfeed'),
      drawer: AppDrawer(),
      body: const Center(
        child: Text(
          'Newsfeed Screen Content',
          style: TextStyle(fontSize: 18),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTabSelected: (index) => _onTabSelected(context, index),
      ),
    );
  }
}
