// flight_search_data_provider.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travelowkey/models/flightSearch_model.dart';
import 'package:travelowkey/models/flight_model.dart';

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
    // final response = await http.get(Uri.parse(apiUrl));
    final response = {
      "departures": ["TP HCM (SGN)", "Hà Nội (HAN)", "Đà Nẵng (DAD)"],
      "destinations": ["TP HCM (SGN)", "Hà Nội (HAN)", "Đà Nẵng (DAD)"],
      "seatClasses": ["Economy", "Business", "First Class"],
      "passengerCounts": [1, 2, 3],
    };
    return FlightSearchModel.fromJson(response);
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
    // Append search info as query parameters
    // final uri = Uri.parse(apiUrl).replace(queryParameters: searchInfo);
    // final response = await http.get(uri);

    const mockResponse = '''
      {
        "flights": [
          {
            "name": "VietJet Air",
            "departureTime": "22:50",
            "arrivalTime": "01:00",
            "price": 1703440,
            "departureLocation": "SGN",
            "arrivalLocation": "HAN",
            "duration": "2h 10m",
            "seatClass": "Economy"
          },
          {
            "name": "VietJet Air",
            "departureTime": "22:50",
            "arrivalTime": "01:00",
            "price": 1703440,
            "departureLocation": "SGN",
            "arrivalLocation": "HAN",
            "duration": "2h 10m",
            "seatClass": "Economy"
          },
          {
            "name": "VietJet Air",
            "departureTime": "22:50",
            "arrivalTime": "01:00",
            "price": 1703440,
            "departureLocation": "SGN",
            "arrivalLocation": "HAN",
            "duration": "2h 10m",
            "seatClass": "Economy"
          },
          {
            "name": "VietJet Air",
            "departureTime": "22:50",
            "arrivalTime": "01:00",
            "price": 1703440,
            "departureLocation": "SGN",
            "arrivalLocation": "HAN",
            "duration": "2h 10m",
            "seatClass": "Economy"
          },
          {
            "name": "VietJet Air",
            "departureTime": "22:50",
            "arrivalTime": "01:00",
            "price": 1703440,
            "departureLocation": "SGN",
            "arrivalLocation": "HAN",
            "duration": "2h 10m",
            "seatClass": "Economy"
          },
          {
            "name": "VietJet Air",
            "departureTime": "22:50",
            "arrivalTime": "01:00",
            "price": 1703440,
            "departureLocation": "SGN",
            "arrivalLocation": "HAN",
            "duration": "2h 10m",
            "seatClass": "Economy"
          },
          {
            "name": "Vietnam Airlines",
            "departureTime": "08:00",
            "arrivalTime": "10:30",
            "price": 2250000,
            "departureLocation": "SGN",
            "arrivalLocation": "HAN",
            "duration": "2h 30m",
            "seatClass": "Economy"
          }
        ]
      }
      ''';
    final response = json.decode(mockResponse);
    final temp = (response['flights'] as List)
        .map((json) => Flight.fromJson(json))
        .toList();
    print(temp);
    return temp;

    // if (response.statusCode == 200) {
    //   // Parse the JSON data
    //   List<dynamic> data = json.decode(response.body);
    //   return data.map((json) => Flight.fromJson(json)).toList();
    // } else {
    //   throw Exception("Failed to load flight data");
  }
}
