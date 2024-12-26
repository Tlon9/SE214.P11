import 'package:mongo_dart/mongo_dart.dart';

class Hotel {
  ObjectId? id;
  String? id_hotel;
  String? name;
  String? address;
  int? rating;
  String? img;
  int? price;

  Hotel({
    this.id,
    this.id_hotel,
    this.name,
    this.address,
    this.rating,
    this.img,
    this.price,
  });

  // Convert JSON to a hotel object
  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['_id'] != null ? ObjectId.parse(json['_id']) : null,
      id_hotel: json['Id'] as String?,
      name: json['Name'] as String?,
      address: json['Address'] as String?,
      rating: json['Rating'] as int?,
      img: json['Img'] as String?,
      price: json['Price'] as int?,
    );
  }

  // Convert a Hotel object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'Id': id_hotel,
      'Name': name,
      'Address': address,
      'Rating': rating,
      'Img': img,
      'Price': price,
    };
  }
}
