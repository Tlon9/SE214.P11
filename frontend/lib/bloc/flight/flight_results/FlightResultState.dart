// flight_result_state.dart
import 'package:equatable/equatable.dart';
import 'package:travelowkey/models/flight_model.dart'; // Model for flight result data

abstract class FlightResultState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FlightResultInitial extends FlightResultState {}

class FlightResultLoading extends FlightResultState {}

class FlightResultLoaded extends FlightResultState {
  final List<Flight> flights;
  final String? filterOption; // Current filter
  final String? sortOption; // Current sort

  FlightResultLoaded({
    required this.flights,
    this.filterOption,
    this.sortOption,
  });

  @override
  List<Object?> get props => [flights, filterOption, sortOption];
}

class FlightResultError extends FlightResultState {
  final String message;

  FlightResultError(this.message);

  @override
  List<Object?> get props => [message];
}
