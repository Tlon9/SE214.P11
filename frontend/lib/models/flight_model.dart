import 'package:mongo_dart/mongo_dart.dart';

class Flight {
  ObjectId? id;
  String? flightId;
  String? from;
  String? to;
  String? date;
  String? departureTime;
  String? arrivalTime;
  String? travelTime;
  String? stopDirect;
  String? name;
  String? seatClass;
  int? numSeat;
  int? price;

  Flight({
    this.id,
    this.flightId,
    this.from,
    this.to,
    this.date,
    this.departureTime,
    this.arrivalTime,
    this.travelTime,
    this.stopDirect,
    this.name,
    this.seatClass,
    this.numSeat,
    this.price,
  });

  // Convert JSON to a Flight object
  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['_id'] != null ? ObjectId.parse(json['_id']) : null,
      flightId: json['Id']
          as String?, // Assuming flightId may be missing in mock data
      from: json['departureLocation'] as String?,
      to: json['arrivalLocation'] as String?,
      date: json['Date'] as String?, // Date is missing in mock data
      departureTime: json['departureTime'] as String?,
      arrivalTime: json['arrivalTime'] as String?,
      travelTime: json['duration'] as String?,
      stopDirect:
          json['Stop_Direct'] as String?, // Stop_Direct is missing in mock data
      name: json['name'] as String?,
      seatClass: json['seatClass'] as String?,
      numSeat: json['NumSeat']
          as int?, // Assuming NumSeat may be missing in mock data
      price: json['price'] as int?,
    );
  }

  // Convert a Flight object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'Id': flightId,
      'From': from,
      'To': to,
      'Date': date,
      'DepartureTime': departureTime,
      'ArrivalTime': arrivalTime,
      'TravelTime': travelTime,
      'Stop_Direct': stopDirect,
      'Name': name,
      'SeatClass': seatClass,
      'NumSeat': numSeat,
      'Price': price,
    };
  }
}
