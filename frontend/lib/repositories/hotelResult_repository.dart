import 'package:travelowkey/services/api_service.dart';
import 'package:travelowkey/models/hotel_model.dart';

class HotelResultRepository {
  final HotelResultDataProvider dataProvider;

  HotelResultRepository({required this.dataProvider});

  Future<List<Hotel>> fetchHotels({
    Map<String, dynamic>? searchInfo,
    Map<String, dynamic>? filterOption,
    String? sortOption,
    required int? offset,
    required int? limit,
  }) async {
    // Get all hotels from the data provider
    List<Hotel> hotels = await dataProvider.fetchHotelResults(searchInfo:searchInfo, offset: offset, limit: limit);
    if (hotels.isEmpty) {
      throw Exception("No hotels found");
    }
    // Filter by airline if a filter option is provided
    if (filterOption != null && filterOption.isNotEmpty) {
      hotels = hotels.where((hotel) => hotel.price! >= int.parse(filterOption['minPrice']!) && hotel.price! <= int.parse(filterOption['maxPrice']!) && filterOption['selectedStars'].contains(hotel.rating!)).toList();
    }

    // Sort by price or departure time if a sort option is provided
    if (sortOption != null) {
      switch (sortOption) {
        case "price_asc":
          hotels.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
          break;
        case "price_desc":
          hotels.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
          break;
        default:
          break;
      }
    }

    return hotels;
  }
}
