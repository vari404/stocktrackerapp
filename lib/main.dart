import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider package
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core package
import 'package:stocktrackerapp/app/routes.dart';
import 'package:stocktrackerapp/themes/theme_provider.dart';
import 'package:stocktrackerapp/services/stocks_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase before anything else
  await Firebase.initializeApp(); // Add Firebase initialization here

  // After Firebase is initialized, you can now safely call syncStockSymbols
  final stocksApiService = StocksApiService();
  await stocksApiService
      .syncStockSymbols('US'); // Sync stock symbols on startup

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Stock Tracker',
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          darkTheme: ThemeData.dark(),
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
          ),
          onGenerateRoute: Routes.generateRoute,
        );
      },
    );
  }
}
