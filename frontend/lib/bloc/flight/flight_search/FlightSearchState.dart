// flight_search_state.dart
import 'package:equatable/equatable.dart';

abstract class FlightSearchState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FlightSearchInitial extends FlightSearchState {}

class FlightSearchLoading extends FlightSearchState {}

class FlightSearchDataLoaded extends FlightSearchState {
  final List<String> departures;
  final List<String> destinations;
  final List<String> seatClasses;
  final List<int> passengerCounts;
  final String? selectedDeparture;
  final String? selectedDestination;
  final String? selectedSeatClass;
  final int? selectedPassengerCount;
  final DateTime? selectedDepartureDate;

  FlightSearchDataLoaded({
    required this.departures,
    required this.destinations,
    required this.seatClasses,
    required this.passengerCounts,
    this.selectedDeparture,
    this.selectedDestination,
    this.selectedSeatClass,
    this.selectedPassengerCount,
    this.selectedDepartureDate,
  });

  FlightSearchDataLoaded copyWith({
    List<String>? departures,
    List<String>? destinations,
    List<String>? seatClasses,
    List<int>? passengerCounts,
    String? selectedDeparture,
    String? selectedDestination,
    String? selectedSeatClass,
    int? selectedPassengerCount,
    DateTime? selectedDepartureDate,
  }) {
    return FlightSearchDataLoaded(
      departures: departures ?? this.departures,
      destinations: destinations ?? this.destinations,
      seatClasses: seatClasses ?? this.seatClasses,
      passengerCounts: passengerCounts ?? this.passengerCounts,
      selectedDeparture: selectedDeparture ?? this.selectedDeparture,
      selectedDestination: selectedDestination ?? this.selectedDestination,
      selectedSeatClass: selectedSeatClass ?? this.selectedSeatClass,
      selectedPassengerCount:
          selectedPassengerCount ?? this.selectedPassengerCount,
      selectedDepartureDate:
          selectedDepartureDate ?? this.selectedDepartureDate,
    );
  }

  @override
  List<Object?> get props => [
        departures,
        destinations,
        seatClasses,
        passengerCounts,
        selectedDeparture,
        selectedDestination,
        selectedSeatClass,
        selectedPassengerCount,
        selectedDepartureDate,
      ];
}
