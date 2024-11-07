// flight_search_data_provider.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travelowkey/models/flightSearch_model.dart';

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
