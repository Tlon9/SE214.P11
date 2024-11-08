// flight_result_event.dart
import 'package:equatable/equatable.dart';

abstract class FlightResultEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFlightResults extends FlightResultEvent {
  final Map<String, dynamic>? searchInfo;

  LoadFlightResults({this.searchInfo});

  @override
  List<Object?> get props => [searchInfo];
}

class ApplyFilter extends FlightResultEvent {
  final String filterOption;
  final Map<String, dynamic>? searchInfo;

  ApplyFilter(this.filterOption, this.searchInfo);

  @override
  List<Object?> get props => [filterOption];
}

class ApplySort extends FlightResultEvent {
  final String sortOption;
  final Map<String, dynamic>? searchInfo;

  ApplySort(this.sortOption, this.searchInfo);

  @override
  List<Object?> get props => [sortOption];
}
