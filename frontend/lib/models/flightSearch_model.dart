// flight_search_model.dart

class FlightSearchModel {
  final List<String> departures;
  final List<String> destinations;
  final List<String> seatClasses;
  final List<int> passengerCounts;

  FlightSearchModel({
    required this.departures,
    required this.destinations,
    required this.seatClasses,
    required this.passengerCounts,
  });

  factory FlightSearchModel.fromJson(Map<String, dynamic> json) {
    return FlightSearchModel(
      departures: List<String>.from(json['departures']),
      destinations: List<String>.from(json['destinations']),
      seatClasses: List<String>.from(json['seatClasses']),
      passengerCounts: List<int>.from(json['passengerCounts']),
    );
  }
}
