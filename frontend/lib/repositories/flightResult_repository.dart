import 'package:user_registration/services/api_service.dart';
import 'package:user_registration/models/flight_model.dart';

class FlightResultRepository {
  final FlightResultDataProvider dataProvider;

  FlightResultRepository({required this.dataProvider});

  Future<List<Flight>> fetchFlights({
    Map<String, dynamic>? searchInfo,
    String? filterOption,
    String? sortOption,
  }) async {
    // Get all flights from the data provider
    List<Flight> flights =
        await dataProvider.fetchFlightResults(searchInfo: searchInfo);
    if (flights.isEmpty) {
      throw Exception("No flights found");
    }
    // Filter by airline if a filter option is provided
    if (filterOption != null && filterOption.isNotEmpty) {
      flights = flights.where((flight) => flight.name == filterOption).toList();
    }

    // Sort by price or departure time if a sort option is provided
    if (sortOption != null) {
      switch (sortOption) {
        case "price_asc":
          flights.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
          break;
        case "price_desc":
          flights.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
          break;
        case "time_departure_asc":
          flights.sort((a, b) =>
              (a.departureTime ?? '').compareTo(b.departureTime ?? ''));
          break;
        case "time_departure_desc":
          flights.sort((a, b) =>
              (b.departureTime ?? '').compareTo(a.departureTime ?? ''));
          break;
      }
    }

    return flights;
  }
}
