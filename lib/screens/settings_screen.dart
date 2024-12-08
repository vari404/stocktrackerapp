import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocktrackerapp/themes/theme_provider.dart';
import 'package:stocktrackerapp/widgets/app_drawer.dart';
import 'package:stocktrackerapp/widgets/custom_app_bar.dart';
import 'package:stocktrackerapp/widgets/bottom_nav_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

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
      appBar: const CustomAppBar(title: 'Settings'),
      drawer: AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 39, 17, 89),
              Color.fromARGB(193, 79, 14, 34)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Dark mode toggle
              Card(
                elevation: 5,
                color: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.dark_mode, color: Colors.white),
                  title: const Text(
                    "Dark Mode",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.toggleDarkMode(value);
                        },
                        activeColor: Colors.white,
                        activeTrackColor: Colors.deepPurpleAccent,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex:
            0, // Default index, you can set it as Home (or adjust based on app navigation)
        onTabSelected: (index) => _onTabSelected(context, index),
      ),
    );
  }
}
