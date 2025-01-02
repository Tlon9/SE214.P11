import 'package:travelowkey/models/area_model.dart';
import 'package:travelowkey/models/flight_model.dart';
import 'package:travelowkey/models/hotel_model.dart';
import 'package:travelowkey/services/api_service.dart';

class ExploreRepository {
  final ExploreDataProvider dataProvider;

  ExploreRepository({required this.dataProvider});

  Future<Map<String, List<dynamic>>> fetchHotels({String? queryArea}) async {
    try {
      final results = await  dataProvider.fetchResults(queryArea: queryArea);
      return {
        'hotels': results['hotels'] as List<Hotel>,
        'flights': results['flights'] as List<Flight>,
        'areas': results['areas'] as List<Area>,
      };
      // return await dataProvider.fetchHotelResults();
    } catch (e) {
      throw Exception("Failed to fetch payment history: $e");
    }
  }
}