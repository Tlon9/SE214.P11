import 'package:travelowkey/services/api_service.dart';
import 'package:travelowkey/models/room_model.dart';

class RoomResultRepository {
  final RoomResultDataProvider dataProvider;

  RoomResultRepository({required this.dataProvider});

  Future<List<Room>> fetchRooms({
    Map<String, dynamic>? searchInfo,
    Map<String, dynamic>? filterOption,
    String? sortOption,
  }) async {
    // Get all Rooms from the data provider
    List<Room> rooms = await dataProvider.fetchRoomResults();
    rooms = rooms.where((room) => room.customers! == int.parse(searchInfo!["customers"])).toList();
    if (rooms.isEmpty) {
      throw Exception("No Rooms found");
    }
    // Filter by airline if a filter option is provided
    if (filterOption != null && filterOption.isNotEmpty) {
      rooms = rooms.where((room) => room.price! >= int.parse(filterOption['minPrice']!) && room.price! <= int.parse(filterOption['maxPrice']!)).toList();
    }


    // Sort by price or departure time if a sort option is provided
    if (sortOption != null) {
      switch (sortOption) {
        case "price_asc":
          rooms.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
          break;
        case "price_desc":
          rooms.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
          break;
        default:
          break;
      }
    }
    return rooms;
  }
}
