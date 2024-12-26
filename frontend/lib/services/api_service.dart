// flight_search_data_provider.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travelowkey/models/flightSearch_model.dart';
import 'package:travelowkey/models/flight_model.dart';
import 'package:travelowkey/models/hotelSearch_model.dart';
import 'package:travelowkey/models/hotel_model.dart';
import 'package:travelowkey/models/room_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelowkey/models/accountLogin_model.dart';
import 'package:travelowkey/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:travelowkey/models/paymentHistory_model.dart';

class FlightSearchDataProvider {
  final String apiUrl;
  final List<String> locations = [
    "TP HCM (SGN)",
    "Hà Nội (HAN)",
    "Đà Nẵng (DAD)"
  ];
  final List<String> travelClasses = ["Economy", "Business", "First Class"];
  final List<int> passengerCounts = [1, 2, 3];

  FlightSearchDataProvider({required this.apiUrl});

  Future<FlightSearchModel> fetchFlightSearchData() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final decodedJson = json.decode(utf8.decode(response.bodyBytes));
      return FlightSearchModel.fromJson(decodedJson);
    } else {
      throw Exception("Failed to load flight search data");
    }
    // final response = {
    //   "departures": ["TP HCM (SGN)", "Hà Nội (HAN)", "Đà Nẵng (DAD)"],
    //   "destinations": ["TP HCM (SGN)", "Hà Nội (HAN)", "Đà Nẵng (DAD)"],
    //   "seatClasses": ["Economy", "Business", "First Class"],
    //   "passengerCounts": [1, 2, 3],
    // };
    // return FlightSearchModel.fromJson(response);
    // if (response.statusCode == 200) {
    //   return FlightSearchModel.fromJson(json.decode(response.body));
    // } else {
    //   throw Exception("Failed to load flight search data");
    // }
  }
}

class FlightResultDataProvider {
  final String apiUrl;

  FlightResultDataProvider({required this.apiUrl});

  Future<List<Flight>> fetchFlightResults(
      {Map<String, dynamic>? searchInfo}) async {
    final response = await http.get(Uri.parse(apiUrl));

    // const mockResponse = '''
    //   {
    //     "flights": [
    //       {
    //         "name": "VietJet Air",
    //         "departureTime": "22:50",
    //         "arrivalTime": "01:00",
    //         "price": 1703440,
    //         "departureLocation": "SGN",
    //         "arrivalLocation": "HAN",
    //         "duration": "2h 10m",
    //         "seatClass": "Economy"
    //       },
    //       {
    //     ]
    //   }
    //   ''';
    // final response = json.decode(mockResponse);
    // final temp = (response['flights'] as List)
    //     .map((json) => Flight.fromJson(json))
    //     .toList();
    // print(temp);
    // return temp;

    if (response.statusCode == 200) {
      // Parse the JSON data
      final data = json.decode(utf8.decode(response.bodyBytes));
      // final check_response = (data['flights'] as List);
      // .map((json) => Flight.fromJson(json))
      // .toList();
      // print(check_response[0]);
      return (data['flights'] as List)
          .map((json) => Flight.fromJson(json))
          .toList();
    } else {
      throw Exception("Failed to load flight data");
    }
  }
}

class HotelSearchDataProvider {
  final String apiUrl;
  final List<String> areas = ["TP HCM", "Hà Nội", "Đà Nẵng", "Đà Lạt"];

  final List<int> customerCounts = [1, 2, 3, 4, 5];

  HotelSearchDataProvider({required this.apiUrl});

  Future<HotelSearchModel> fetchHotelSearchData() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final decodedJson = json.decode(utf8.decode(response.bodyBytes));
      return HotelSearchModel.fromJson(decodedJson);
    } else {
      throw Exception("Failed to load hotel search data");
    }
  }
}

class HotelResultDataProvider {
  // final String apiUrl;

  // HotelResultDataProvider({required this.apiUrl});
  HotelResultDataProvider();

  Future<List<Hotel>> fetchHotelResults(
      {Map<String, dynamic>? searchInfo, int? offset, int? limit}) async {
    if (!searchInfo!.containsKey('area') || searchInfo['area'] == null) {
      throw Exception("Search information is missing the 'area' key.");
    }
    final apiUrl =
        'http://10.0.2.2:8008/hotels/results?area=${Uri.encodeComponent(searchInfo['area']!)}&offset=$offset&limit=$limit';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // Parse the JSON data
      final data = json.decode(utf8.decode(response.bodyBytes));
      // final temp = (data['hotels'] as List).map((json) => Hotel.fromJson(json)).toList();
      // print(offset.toString() + " " + limit.toString() + " " + temp.length.toString());
      return (data['hotels'] as List)
          .map((json) => Hotel.fromJson(json))
          .toList();
    } else {
      throw Exception("Failed to load hotel data");
    }
  }
}

class RoomResultDataProvider {
  final String apiUrl;

  RoomResultDataProvider({required this.apiUrl});

  Future<List<Room>> fetchRoomResults(
      {Map<String, dynamic>? searchInfo}) async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // Parse the JSON data
      final data = json.decode(utf8.decode(response.bodyBytes));
      return (data['rooms'] as List)
          .map((json) => Room.fromJson(json))
          .toList();
    } else {
      throw Exception("Failed to load room data");
    }
  }
}

class AuthService {
  final _storage = const FlutterSecureStorage();

  // Save user info
  Future<void> saveUserInfo(AccountLogin user) async {
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: 'user_info', value: userJson);
  }

  // Retrieve user info
  Future<AccountLogin?> getUserInfo() async {
    final userJson = await _storage.read(key: 'user_info');
    if (userJson == null) return null;
    return AccountLogin.fromJson(jsonDecode(userJson));
  }

  // Clear user info (e.g., on logout)
  Future<void> clearUserInfo() async {
    await _storage.delete(key: 'user_info');
  }
}

class UserProvider with ChangeNotifier {
  AccountLogin? _user;
  final AuthService _authService = AuthService();

  AccountLogin? get user => _user;

  // Load user info on app start
  Future<void> loadUserInfo() async {
    _user = await _authService.getUserInfo();
    notifyListeners();
  }

  Future<AccountLogin?> getUserInfo() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return AccountLogin(
        email: 'test@example.com',
        accessToken: 'token',
        refreshToken: 'refresh_token');
  }

  // Save user info and notify listeners
  Future<void> saveUser(AccountLogin user) async {
    _user = user;
    await _authService.saveUserInfo(user);
    notifyListeners();
  }

  // Clear user info (e.g., on logout)
  Future<void> logout() async {
    _user = null;
    await _authService.clearUserInfo();
    notifyListeners();
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _user != null && !isTokenExpired();
  }

  // Check if token is expired
  bool isTokenExpired() {
    if (_user == null || _user!.accessToken.isEmpty) return true;
    try {
      return Jwt.isExpired(_user!.accessToken);
    } catch (e) {
      return true; // Treat invalid tokens as expired
    }
  }
}

class UserDataProvider {
  final String apiUrl;
  UserDataProvider({required this.apiUrl});
  Future<User> fetchUser() async {
    // final apiUrl = 'http://10.0.2.2:8000/user/?email=${email}';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final decodedJson = json.decode(utf8.decode(response.bodyBytes));
      return User.fromJson(decodedJson);
    } else {
      throw Exception("Failed to load user");
    }
  }

  Future<AccountLogin?> getUserInfo() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return AccountLogin(
        email: 'test@example.com',
        accessToken: 'token',
        refreshToken: 'refresh_token');
  }
}

class PaymentDataProvider {
  final apiUrl = 'http://10.0.2.2:8080/payment/history';
  final _storage = const FlutterSecureStorage();
  PaymentDataProvider();

  Future<List<PaymentHistory>> fetchPaymentHistory() async {
    final userJson = await _storage.read(key: 'user_info');
    final accessToken =
        AccountLogin.fromJson(jsonDecode(userJson!)).accessToken;
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> decodedJson =
          json.decode(utf8.decode(response.bodyBytes));
      return decodedJson.map((json) => PaymentHistory.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load payment history");
    }
  }
}

class FlightPaymentDataProvider {
  final String apiUrl;

  FlightPaymentDataProvider({required this.apiUrl});

  Future<void> makePayment({required Map<String, dynamic> paymentInfo}) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: json.encode(paymentInfo),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to make payment");
    }
  }
}
