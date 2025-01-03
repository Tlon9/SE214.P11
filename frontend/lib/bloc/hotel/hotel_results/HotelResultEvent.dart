// Hotel_result_event.dart
import 'package:equatable/equatable.dart';

abstract class HotelResultEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadHotelResults extends HotelResultEvent {
  final Map<String, dynamic>? searchInfo;

  LoadHotelResults({this.searchInfo});

  @override
  List<Object?> get props => [searchInfo];
}
class LoadMoreHotels extends HotelResultEvent {
  final Map<String, dynamic>? searchInfo;
  // final int? offset;  // The current offset
  LoadMoreHotels({required this.searchInfo});
}

class ApplyFilter extends HotelResultEvent {
  final Map<String, dynamic>? filterOption;
  final Map<String, dynamic>? searchInfo;

  ApplyFilter(this.filterOption, this.searchInfo);

  @override
  List<Object?> get props => [filterOption];
}

class ApplySort extends HotelResultEvent {
  final String sortOption;
  final Map<String, dynamic>? searchInfo;

  ApplySort(this.sortOption, this.searchInfo);

  @override
  List<Object?> get props => [sortOption];
}
