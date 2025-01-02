import 'package:equatable/equatable.dart';
import 'package:travelowkey/models/area_model.dart';
import 'package:travelowkey/models/flight_model.dart';
import 'package:travelowkey/models/hotel_model.dart';

abstract class ExploreState extends Equatable {
  const ExploreState();

  @override
  List<Object> get props => [];
}

class ExploreLoading extends ExploreState {}

class ExploreLoaded extends ExploreState {
  final List<Hotel> hotels;
  final List<Flight> flights;
  final List<Area> areas;

  const ExploreLoaded(this.hotels, this.flights, this. areas);

  @override
  List<Object> get props => [hotels];
}

class ExploreError extends ExploreState {
  final String message;

  const ExploreError(this.message);

  @override
  List<Object> get props => [message];
}
