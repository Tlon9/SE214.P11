// Room_result_state.dart
import 'package:equatable/equatable.dart';
import 'package:user_registration/models/room_model.dart'; // Model for Room result data

abstract class RoomResultState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RoomResultInitial extends RoomResultState {}

class RoomResultLoading extends RoomResultState {}

class RoomResultLoaded extends RoomResultState {
  final List<Room> rooms;
  final Map<String, dynamic>? filterOption; // Current filter
  final String? sortOption; // Current sort

  RoomResultLoaded({
    required this.rooms,
    this.filterOption,
    this.sortOption,
  });

  @override
  List<Object?> get props => [rooms, filterOption, sortOption];
}

class RoomResultError extends RoomResultState {
  final String message;

  RoomResultError(this.message);

  @override
  List<Object?> get props => [message];
}
