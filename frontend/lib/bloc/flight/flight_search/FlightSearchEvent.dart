// flight_search_event.dart
import 'package:equatable/equatable.dart';

abstract class FlightSearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFlightSearchData extends FlightSearchEvent {}

class SelectDeparture extends FlightSearchEvent {
  final String departure;
  SelectDeparture(this.departure);

  @override
  List<Object?> get props => [departure];
}

class SelectDestination extends FlightSearchEvent {
  final String destination;
  SelectDestination(this.destination);

  @override
  List<Object?> get props => [destination];
}

class SelectSeatClass extends FlightSearchEvent {
  final String seatClass;
  SelectSeatClass(this.seatClass);

  @override
  List<Object?> get props => [seatClass];
}

class SelectPassengerCount extends FlightSearchEvent {
  final int passengerCount;
  SelectPassengerCount(this.passengerCount);

  @override
  List<Object?> get props => [passengerCount];
}

class SelectDepartureDate extends FlightSearchEvent {
  final DateTime departureDate;
  SelectDepartureDate(this.departureDate);

  @override
  List<Object?> get props => [departureDate];
}
