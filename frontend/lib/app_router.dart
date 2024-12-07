import 'package:flutter/material.dart';
import 'package:travelowkey/screens/auth/login_screen.dart';
import 'package:travelowkey/screens/auth/register_screen.dart';
import 'package:travelowkey/screens/home/main_screen.dart';
import 'package:travelowkey/screens/flight/flight_search_screen.dart';
import 'package:travelowkey/screens/flight/flight_result_screen.dart';
import 'package:travelowkey/screens/flight/flight_payment_screen.dart';
import 'package:travelowkey/models/flight_model.dart';
import 'package:travelowkey/screens/hotel/hotel_search_screen.dart';
import 'package:travelowkey/screens/hotel/hotel_result_screen.dart';
import 'package:travelowkey/screens/hotel/room_result_screen.dart';
import 'package:travelowkey/screens/payment/invoice_screen.dart';

class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    final Uri? uri = Uri.tryParse(settings.name ?? '');

    if (uri != null) {
      if (uri.host == 'localhost' && uri.path == '/') {
        return MaterialPageRoute(
          builder: (_) => MainScreen(),
        );
      }
      // Add more deep link paths as needed
    }
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
      case '/invoice':
        final args = settings.arguments as Map<String, dynamic>;
        final transactionId = args['transactionId'] as String;
        return MaterialPageRoute(
            builder: (_) => InvoiceScreen(transactionId: transactionId));
      case '/hotel_search':
        return MaterialPageRoute(builder: (_) => HotelSearchScreen());
      case '/hotel_result':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return HotelResultScreen(
              area: args['area'],
              checkInDate: args['checkInDate'],
              checkOutDate: args['checkOutDate'],
              customers: args['customerCount'],
            );
          },
        );
      case '/room_result':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) {
            return RoomResultScreen(
              hotel_id: args['hotel_id'],
              hotel_name: args['hotel_name'],
              customers: args['customers'],
            );
          },
        );
      default:
        return MaterialPageRoute(builder: (_) => MainScreen());
    }
  }
}
