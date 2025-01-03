// Hotel_search_event.dart
import 'package:equatable/equatable.dart';

abstract class HotelSearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadHotelSearchData extends HotelSearchEvent {}

class SelectArea extends HotelSearchEvent {
  final String area;
  SelectArea(this.area);

  @override
  List<Object?> get props => [area];
}

class SelectCustomerCount extends HotelSearchEvent {
  final int customerCount;
  SelectCustomerCount(this.customerCount);

  @override
  List<Object?> get props => [customerCount];
}

class SelectCheckInDate extends HotelSearchEvent {
  final DateTime checkinDate;
  SelectCheckInDate(this.checkinDate);

  @override
  List<Object?> get props => [checkinDate];
}

class SelectCheckOutDate extends HotelSearchEvent {
  final DateTime checkoutDate;
  SelectCheckOutDate(this.checkoutDate);

  @override
  List<Object?> get props => [checkoutDate];
}

