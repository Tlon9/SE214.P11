// flight_search_data_provider.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:user_registration/models/flightSearch_model.dart';
import 'package:user_registration/models/flight_model.dart';
import 'package:user_registration/models/hotelSearch_model.dart';
import 'package:user_registration/models/hotel_model.dart';
import 'package:user_registration/models/room_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:user_registration/models/user_model.dart';
import 'package:flutter/material.dart';

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
  final List<String> areas = [
    "TP HCM",
    "Hà Nội",
    "Đà Nẵng",
    "Đà Lạt"
  ];

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

  Future<List<Hotel>> fetchHotelResults({Map<String, dynamic>? searchInfo, int? offset, int? limit}) async {
    if (!searchInfo!.containsKey('area') || searchInfo['area'] == null) {
      throw Exception("Search information is missing the 'area' key.");
    }
    final apiUrl = 'http://10.0.2.2:8000/hotels/results?area=${Uri.encodeComponent(searchInfo['area']!)}&offset=$offset&limit=$limit';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // Parse the JSON data
      final data = json.decode(utf8.decode(response.bodyBytes));
      // final temp = (data['hotels'] as List).map((json) => Hotel.fromJson(json)).toList();
      // print(offset.toString() + " " + limit.toString() + " " + temp.length.toString());
      return (data['hotels'] as List).map((json) => Hotel.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load hotel data");
    }
  }
}

class RoomResultDataProvider {
  final String apiUrl;

  RoomResultDataProvider({required this.apiUrl});

  Future<List<Room>> fetchRoomResults({Map<String, dynamic>? searchInfo}) async {
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
  Future<void> saveUserInfo(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: 'user_info', value: userJson);
  }

  // Retrieve user info
  Future<User?> getUserInfo() async {
    final userJson = await _storage.read(key: 'user_info');
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  // Clear user info (e.g., on logout)
  Future<void> clearUserInfo() async {
    await _storage.delete(key: 'user_info');
  }
}

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthService _authService = AuthService();

  User? get user => _user;

  // Load user info on app start
  Future<void> loadUserInfo() async {
    _user = await _authService.getUserInfo();
    notifyListeners();
  }

  // Save user info and notify listeners
  Future<void> saveUser(User user) async {
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
}
