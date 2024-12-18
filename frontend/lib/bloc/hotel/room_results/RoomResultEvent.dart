// Room_result_event.dart
import 'package:equatable/equatable.dart';

abstract class RoomResultEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadRoomResults extends RoomResultEvent {
  final Map<String, dynamic>? searchInfo;

  LoadRoomResults({this.searchInfo});

  @override
  List<Object?> get props => [searchInfo];
}

class ApplyFilter extends RoomResultEvent {
  final Map<String, dynamic>? filterOption;
  final Map<String, dynamic>? searchInfo;

  ApplyFilter(this.filterOption, this.searchInfo);

  @override
  List<Object?> get props => [filterOption];
}

class ApplySort extends RoomResultEvent {
  final String sortOption;
  final Map<String, dynamic>? searchInfo;

  ApplySort(this.sortOption, this.searchInfo);

  @override
  List<Object?> get props => [sortOption];
}
