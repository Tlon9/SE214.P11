import 'package:flutter/material.dart';
import 'package:travelowkey/screens/auth/login_screen.dart';
import 'package:travelowkey/screens/auth/register_screen.dart';
import 'package:travelowkey/screens/home/main_screen.dart';
import 'package:travelowkey/screens/flight/flight_search_screen.dart';

class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegistrationScreen());
      case '/flight_search':
        return MaterialPageRoute(builder: (_) => FlightSearchScreen());
      default:
        return MaterialPageRoute(builder: (_) => MainScreen());
    }
  }
}
