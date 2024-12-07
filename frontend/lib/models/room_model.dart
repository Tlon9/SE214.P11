import 'package:mongo_dart/mongo_dart.dart';

class Room {
  ObjectId? id;
  String? hotel_id;
  String? name;
  int? customers;
  List<dynamic>? img;
  int? price;
  String? state;
  String? service;

  Room({
    this.id,
    this.hotel_id,
    this.name,
    this.customers,
    this.img,
    this.price,
    this.state,
    this.service
  });

  // Convert JSON to a Room object
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['_id'] != null ? ObjectId.parse(json['_id']) : null,
      hotel_id: json['Hotel_id'] as String?,
      name: json['Name'] as String?,
      customers: json['Max'] as int?,
      img: json['Img'] as List<dynamic>?,
      price: json['Price'] as int?,
      state: json['State'] as String?,
      service: json['Service'] as String?
    );
  }

  // Convert a Room object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'Hotel_id': hotel_id,
      'Name': name,
      'Max': customers,
      'Img': img,
      'Price': price,
      'State': state,
      'Service': service
    };
  }
}
