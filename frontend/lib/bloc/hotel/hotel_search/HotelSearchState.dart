// flight_search_state.dart
import 'package:equatable/equatable.dart';

abstract class HotelSearchState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HotelSearchInitial extends HotelSearchState {}

class HotelSearchLoading extends HotelSearchState {}

class HotelSearchDataLoaded extends HotelSearchState {
  final List<String> areas;
  final List<int> customerCounts;
  final String? selectedArea;
  final int? selectedCustomerCount;
  final DateTime? selectedCheckInDate;
  final DateTime? selectedCheckOutDate;

  HotelSearchDataLoaded({
    required this.areas,
    required this.customerCounts,
    this.selectedArea,
    this.selectedCustomerCount,
    this.selectedCheckInDate,
    this.selectedCheckOutDate,
  });

  HotelSearchDataLoaded copyWith({
    List<String>? areas,
    List<int>? customerCounts,
    String? selectedArea,
    int? selectedCustomerCount,
    DateTime? selectedCheckInDate,
    DateTime? selectedCheckOutDate
  }) {
    return HotelSearchDataLoaded(
      areas: areas ?? this.areas,
      customerCounts: customerCounts ?? this.customerCounts,
      selectedArea: selectedArea ?? this.selectedArea,
      selectedCustomerCount: selectedCustomerCount ?? this.selectedCustomerCount,
      selectedCheckInDate:
          selectedCheckInDate ?? this.selectedCheckInDate,
      selectedCheckOutDate:
          selectedCheckOutDate ?? this.selectedCheckOutDate,
    );
  }

  @override
  List<Object?> get props => [
        areas,
        customerCounts,
        selectedArea,
        selectedCustomerCount,
        selectedCheckInDate,
        selectedCheckOutDate,
      ];
}
