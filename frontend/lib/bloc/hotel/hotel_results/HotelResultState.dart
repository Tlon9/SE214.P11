// Hotel_result_state.dart
import 'package:equatable/equatable.dart';
import 'package:travelowkey/models/hotel_model.dart'; // Model for Hotel result data

abstract class HotelResultState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HotelResultInitial extends HotelResultState {}

class HotelResultLoading extends HotelResultState {}

class HotelResultLoaded extends HotelResultState {
  final List<Hotel> hotels;
  final Map<String, dynamic>? filterOption; // Current filter
  final String? sortOption; // Current sort
  final int? offset;

  HotelResultLoaded(
      {required this.hotels, this.filterOption, this.sortOption, this.offset});

  @override
  List<Object?> get props => [hotels, filterOption, sortOption, offset];
  // List<Object?> get props => [hotels, sortOption];
}

class HotelResultError extends HotelResultState {
  final String message;

  HotelResultError(this.message);

  @override
  List<Object?> get props => [message];
}
