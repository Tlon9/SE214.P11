import 'package:flutter/material.dart';
import 'package:travelowkey/screens/auth/login_screen.dart';
import 'package:travelowkey/screens/auth/register_screen.dart';
import 'package:travelowkey/screens/home/main_screen.dart';
import 'package:travelowkey/screens/flight/flight_search_screen.dart';
import 'package:travelowkey/screens/flight/flight_result_screen.dart';
import 'package:travelowkey/screens/flight/flight_payment_screen.dart';
import 'package:travelowkey/models/flight_model.dart';

class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegistrationScreen());
      case '/flight_search':
        return MaterialPageRoute(builder: (_) => FlightSearchScreen());
      case '/flight_result':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return FlightResultScreen(
              departure: args['departure'],
              destination: args['destination'],
              date: args['date'],
              seatClass: args['seatClass'],
              passengers: args['passengerCount'],
            );
          },
        );
      case '/flight_payment':
        final args = settings.arguments as Map<String, dynamic>;
        final flight = args['flight'] as Flight;
        final passengers = args['passengers'] as int;
        return MaterialPageRoute(
          builder: (_) => PaymentScreen(
            flight: flight,
            passengers: passengers,
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => MainScreen());
    }
  }
}
