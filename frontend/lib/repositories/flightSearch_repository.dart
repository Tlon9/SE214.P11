// flight_search_repository.dart
import 'package:user_registration/services/api_service.dart';
import 'package:user_registration/models/flightSearch_model.dart';

class FlightSearchRepository {
  final FlightSearchDataProvider dataProvider;

  FlightSearchRepository({required this.dataProvider});

  Future<FlightSearchModel> getFlightSearchData() async {
    return await dataProvider.fetchFlightSearchData();
  }
}
