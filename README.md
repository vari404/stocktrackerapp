# stocktrackerapp

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Project Structure


lib/
├── main.dart                   # Entry point of the application.
├── app/
│   ├── app.dart                # App-level configuration (MaterialApp, ThemeData, Routes).
│   ├── routes.dart             # Centralized routing management.
├── features/
│   ├── home/
│   │   ├── home_screen.dart    # Home page with tabs for Stock Overview and Trending Stocks.
│   │   ├── widgets/            # Widgets specific to the home page.
│   │       ├── stock_card.dart # Widget for individual stock display.
│   │       ├── tabs/           # Tab-specific widgets.
│   │           ├── stock_overview_tab.dart
│   │           ├── trending_stocks_tab.dart
│   │
│   ├── stock_details/
│   │   ├── stock_details_screen.dart  # Detailed stock page.
│   │   ├── widgets/                   # Widgets specific to stock details.
│   │       ├── stock_chart.dart       # Widget to display stock price chart.
│   │       ├── stock_info.dart        # Widget to display price, P/E ratio, etc.
│   │
│   ├── watchlist/
│   │   ├── watchlist_screen.dart      # Watchlist page.
│   │   ├── widgets/                   # Widgets specific to watchlist.
│   │       ├── watchlist_card.dart    # Widget for individual watchlist item.
│   │
│   ├── portfolio/
│   │   ├── portfolio_screen.dart      # Portfolio page.
│   │   ├── widgets/                   # Widgets specific to portfolio.
│   │       ├── portfolio_card.dart    # Widget for individual portfolio item.
│
├── services/
│   ├── firebase_service.dart          # Firebase interaction logic.
│   ├── stock_api_service.dart         # API integration for fetching stock data.
│
├── models/
│   ├── stock_model.dart               # Model for stock data.
│   ├── user_model.dart                # Model for user data.
│
├── utils/
│   ├── constants.dart                 # App constants like API keys, URLs.
│   ├── helpers.dart                   # Utility functions like formatting, error handling.
│
├── providers/
│   ├── stock_provider.dart            # State management for stock data.
│   ├── watchlist_provider.dart        # State management for watchlist.
│
├── widgets/
│   ├── custom_app_bar.dart            # Reusable app bar widget.
│   ├── app_drawer.dart                # Reusable app drawer widget. (NEW)
│   ├── loading_indicator.dart         # Common loading spinner.
│   ├── error_widget.dart              # Error handling UI component.



Issues

I had hard time to fetch the trending stocks because all the stocks are not trended, I had to retreive first the symbols name then filter all of them to find which on is trending and displays them and because it was a lot information to process from api the app took forever to load 