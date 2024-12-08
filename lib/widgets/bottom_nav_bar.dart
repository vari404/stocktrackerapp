import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabSelected,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pie_chart),
          label: 'Portfolio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.watch_later),
          label: 'Watchlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.feed),
          label: 'Newsfeed',
        ),
      ],
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true, // Ensure selected labels are visible
      showUnselectedLabels: true, // Ensure unselected labels are visible
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
      unselectedLabelStyle: TextStyle(
        color: Colors.grey,
      ),
    );
  }
}
