import 'package:mongo_dart/mongo_dart.dart';

class Room {
  ObjectId? id;
  String? hotel_id;
  String? room_id;
  String? name;
  int? customers;
  List<dynamic>? img;
  int? price;
  StateData? state;
  String? service;

  Room(
      {this.id,
      this.hotel_id,
      this.room_id,
      this.name,
      this.customers,
      this.img,
      this.price,
      this.state,
      this.service});

  // Convert JSON to a Room object
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
        id: json['_id'] != null ? ObjectId.parse(json['_id']) : null,
        hotel_id: json['Hotel_id'] as String?,
        room_id: json['Id'] as String?,
        name: json['Name'] as String?,
        customers: json['Max'] as int?,
        img: json['Img'] as List<dynamic>?,
        price: json['Price'] as int?,
        state: json['State'] != null
            ? StateData.fromJson(json['State'] as Map<String, dynamic>)
            : null,
        service: json['Service'] as String?);
  }

  // Convert a Room object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'Hotel_id': hotel_id,
      'Id': room_id,
      'Name': name,
      'Max': customers,
      'Img': img,
      'Price': price,
      'State': state?.toJson(),
      'Service': service
    };
  }
}

class StateData {
  List<Booking>? bookings;

  StateData({this.bookings});

  // Convert JSON to StateData object
  factory StateData.fromJson(Map<String, dynamic> json) {
    return StateData(
      bookings: json['Bookings'] != null
          ? (json['Bookings'] as List<dynamic>)
              .map((e) => Booking.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  // Convert StateData object to JSON
  Map<String, dynamic> toJson() {
    return {
      'Bookings': bookings?.map((e) => e.toJson()).toList(),
    };
  }
}

class Booking {
  String? checkIn;
  String? checkOut;

  Booking({this.checkIn, this.checkOut});

  // Convert JSON to Booking object
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      checkIn: json['check_in'] as String?,
      checkOut: json['check_out'] as String?,
    );
  }

  // Convert Booking object to JSON
  Map<String, dynamic> toJson() {
    return {
      'check_in': checkIn,
      'check_out': checkOut,
    };
  }
}
