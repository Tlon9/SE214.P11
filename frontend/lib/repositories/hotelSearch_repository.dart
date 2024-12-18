// flight_search_repository.dart
import 'package:travelowkey/services/api_service.dart';
import 'package:travelowkey/models/hotelSearch_model.dart';

class HotelSearchRepository {
  final HotelSearchDataProvider dataProvider;

  HotelSearchRepository({required this.dataProvider});

  Future<HotelSearchModel> getHotelSearchData() async {
    return await dataProvider.fetchHotelSearchData();
  }
}
