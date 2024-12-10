import 'package:flutter/material.dart';
import 'package:user_registration/models/hotel_model.dart';
import 'package:user_registration/models/room_model.dart';
import 'package:user_registration/screens/auth/login_screen.dart';
import 'package:user_registration/screens/auth/register_screen.dart';
import 'package:user_registration/screens/home/main_screen.dart';
import 'package:user_registration/screens/flight/flight_search_screen.dart';
import 'package:user_registration/screens/flight/flight_result_screen.dart';
import 'package:user_registration/screens/flight/flight_payment_screen.dart';
import 'package:user_registration/models/flight_model.dart';
import 'package:user_registration/screens/hotel/hotel_payment_screen.dart';
import 'package:user_registration/screens/hotel/hotel_search_screen.dart';
import 'package:user_registration/screens/hotel/hotel_result_screen.dart';
import 'package:user_registration/screens/hotel/room_result_screen.dart';

class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegistrationScreen());
      case '/flight_search':
        return MaterialPageRoute(builder: (_) => FlightSearchScreen());
      case '/main':
        return MaterialPageRoute(builder: (_) => MainScreen());
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
      case '/hotel_payment':
        final args = settings.arguments as Map<String, dynamic>;
        final hotel = args['hotel'] as Hotel;
        final room = args['room'] as Room;
        final passengers = args['passengers'] as int;
        return MaterialPageRoute(
          builder: (_) => HotelPaymentScreen(
            hotel: hotel,
            room: room,
            passengers: passengers,
            checkInDate: args['checkInDate'],
            checkOutDate: args['checkOutDate'],
          ),
        );
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
        final hotel = args['hotel'] as Hotel;
        return MaterialPageRoute(
          builder: (context) {
            return RoomResultScreen(
              hotel: hotel,
              hotel_name: args['hotel_name'],
              customers: args['customers'],
              checkInDate: args['checkInDate'],
              checkOutDate: args['checkOutDate'],
            );
          },
        );
      default:
        return MaterialPageRoute(builder: (_) => LoginScreen());
    }
  }
}
