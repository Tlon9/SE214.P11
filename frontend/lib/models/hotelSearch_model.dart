class HotelSearchModel {
  final List<String> areas;
  final List<int> customerCounts;

  HotelSearchModel({
    required this.areas,
    required this.customerCounts
  });

  factory HotelSearchModel.fromJson(Map<String, dynamic> json) {
    return HotelSearchModel(
      areas: List<String>.from(json['areas']),
      customerCounts: List<int>.from(json['customerCounts']),
    );
  }
}
