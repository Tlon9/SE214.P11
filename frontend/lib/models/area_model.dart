import 'package:mongo_dart/mongo_dart.dart';

class Area {
  ObjectId? id;
  String? Id;
  String? area;
  String? country;
  String? img;

  Area({
    this.id,
    this.Id,
    this.area,
    this.country,
    this.img,
  });

  // Convert JSON to a hotel object
  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['_id'] != null ? ObjectId.parse(json['_id']) : null,
      Id: json['Id'] as String?,
      area: json['Area'] as String?,
      country: json['Country'] as String?,
      img: json['Img'] as String
    );
  }

  // Convert a Hotel object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'Id': Id,
      'Area': area,
      'Country': country,
      'Img': img,
    };
  }
}
