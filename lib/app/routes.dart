import 'package:flutter/material.dart';
import 'package:stocktrackerapp/features/home/home_screen.dart';
import 'package:stocktrackerapp/features/watchlist/watchlist_screen.dart';
import 'package:stocktrackerapp/features/newsfeed/newsfeed_screen.dart';
import 'package:stocktrackerapp/screens/forgot_password_screen.dart';
import 'package:stocktrackerapp/screens/welcome_screen.dart';
import 'package:stocktrackerapp/screens/sign_in_screen.dart';
import 'package:stocktrackerapp/screens/sign_up_screen.dart';
import 'package:stocktrackerapp/screens/profile_screen.dart';
import 'package:stocktrackerapp/screens/settings_screen.dart';

class Routes {
  static Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case '/watchlist':
        return MaterialPageRoute(builder: (_) => const WatchlistScreen());
      case '/newsfeed':
        return MaterialPageRoute(builder: (_) => const NewsfeedScreen());
      case '/sign-in':
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case '/sign-up':
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return null;
    }
  }
}
