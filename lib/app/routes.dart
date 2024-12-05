import 'package:flutter/material.dart';
import 'package:stocktrackerapp/features/home/home_screen.dart';
import 'package:stocktrackerapp/screens/forgot_password_screen.dart';
import 'package:stocktrackerapp/screens/welcome_screen.dart'; // Import WelcomeScreen
import 'package:stocktrackerapp/screens/sign_in_screen.dart'; // Import SignInScreen
import 'package:stocktrackerapp/screens/sign_up_screen.dart'; // Import SignUpScreen

class Routes {
  static Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/sign-in':
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case '/sign-up':
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      default:
        return null;
    }
  }
}
